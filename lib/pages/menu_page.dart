import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:libraryapp/models/api_service.dart';
import 'package:libraryapp/models/book.dart';
import 'package:libraryapp/components/button.dart';
//import 'package:libraryapp/models/rent.dart';
import 'package:libraryapp/theme/colors.dart';
import 'package:libraryapp/pages/book_details_page.dart';
import 'package:libraryapp/pages/search_page.dart';
//import 'package:provider/provider.dart';
//import 'package:flutter/foundation.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  List<Book> bookMenu = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadBooks();
  }

//fetchapi
  void loadBooks() async {
    try {
      final books = await fetchWantToReadBooks();
      setState(() {
        bookMenu = books;
        isLoading = false;
      });
    } catch (e) {
      //print("Error loading books: $e");
      //if (kDebugMode) {
      //debugPrint("Error loading books: $e");
    //}
    }
  }

//navigatebook
  void navigateToBookDetails(int index) {

    //get the rent& menu ปิดแล้วรันได้ dialog
    //final rent = context.read<Rent>();
    //final bookMenu = rent.books;


    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookDetailsPage(
          book: bookMenu[index],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    //get the rent & menu ปิดแล้วรันได้ dialog
    //final rent = context.read<Rent>();
    //final bookMenu = rent.books;

    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Icon(
          Icons.menu,
          color: Colors.grey[900],
        ),
        title: Text(
          'Library Book',
          style:  GoogleFonts.dmSerifDisplay(
          fontSize: 20,
         color : Colors.grey[900]),
        ),
        //cart button
        actions: [
        IconButton(onPressed: (){
          Navigator.pushNamed(context, '/cartpage'); //to cart page
        },
        icon: Icon(Icons.shopping_cart,
        color: Colors.grey[900],),
        )]
      ),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //promo banner
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
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    //promo message
                    Text(
                      'Get 32% Promo',
                      style: GoogleFonts.dmSerifDisplay(
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),

                    //redeem button
                    MyButton(
                      text: "Redeem",
                      onTap: () {},
                    )
                  ],
                ),

                //image
                Image.asset(
                  'asset/book2.png',
                  height: 100,
                )
              ],
            ),
          ),

          const SizedBox(height: 25),

          
          //search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: TextField(
              readOnly: true,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SearchPage(book: bookMenu)),
                );
              },
              decoration: InputDecoration(
                hintText: "Search ..",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
            ),
          ),
          /*Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: TextField(
                decoration: InputDecoration(
              focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                  borderRadius: BorderRadius.circular(20)),
              enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                  borderRadius: BorderRadius.circular(20)
                ),
                hintText: "Search .." 
            ),
          ),
          ),*/


          const SizedBox(height: 25),

          //menu list
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Text("Book Menu",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                  fontSize: 18,
                )),
          ),

          const SizedBox(
            height: 10,
          ),
          //api
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
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
                          leading: Image.network(book.imagePath,
                              width: 50, height: 70, fit: BoxFit.cover),
                          title: Text(book.title), // ใช้ title แทน name
                          subtitle: Text(
                              "Author: ${book.author}"), // ใช้ author แทน price
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // ถ้าไม่มี rating ก็ไม่ต้องแสดง หรือใส่ค่าคงที่
                              Icon(Icons.star, color: Colors.amber, size: 18),
                              Text("No rating"), // ถ้าไม่มี rating ใน API
                            ],
                          ),
                          onTap: () =>
                              navigateToBookDetails(index), // ✅ แบบนี้ถูกต้อง
                        ),
                      );
                    },
                  ),
          ),
          //
        ],
      ),
    );
  }
}
