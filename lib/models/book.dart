//import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';


 /*2. class Book {
  String title;
  String author;
  String imagePath;

  Book({
    required this.title,
    required this.author,
    required this.imagePath,
  });

  // ฟังก์ชันสำหรับแปลงข้อมูล JSON เป็น Book object
  factory Book.fromJson(Map<String, dynamic> json) {
    final work = json['work'];
    final title = work['title'] ?? 'No Title';
    final author = work['author_names'] != null && work['author_names'].isNotEmpty
        ? work['author_names'][0] ?? 'Unknown Author'
        : 'Unknown Author';

    final coverId = work['cover_id']?.toString();
    final imagePath = coverId != null
        ? 'https://covers.openlibrary.org/b/id/$coverId-M.jpg'
        : 'https://via.placeholder.com/150'; // ถ้าไม่มีภาพปก

    return Book(
      title: title,
      author: author,
      imagePath: imagePath,
    );
  }
}*/
class Book {
  final String title;
  final String author;
  final String imagePath;
  final String? rating;
  final int? firstPublishYear;
  final String? loggedDate;

  Book({
    required this.title,
    required this.author,
    required this.imagePath,
    this.rating,
    this.firstPublishYear,
    this.loggedDate,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    final work = json['work'];

    final title = work['title'] ?? 'No Title';

    // ดึงชื่อผู้แต่งแบบปลอดภัย
    final author = (json['author_names'] as List?)?.isNotEmpty == true
        ? json['author_names'][0]
        : 'Unknown Author';

    final coverId = work['cover_id']?.toString();
    final imagePath = coverId != null
        ? 'https://covers.openlibrary.org/b/id/$coverId-M.jpg'
        : 'https://via.placeholder.com/150';

    final firstPublishYear = work['first_publish_year'];
    final loggedDate = json['logged_date'];

    // Debug print
    //print('📘 Title: $title | 👤 Author: $author | 🕒 Logged: $loggedDate');
    if (kDebugMode) {
      debugPrint('📘 Title: $title | 👤 Author: $author | 🕒 Logged: $loggedDate');
    }

    return Book(
      title: title,
      author: author,
      imagePath: imagePath,
      firstPublishYear: firstPublishYear,
      loggedDate: loggedDate,
    );
  }
}




