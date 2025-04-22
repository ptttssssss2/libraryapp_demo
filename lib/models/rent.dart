import 'package:flutter/material.dart';
import 'package:libraryapp/models/book.dart';

class Rent extends ChangeNotifier {
  final Map<Book, int> _cartItems = {};

  // รับรายการหนังสือที่ไม่ซ้ำในตะกร้า
  List<Book> get cartBooks => _cartItems.keys.toList();

  // รับจำนวนหนังสือทั้งหมดในตะกร้า (รวมจำนวนแต่ละเล่ม)
  int get totalItems => _cartItems.values.fold(0, (sum, quantity) => sum + quantity);

  // รับจำนวนหนังสือที่ไม่ซ้ำในตะกร้า
  int get uniqueItemsCount => _cartItems.length;

  // เพิ่มหนังสือลงตะกร้า
  void addToCart(Book book, [int quantity = 1]) {
    if (_cartItems.containsKey(book)) {
      _cartItems[book] = _cartItems[book]! + quantity;
    } else {
      _cartItems[book] = quantity;
    }
    notifyListeners();
  }

  // ลบหนังสือออกจากตะกร้า (ลดจำนวนทีละ 1)
  void removeFromCart(Book book) {
    if (_cartItems.containsKey(book)) {
      if (_cartItems[book]! > 1) {
        _cartItems[book] = _cartItems[book]! - 1;
      } else {
        _cartItems.remove(book);
      }
      notifyListeners();
    }
  }

  // ลบหนังสือออกจากตะกร้าทั้งหมด (ไม่ว่าจะมีกี่เล่ม)
  void removeAllCopiesFromCart(Book book) {
    if (_cartItems.containsKey(book)) {
      _cartItems.remove(book);
      notifyListeners();
    }
  }

  // รับจำนวนของหนังสือเฉพาะเล่ม
  int getBookQuantity(Book book) {
    return _cartItems[book] ?? 0;
  }

  // ล้างตะกร้าทั้งหมด
  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }

  // รับรายการหนังสือทั้งหมดสำหรับการยืม (แปลง Map เป็น List โดยคงจำนวน)
  List<Book> getBooksForBorrowing() {
    return _cartItems.entries
        .expand((entry) => List.filled(entry.value, entry.key))
        .toList();
  }

  // ตรวจสอบว่าหนังสืออยู่ในตะกร้าหรือไม่
  bool isBookInCart(Book book) {
    return _cartItems.containsKey(book);
  }
}