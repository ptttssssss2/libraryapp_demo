import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';


class BorrowRecord {
  final String bookId;
  final String bookTitle;
  final String author; // เพิ่ม field นี้
  final String imagePath; // เปลี่ยนจาก bookCoverUrl เป็น imagePath
  final DateTime borrowDate;
  final DateTime returnDate; // เปลี่ยนจาก dueDate เป็น returnDate
  final String status;
  final String uid; // เปลี่ยนจาก returned เป็น status

  BorrowRecord({
    required this.bookId,
    required this.bookTitle,
    required this.author,
    required this.imagePath,
    required this.borrowDate,
    required this.returnDate,
    required this.status,
    required this.uid,
  });

// ใน BorrowRecord model
factory BorrowRecord.fromFirestore(DocumentSnapshot doc) {
  final data = doc.data() as Map<String, dynamic>;
  return BorrowRecord(
    bookId: data['bookId'] as String? ?? doc.id,
    bookTitle: data['bookTitle'] as String? ?? 'No title',
    author: data['author'] as String? ?? 'Unknown',
    imagePath: data['imagePath'] as String? ?? '',
    borrowDate: (data['borrowDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
    returnDate: (data['returnDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
    status: (data['status'] as String?)?.toLowerCase() ?? 'borrowed',
    uid: data['uid'] as String? ?? '',
  );
}

  Map<String, dynamic> toMap() {
    return {
      'bookId': bookId,
      'bookTitle': bookTitle,
      'author': author,
      'imagePath': imagePath,
      'borrowDate': Timestamp.fromDate(borrowDate),
      'returnDate': Timestamp.fromDate(returnDate),
      'status': status,
      'uid': uid,
    };
  }

  // เพิ่ม convenience getter เพื่อตรวจสอบว่าคืนแล้วหรือไม่
  // bool get isReturned => status == 'returned';
 // bool get isOverdue => !isReturned && returnDate.isBefore(DateTime.now());

  // สำหรับแสดงสถานะเป็นข้อความ
 // String get statusText {
   // if (isReturned) return 'Returned';
    //if (isOverdue) return 'Overdue';
    //return 'Borrowed';
  //}

  // สำหรับแสดงสีสถานะ
 // Color get statusColor {
    //if (isReturned) return Colors.green;
    //if (isOverdue) return Colors.red;
   // return Colors.orange;
  //}
}