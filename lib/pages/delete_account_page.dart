import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:libraryapp/services/auth_service.dart';

class DeleteAccountPage extends StatefulWidget {
  const DeleteAccountPage({super.key});

  @override
  State<DeleteAccountPage> createState() => _DeleteAccountPageState();
}

  Future<void> _deleteRelatedData(String userId) async {
    // Delete all user-related data from other collections
    final batch = FirebaseFirestore.instance.batch();
    
    // Example: Delete borrowed books history
    final borrows = await FirebaseFirestore.instance
        .collection('borrowed_books')
        .where('uid', isEqualTo: userId)
        .get();

    for (var doc in borrows.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }
  
class _DeleteAccountPageState extends State<DeleteAccountPage> {
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  Future<void> _deleteAccount() async {
    setState(() => _isLoading = true);
    
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // 1. Delete user data from Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .delete();

        // 2. Delete ข้อมูลที่เคยโพสหรือเกี่ยวข้องใน data
        await _deleteRelatedData(user.uid);

        // 3. Delete authentication account
        await _authService.deleteUserAccount();

        // 4. Navigate to login page and clear all routes
        if (!mounted) return;
        Navigator.pushNamedAndRemoveUntil(
          context, 
          '/loginpage', 
          (route) => false
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting account: ${e.toString()}')),
      );
    } finally {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }



  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const Text(
            'This will permanently delete your account and all related data.',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            icon: const Icon(Icons.warning, color: Colors.white),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              minimumSize: const Size(double.infinity, 50),
            ),
            onPressed: _isLoading ? null : _deleteAccount,
            label: _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text(
                    'Delete My Account',
                    style: TextStyle(color: Colors.white),
                  ),
          ),
        ],
      ),
    );
  }
}