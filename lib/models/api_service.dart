import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:libraryapp/models/book.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<List<Book>> fetchWantToReadBooks() async {
  final url = Uri.parse('https://openlibrary.org/people/mekBot/books/want-to-read.json');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final List books = data['reading_log_entries'];

    // บันทึกลง Firestore
    await _saveBooksToFirestore(books.map((b) => Book.fromJson(b)).toList());

    return books.map((entry) => Book.fromJson(entry)).toList();
  } else {
    throw Exception('Failed to load books');
  }
}

Future<void> _saveBooksToFirestore(List<Book> books) async {
  final batch = FirebaseFirestore.instance.batch();
  
  for (final book in books) {
    final bookRef = FirebaseFirestore.instance.collection('books').doc(book.id);
    batch.set(bookRef, {
      'id': book.id,
      'title': book.title,
      'author': book.author,
      'coverUrl': book.imagePath,
      'availableCopies': 10,
      'totalCopies': 10,
    }, SetOptions(merge: true));
  }

  await batch.commit();
}