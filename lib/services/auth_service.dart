import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:convert';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // สมัครสมาชิก
  Future<bool> signup({
    required String email,
    required String username,
    required String password,
  }) async {
    try {
      if (username.isEmpty || email.isEmpty || password.isEmpty) {
        _showToast('All fields are required');
        return false;
      }

      if (password.length < 6) {
        _showToast('Password must be at least 6 characters');
        return false;
      }

      final usernameExists = await _firestore
          .collection('users')
          .where('username', isEqualTo: username)
          .limit(1)
          .get()
          .then((snapshot) => snapshot.docs.isNotEmpty);

      if (usernameExists) {
        _showToast('Username already taken');
        return false;
      }

      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _saveUserData(
        uid: userCredential.user!.uid,
        email: email,
        username: username,
      );

      await userCredential.user?.updateProfile(displayName: username);

      _showToast('Signup successful!');
      return true;
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
      return false;
    } catch (e) {
      _showToast('An error occurred: ${e.toString()}');
      return false;
    }
  }

  // เข้าสู่ระบบ
  Future<bool> loginWithUsername({
    required String username,
    required String password,
  }) async {
    try {
      if (username.isEmpty || password.isEmpty) {
        _showToast('Username and password are required');
        return false;
      }

      final userSnapshot = await _firestore
          .collection('users')
          .where('username', isEqualTo: username)
          .limit(1)
          .get();

      if (userSnapshot.docs.isEmpty) {
        _showToast('Username not found');
        return false;
      }

      final userData = userSnapshot.docs.first.data();
      final email = userData['email'] as String;

      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      _showToast('Login successful!');
      return true;
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e, isLogin: true);
      return false;
    } catch (e) {
      _showToast('An error occurred: ${e.toString()}');
      return false;
    }
  }

  // ส่งอีเมลรีเซ็ตรหัสผ่าน (แก้ไขแล้ว)
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      // ตรวจสอบใน Firestore ก่อน
      final userSnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email.toLowerCase().trim())
          .limit(1)
          .get();

      if (userSnapshot.docs.isEmpty) {
        throw Exception('No account found with that email');
      }

      // ลองส่งอีเมลรีเซ็ตโดยตรง
      try {
        await _auth.sendPasswordResetEmail(email: email);
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          // ถ้าไม่พบใน Auth แต่มีใน Firestore ให้สร้างบัญชีชั่วคราว
          await _createTemporaryAuthAccount(email, userSnapshot.docs.first.data());
          // ส่งอีเมลรีเซ็ตอีกครั้ง
          await _auth.sendPasswordResetEmail(email: email);
        } else {
          rethrow;
        }
      }

      _showToast('Password reset email sent. Please check your inbox.');
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
      rethrow;
    } catch (e) {
      _showToast('Error: ${e.toString()}');
      rethrow;
    }
  }

  // สร้างบัญชีชั่วคราวใน Firebase Auth
  Future<void> _createTemporaryAuthAccount(String email, Map<String, dynamic> userData) async {
    try {
      // สร้างรหัสผ่านชั่วคราวแบบสุ่ม
      final tempPassword = _generateTempPassword();
      
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: tempPassword,
      );
      
      // บันทึกข้อมูลผู้ใช้เพิ่มเติม
      await _saveUserData(
        uid: userCredential.user!.uid,
        email: email,
        username: userData['username'] ?? email.split('@')[0],
      );
    } on FirebaseAuthException catch (e) {
      if (e.code != 'email-already-in-use') rethrow;
    }
  }

  // สร้างรหัสผ่านชั่วคราว
  String _generateTempPassword() {
    final random = Random.secure();
    return base64Encode(List<int>.generate(16, (_) => random.nextInt(256)));
  }

  // ออกจากระบบ
  Future<void> logout() async {
    try {
      await _auth.signOut();
      _showToast('Logged out successfully', isShort: true);
    } catch (e) {
      _showToast('Logout failed: ${e.toString()}');
      throw e;
    }
  }

  // รับผู้ใช้ปัจจุบัน
  User? get currentUser => _auth.currentUser;

  // ---------------------- ฟังก์ชันช่วยเหลือส่วนตัว ----------------------

  Future<void> _saveUserData({
    required String uid,
    required String email,
    required String username,
  }) async {
    await _firestore.collection('users').doc(uid).set({
      'uid': uid,
      'email': email,
      'username': username,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'borrowedBooks': [],
      'favorites': [],
      'role': 'user',
      'isTemporary': true, // ระบุว่าเป็นบัญชีชั่วคราว
    }, SetOptions(merge: true));
  }

  void _handleAuthError(FirebaseAuthException e, {bool isLogin = false}) {
    String message = isLogin ? 'Login failed' : 'Signup failed';
    
    if (e.code == 'weak-password') {
      message = 'Password is too weak';
    } else if (e.code == 'email-already-in-use') {
      message = 'Email already in use';
    } else if (e.code == 'invalid-email') {
      message = 'Invalid email format';
    } else if (e.code == 'user-not-found' || e.code == 'wrong-password') {
      message = 'Invalid username or password';
    } else if (e.code == 'user-disabled') {
      message = 'This account has been disabled';
    } else if (e.code == 'too-many-requests') {
      message = 'Too many requests. Please try again later';
    }
    
    _showToast(message);
  }

  void _showToast(String message, {bool isShort = false}) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: isShort ? Toast.LENGTH_SHORT : Toast.LENGTH_LONG,
    );
  }
}