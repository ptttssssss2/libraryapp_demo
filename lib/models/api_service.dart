import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:libraryapp/models/book.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class ApiService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ดึงหนังสือจาก OpenLibrary API
  Future<List<Book>> fetchWantToReadBooks() async {
    try {
      final url = Uri.parse('https://openlibrary.org/people/mekBot/books/want-to-read.json');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List books = data['reading_log_entries'] ?? [];
        return books.map((entry) => Book.fromJson(entry)).toList();
      } else {
        throw Exception('Failed to load books: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('API Error: $e');
      return [];
    }
  }

  // ดึงหนังสือทั้งหมดจาก Firestore
  Future<List<Book>> fetchAllBooks() async {
  try {
    final snapshot = await _firestore.collection('books').get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return Book(
        id: doc.id, // ใช้ doc.id เป็นหลักเพื่อความสม่ำเสมอ
        title: data['title'] ?? 'No Title',
        author: data['author'] ?? 'Unknown Author',
        imagePath: data['coverUrl'] ?? 'https://via.placeholder.com/150',
      );
    }).toList();
  } catch (e) {
    debugPrint('Error fetching books: $e');
    return [];
  }
}

  // บันทึกหนังสือยืมลง Firestore
  Future<void> saveBooksToFirestore(List<Book> books) async {
    try {
      final batch = _firestore.batch();
      
      for (final book in books) {
        final docRef = _firestore.collection('books').doc(book.id);
        batch.set(docRef, {
          'id': book.id,
          'title': book.title,
          'author': book.author,
          'coverUrl': book.imagePath,
          'availableCopies': 10,
          'totalCopies': 10,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
      
      await batch.commit();
    } catch (e) {
      debugPrint('Firestore Save Error: $e');
      rethrow;
    }
  }
}