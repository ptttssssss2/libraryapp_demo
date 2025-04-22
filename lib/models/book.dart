import 'package:flutter/foundation.dart';

class Book {
  final String id;
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
    this.id = '',
    this.rating,
    this.firstPublishYear,
    this.loggedDate,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    final work = json['work'] ?? {};
    final title = work['title'] ?? 'No Title';
    final author = (json['author_names'] as List?)?.isNotEmpty == true
        ? json['author_names'][0]
        : work['author_names']?.join(', ') ?? 'Unknown Author';

    final coverId = work['cover_id']?.toString();
    final imagePath = coverId != null
        ? 'https://covers.openlibrary.org/b/id/$coverId-M.jpg'
        : 'https://via.placeholder.com/150';

    if (kDebugMode) {
      debugPrint('📘 Title: $title | 👤 Author: $author');
    }

    return Book(
      id: work['id'] ?? title.hashCode.toString(),
      title: title,
      author: author,
      imagePath: imagePath,
      firstPublishYear: work['first_publish_year'],
      loggedDate: json['logged_date'],
    );
  }
}