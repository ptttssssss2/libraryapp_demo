import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:libraryapp/models/api_service.dart';
import 'package:libraryapp/models/book.dart';
import 'package:libraryapp/components/button.dart';
import 'package:libraryapp/theme/colors.dart';
import 'package:libraryapp/pages/book_details_page.dart';
import 'package:libraryapp/pages/search_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  List<Book> bookMenu = [];
  bool isLoading = true;
  User? currentUser;

  @override
  void initState() {
    super.initState();
    loadBooks();
    currentUser = FirebaseAuth.instance.currentUser;
  }

  void loadBooks() async {
    try {
      final books = await fetchWantToReadBooks();
      setState(() {
        bookMenu = books;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error loading books: $e");
    }
  }

  void navigateToBookDetails(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookDetailsPage(
          book: bookMenu[index],
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
            const Divider(),
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
              Navigator.pushNamed(context, '/cartpage');
            },
            icon: Icon(Icons.shopping_cart, color: Colors.grey[900]),
          )
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: primaryColor,
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
                      'Get 32% Promo',
                      style: GoogleFonts.dmSerifDisplay(
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    MyButton(
                      text: "Redeem",
                      onTap: () {},
                    )
                  ],
                ),
                Image.asset(
                  'asset/book2.png',
                  height: 100,
                )
              ],
            ),
          ),
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
          const SizedBox(height: 10),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: bookMenu.length,
                    itemBuilder: (context, index) {
                      final book = bookMenu[index];
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
                          ),
                          title: Text(book.title),
                          subtitle: Text("Author: ${book.author}"),
                          trailing: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.star, color: Colors.amber, size: 18),
                              Text("No rating"),
                            ],
                          ),
                          onTap: () => navigateToBookDetails(index),
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