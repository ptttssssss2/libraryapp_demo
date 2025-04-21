import 'package:flutter/material.dart';
import 'book.dart';

class Rent extends ChangeNotifier {
  final List<Book> _books = []; // เมนูหนังสือทั้งหมด  เพิ่ม final
  final List<Book> _cart = [];
 // List<Book> bookMenu = []; ....

  // Getter methods
  List<Book> get books => _books;
  List<Book> get cart => _cart;

  // ฟังก์ชันสำหรับเพิ่มหนังสือในเมนู
  //void addBook(Book book) {
  // _books.add(book);
  //}

  // add to cart
  void addToCart(Book books, int quantity) {
    for(int i=0; i<quantity; i++){
      _cart.add(books);
    }
    notifyListeners();
  }

  //remove from cart
  void removeFromCart(Book books){
    _cart.remove(books);
    notifyListeners();
  }
}
