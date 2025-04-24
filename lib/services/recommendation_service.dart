import 'package:libraryapp/models/book.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RecommendationService {
  static Future<List<Book>> getPopularBooks() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('books') // Firestore ที่ collection ชื่อว่า 'books'
        .orderBy('borrowCount', descending: true) //มากไปน้อย
        .limit(3)
        .get();

    return snapshot.docs.map((doc) => Book.fromJson(doc.data())).toList();
  }
}