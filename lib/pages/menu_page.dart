import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:libraryapp/models/api_service.dart';
import 'package:libraryapp/models/book.dart';
import 'package:libraryapp/components/button.dart';
import 'package:libraryapp/theme/colors.dart';
import 'package:libraryapp/pages/book_details_page.dart';
import 'package:libraryapp/pages/search_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:libraryapp/pages/history_page.dart';
import 'package:libraryapp/pages/delete_account_page.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  List<Book> bookMenu = [];
  List<Book> recommendedBooks = [];
  bool isLoading = true;
  User? currentUser;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    loadBooks();
    currentUser = FirebaseAuth.instance.currentUser;
  }

  void loadBooks() async {
    try {
      final books = await _apiService.fetchAllBooks();
      setState(() {
        bookMenu = books;
        isLoading = false;
        recommendedBooks = _getRecommendedBooksWithoutDuplicates(bookMenu);
      });
    } catch (e) {
      debugPrint("Error loading books: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load books: ${e.toString()}')),
      );
    }
  }

  // เมธอดที่เพิ่มเข้ามาเพื่อแก้ไข error
  void _navigateToBookDetails(Book book) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookDetailsPage(book: book),
      ),
    );
  }

  List<Book> _getRecommendedBooksWithoutDuplicates(List<Book> allBooks,
      {int count = 3}) {
    if (allBooks.isEmpty) return [];

    final availableBooks = allBooks
        .where((book) => !bookMenu.any((menuBook) => menuBook.id == book.id))
        .toList();

    final sourceBooks =
        availableBooks.length >= count ? availableBooks : allBooks;

    final shuffled = List<Book>.from(sourceBooks)..shuffle();
    return shuffled.take(count).toList();
  }

  void _refreshRecommendedBooks() {
    setState(() {
      recommendedBooks = _getRecommendedBooksWithoutDuplicates(bookMenu);
    });
  }

  void _showRecommendedBooks(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Recommended For You",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () {
                    _refreshRecommendedBooks(); //ดึง void บนมาใช้ _refreshRecommendedBooks
                    Navigator.pop(context);
                    _showRecommendedBooks(context);
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: recommendedBooks.isEmpty
                  ? Center(
                      child: Text(
                        'No new books to recommend',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    )
                  : ListView.builder(
                      itemCount: recommendedBooks.length,
                      itemBuilder: (context, index) {
                        final book = recommendedBooks[index];
                        return ListTile(
                          leading: Image.network(
                            book.imagePath,
                            width: 40,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.book, size: 40),
                          ),
                          title: Text(book.title),
                          subtitle: Text(book.author),
                          onTap: () {
                            Navigator.pop(context);
                            _navigateToBookDetails(book);
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacementNamed(context, '/loginpage');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Logout failed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: primaryColor,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Library Menu',
                    style: GoogleFonts.dmSerifDisplay(
                      fontSize: 24,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 10),
                  FutureBuilder<User?>(
                    future: FirebaseAuth.instance.authStateChanges().first,
                    builder: (context, snapshot) {
                      final user = snapshot.data ?? currentUser;
                      if (user != null) {
                        return Text(
                          'Hi ${user.displayName ?? user.email?.split('@')[0] ?? 'User'}',
                          style: GoogleFonts.dmSerifDisplay(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ],
              ),
            ),

            //แถบข้าง สามขีด
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/home');
              },
            ),

            ListTile(
              leading: const Icon(Icons.search),
              title: const Text('Search'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SearchPage(book: bookMenu),
                    // ส่งข้อมูล bookMenu ไปยัง SearchPage ผ่าน constructor
                  ),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.shopping_cart),
              title: const Text('Cart'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/cartpage');
              },
            ),
            ListTile(
              leading: const Icon(Icons.assignment_rounded),
              title: const Text('History'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/historypage');
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete Account',
                  style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const DeleteAccountPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout', style: TextStyle(color: Colors.red)),
              onTap: _logout,
            ),
          ],
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu, color: Colors.grey[900]),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Text(
          'Library Book',
          style: GoogleFonts.dmSerifDisplay(
            fontSize: 20,
            color: Colors.grey[900],
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/cartpage'); //ไปหน้าตะกร้า
            },
            icon: Icon(Icons.shopping_cart, color: Colors.grey[900]),
          )
        ],
      ),
      body: Column(
        //ตกแต่ง
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: primaryColor,
              image: const DecorationImage(
                image: AssetImage('asset/book3.jpg'),
                fit: BoxFit.cover,
                opacity: 0.4,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            margin: const EdgeInsets.symmetric(horizontal: 25),
            padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '────୨ৎ────',
                      style: GoogleFonts.dmSerifDisplay(
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                    

          


                    const SizedBox(height: 20), // แนะนำนส
                    MyButton(
                      text: "Recommended For You",
                      onTap: () {
                        if (bookMenu.isNotEmpty) {
                          _showRecommendedBooks(context); //จากด้านบน
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar( //popup
                            const SnackBar(content: Text('No books available')),
                          );
                        }
                      },
                        textStyle: GoogleFonts.dmSerifDisplay(
                          fontSize: 20,
                          color: Colors.white,
                        ),
              
                    )
                    
                  ],
                ),
              ],
            ),
          ),



        //search bar
          const SizedBox(height: 25),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: TextField(
              readOnly: true,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SearchPage(book: bookMenu),
                  ),
                );
              },
              decoration: InputDecoration(
                hintText: "Search ..",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(color: Colors.white),
                ),
              ),
            ),
          ),

          // Book Menu
          const SizedBox(height: 25),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Text(
              "Book Menu",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
                fontSize: 18,
              ),
            ),
          ),

          //book ด้านล่าง
          const SizedBox(height: 10),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : bookMenu.isEmpty
                    ? Center(
                        child: Text(
                          'No books available',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      )
                    : ListView.builder(
                        itemCount: bookMenu.length,
                        itemBuilder: (context, index) {
                          final book = bookMenu[index]; //book.dart
                          return Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 25, vertical: 10),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15)),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(15),
                              leading: Image.network(
                                book.imagePath,
                                width: 50,
                                height: 70,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.book, size: 50),
                              ),
                              title: Text(book.title),
                              subtitle: Text("Author: ${book.author}"),
                              trailing: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.star,
                                      color: Colors.amber, size: 18),
                                  Text("No rating"),
                                ],
                              ),
                              onTap: () => _navigateToBookDetails(book), //กดแล้วไป book_details
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
