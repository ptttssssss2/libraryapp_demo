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
  late TextEditingController _controller;
  late List<Book> filteredBooks;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    filteredBooks = widget.book;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _filterBooks(String query) {
    setState(() {
      filteredBooks = widget.book.where((book) {
        return book.title.toLowerCase().contains(query.toLowerCase()) ||
            book.author.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Search Books",
          style: GoogleFonts.dmSerifDisplay(fontSize: 20),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 10),
            child: TextField(
              controller: _controller,
              onChanged: _filterBooks,
              decoration: InputDecoration(
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.white),
                  borderRadius: BorderRadius.circular(20),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.white),
                  borderRadius: BorderRadius.circular(20),
                ),
                hintText: "Search ..",
                prefixIcon: const Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: filteredBooks.isEmpty
                ? Center(
                    child: Text(
                      "No books found",
                      style: GoogleFonts.dmSerifDisplay(fontSize: 18),
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredBooks.length,
                    itemBuilder: (context, index) {
                      final book = filteredBooks[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 25, vertical: 5),
                        child: ListTile(
                          leading: Image.network(
                            book.imagePath,
                            width: 50,
                            height: 70,
                            fit: BoxFit.cover,
                          ),
                          title: Text(book.title),
                          subtitle: Text('Author: ${book.author}'),
                          onTap: () {
                            // สามารถเพิ่มการนำทางไปยังหน้าดูรายละเอียดหนังสือได้ที่นี่
                          },
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