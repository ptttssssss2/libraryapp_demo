import 'package:flutter/material.dart';
import 'package:libraryapp/components/button.dart';
import 'package:libraryapp/models/book.dart';
import 'package:libraryapp/models/rent.dart';
import 'package:libraryapp/pages/menu_page.dart';
import 'package:libraryapp/theme/colors.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  void removeFromCart(Book book, BuildContext context) {
    final rent = context.read<Rent>();
    rent.removeFromCart(book);
  }

  Future<void> _borrowBooks(Rent rent, BuildContext context) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please login first')),
        );
        return;
      }

      final books = rent.getBooksForBorrowing();
      final batch = FirebaseFirestore.instance.batch();
      final now = DateTime.now();
      final returnDate = now.add(const Duration(days: 14));

      for (final book in books) {
        final docRef = FirebaseFirestore.instance.collection('borrowed_books').doc();
        
        batch.set(docRef, {
          'userId': user.uid,
          'bookId': book.id ?? book.title.hashCode.toString(),
          'bookTitle': book.title,
          'author': book.author,
          'imagePath': book.imagePath,
          'borrowDate': Timestamp.fromDate(now),
          'returnDate': Timestamp.fromDate(returnDate),
          'status': 'borrowed',
        });
      }

      final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
      batch.update(userRef, {
        'borrowedBooks': FieldValue.arrayUnion(
          books.map((b) => b.id ?? b.title.hashCode.toString()).toList()
        ),
      });

      await batch.commit();
      rent.clearCart();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Books borrowed successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<Rent>(
      builder: (context, rent, child) => Scaffold(
        backgroundColor: Colors.grey[300],
        appBar: AppBar(
          title: Text(
            "My Cart",
            style: GoogleFonts.dmSerifDisplay(
              fontSize: 22,
              color: Colors.black,
            ),
          ),
          elevation: 0,
          backgroundColor: primaryColor,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            color: Colors.black,
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const MenuPage()),
              );
            },
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: rent.cartBooks.isEmpty
                  ? Center(
                      child: Text(
                        'Your cart is empty',
                        style: GoogleFonts.dmSerifDisplay(
                          fontSize: 18,
                          color: Colors.grey[700],
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: rent.cartBooks.length,
                      itemBuilder: (context, index) {
                        final book = rent.cartBooks[index];
                        final quantity = rent.getBookQuantity(book);
                        return Container(
                          decoration: BoxDecoration(
                            color: secondaryColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          margin: const EdgeInsets.only(left: 20, top: 10, right: 20),
                          child: ListTile(
                            leading: Stack(
                              children: [
                                Image.network(
                                  book.imagePath,
                                  width: 50,
                                  height: 70,
                                  fit: BoxFit.cover,
                                ),
                                if (quantity > 1)
                                  Positioned(
                                    right: 0,
                                    bottom: 0,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Text(
                                        quantity.toString(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            title: Text(
                              book.title,
                              style: const TextStyle(
                                color: Colors.white, 
                                fontWeight: FontWeight.bold
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  book.author,
                                  style: TextStyle(
                                    color: Colors.grey[200],
                                  ),
                                ),
                                Text(
                                  'Quantity: $quantity',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                            trailing: IconButton(
                              onPressed: () => removeFromCart(book, context),
                              icon: Icon(
                                Icons.delete,
                                color: Colors.grey[300],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
            
            if (rent.cartBooks.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(25.0),
                child: Column(
                  children: [
                    Text(
                      'Total Items: ${rent.totalItems}',
                      style: GoogleFonts.dmSerifDisplay(
                        fontSize: 18,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: MyButton(
                        text: "Borrow Now",
                        onTap: () => _borrowBooks(rent, context),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}