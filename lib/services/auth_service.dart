import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import 'dart:convert';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // สมัครสมาชิกใหม่
  Future<bool> signup({
    required String email,
    required String username,
    required String password,
  }) async {
    try {
      // ตรวจสอบข้อมูลที่จำเป็น
      if (username.isEmpty || email.isEmpty || password.isEmpty) {
        _showToast('กรุณากรอกข้อมูลให้ครบทุกช่อง');
        return false;
      }

      // ตรวจสอบความยาวรหัสผ่าน
      if (password.length < 8 || password.length > 20) {
        _showToast('รหัสผ่านต้องมีความยาว 8-20 ตัวอักษร');
        return false;
      }

      // ตรวจสอบว่าชื่อผู้ใช้ซ้ำหรือไม่
      final usernameExists = await _firestore
          .collection('users')
          .where('username', isEqualTo: username)
          .limit(1)
          .get()
          .then((snapshot) => snapshot.docs.isNotEmpty);

      if (usernameExists) {
        _showToast('ชื่อผู้ใช้นี้ถูกใช้งานแล้ว');
        return false;
      }

      // สร้างบัญชีใน Firebase Auth
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // บันทึกข้อมูลผู้ใช้เพิ่มเติมใน Firestore
      await _saveUserData(
        uid: userCredential.user!.uid,
        email: email,
        username: username,
      );

      // อัปเดตชื่อผู้ใช้ใน Firebase Auth (ไม่ได้ทำในส่วนของupdate profile แต่เขียนไว้ก่อน)
      await userCredential.user?.updateProfile(displayName: username);

      _showToast('สมัครสมาชิกสำเร็จ!');
      return true;
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
      return false;
    } catch (e) {
      _showToast('เกิดข้อผิดพลาด: ${e.toString()}');
      return false;
    }
  }

  // เข้าสู่ระบบด้วยชื่อผู้ใช้
  Future<bool> loginWithUsername({
    required String username,
    required String password,
  }) async {
    try {
      // ตรวจสอบข้อมูลที่จำเป็น
      if (username.isEmpty || password.isEmpty) {
        _showToast('กรุณากรอกชื่อผู้ใช้และรหัสผ่าน');
        return false;
      }

      // ค้นหาอีเมลจากชื่อผู้ใช้ใน Firestore
      final userSnapshot = await _firestore
          .collection('users')
          .where('username', isEqualTo: username)
          .limit(1)
          .get();

      if (userSnapshot.docs.isEmpty) {
        _showToast('ไม่พบชื่อผู้ใช้นี้ในระบบ');
        return false;
      }

      final userData = userSnapshot.docs.first.data();
      final email = userData['email'] as String;

      // เข้าสู่ระบบด้วยอีเมลและรหัสผ่าน
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      _showToast('เข้าสู่ระบบสำเร็จ!');
      return true;
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e, isLogin: true);
      return false;
    } catch (e) {
      _showToast('เกิดข้อผิดพลาด: ${e.toString()}');
      return false;
    }
  }

  // ส่งอีเมลรีเซ็ตรหัสผ่าน
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      // ตรวจสอบว่าอีเมลมีอยู่ใน Firestore หรือไม่
      final userSnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email.toLowerCase().trim())
          .limit(1)
          .get();

      if (userSnapshot.docs.isEmpty) {
        throw Exception('ไม่พบบัญชีที่ใช้อีเมลนี้');
      }

      // พยายามส่งอีเมลรีเซ็ตรหัสผ่าน
      try {
        await _auth.sendPasswordResetEmail(email: email);
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          // หากไม่พบใน Auth แต่มีใน Firestore ให้สร้างบัญชีชั่วคราว
          await _createTemporaryAuthAccount(email, userSnapshot.docs.first.data());
          // ส่งอีเมลรีเซ็ตอีกครั้ง
          await _auth.sendPasswordResetEmail(email: email);
        } else {
          rethrow;
        }
      }

      _showToast('ส่งอีเมลรีเซ็ตรหัสผ่านเรียบร้อย กรุณาตรวจสอบอีเมลของคุณ');
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
      rethrow;
    } catch (e) {
      _showToast('ข้อผิดพลาด: ${e.toString()}');
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
      
      // บันทึกข้อมูลผู้ใช้
      await _saveUserData(
        uid: userCredential.user!.uid,
        email: email,
        username: userData['username'] ?? email.split('@')[0],
      );
    } on FirebaseAuthException catch (e) {
      if (e.code != 'email-already-in-use') rethrow;
    }
  }

  // สร้างรหัสผ่านชั่วคราวแบบสุ่ม
  String _generateTempPassword() {
    final random = Random.secure();
    return base64Encode(List<int>.generate(16, (_) => random.nextInt(256)));
  }

  // ออกจากระบบ
  Future<void> logout() async {
    try {
      await _auth.signOut();
      _showToast('ออกจากระบบสำเร็จ', isShort: true);
    } catch (e) {
      _showToast('ออกจากระบบไม่สำเร็จ: ${e.toString()}');
      rethrow;
    }
  }

  // ลบบัญชีผู้ใช้
  Future<void> deleteUserAccount() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        // ลบข้อมูลผู้ใช้จาก Firestore ก่อน
        await _firestore.collection('users').doc(user.uid).delete();
        // แล้วจึงลบบัญชีจาก Firebase Auth
        await user.delete();
        _showToast('ลบบัญชีเรียบร้อยแล้ว');
      }
    } catch (e) {
      _showToast('ลบบัญชีไม่สำเร็จ: ${e.toString()}');
      rethrow;
    }
  }

  // รับผู้ใช้ปัจจุบัน เข้าถึงข้อมูลต่างๆ
  User? get currentUser => _auth.currentUser;

  // ---------------------- ฟังก์ชันช่วยเหลือส่วนตัว ----------------------

  // บันทึกข้อมูลผู้ใช้ใน Firestore
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
    }, SetOptions(merge: true)); //รวมข้อมูลใหม่กับของเดิม
  }

  // จัดการข้อผิดพลาดจากการ Authentication
  void _handleAuthError(FirebaseAuthException e, {bool isLogin = false}) {
    String message = isLogin ? 'เข้าสู่ระบบไม่สำเร็จ' : 'สมัครสมาชิกไม่สำเร็จ';
    
    if (e.code == 'weak-password') {
      message = 'รหัสผ่านไม่แข็งแรงพอ';
    } else if (e.code == 'email-already-in-use') {
      message = 'อีเมลนี้ถูกใช้งานแล้ว';
    } else if (e.code == 'invalid-email') {
      message = 'รูปแบบอีเมลไม่ถูกต้อง';
    } else if (e.code == 'user-not-found' || e.code == 'wrong-password') {
      message = 'ชื่อผู้ใช้หรือรหัสผ่านไม่ถูกต้อง';
    } else if (e.code == 'user-disabled') {
      message = 'บัญชีนี้ถูกระงับการใช้งาน';
    } else if (e.code == 'too-many-requests') {
      message = 'มีการร้องขอมากเกินไป กรุณาลองใหม่ในภายหลัง';
    }
    
    _showToast(message);
  }

  // แสดง Toast Message
  void _showToast(String message, {bool isShort = false}) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: isShort ? Toast.LENGTH_SHORT : Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
    );
  }
}