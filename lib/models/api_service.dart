import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:libraryapp/models/book.dart';

Future<List<Book>> fetchWantToReadBooks() async {
  final url = Uri.parse('https://openlibrary.org/people/mekBot/books/want-to-read.json');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final List books = data['reading_log_entries'];

    return books.map((entry) {
      return Book.fromJson(entry);  // แปลงข้อมูล JSON เป็น Book object
    }).toList();
  } else {
    throw Exception('Failed to load books');
  }
}

