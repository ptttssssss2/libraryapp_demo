import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:libraryapp/models/book.dart';

class SearchPage extends StatefulWidget {
  final List<Book> book;

  const SearchPage({super.key, required this.book});

  @override
  SearchPageState createState() => SearchPageState();
}

class SearchPageState extends State<SearchPage> {
  final TextEditingController _controller = TextEditingController();

  late List<Book> bookMenu;
  late List<Book> filteredBooks;

  @override
  void initState() {
    super.initState();
    bookMenu = widget.book; // MenuPage
    filteredBooks = bookMenu;
  }

  //find filter
  void _filterBooks(String query) {
    final filtered = bookMenu.where((book) {
      return book.title.toLowerCase().contains(query.toLowerCase()) ||
          book.author.toLowerCase().contains(query.toLowerCase());
    }).toList();

    setState(() {
      filteredBooks = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Search Books", 
      style: GoogleFonts.dmSerifDisplay(fontSize: 20,))),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 10),
            child: TextField(
              controller: _controller,
              onChanged: _filterBooks,
              decoration: InputDecoration(
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                  borderRadius: BorderRadius.circular(20),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                  borderRadius: BorderRadius.circular(20),
                ),
                hintText: "Search ..",
              ),
            ),
          ),

          // Display filtered books
          Expanded(
            child: ListView.builder(
              itemCount: filteredBooks.length,
              itemBuilder: (context, index) {
                final book = filteredBooks[index];
                return ListTile(
                  leading: Image.network(book.imagePath, width: 50, height: 70, fit: BoxFit.cover),
                  title: Text(book.title),
                  subtitle: Text('Author: ${book.author}'),
                );
              },
            ),
          ),
        ],
      ),
      );
  }
}
