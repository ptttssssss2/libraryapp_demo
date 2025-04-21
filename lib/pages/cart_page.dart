import 'package:flutter/material.dart';
import 'package:libraryapp/components/button.dart';
import 'package:libraryapp/models/book.dart';
import 'package:libraryapp/models/rent.dart';
import 'package:libraryapp/theme/colors.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  //remove from cart()
  void removeFromCart(Book book, BuildContext context) {
    //get access the rent
    final rent = context.read<Rent>();
    
    //remove from cart
    rent.removeFromCart(book);


  }

  @override
  Widget build(BuildContext context) {
    return Consumer<Rent>(
      builder: (context, value, child) => Scaffold(
        backgroundColor: Colors.grey[300],
        //value
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
        ),
        body: Column(
          children: [
            //Customer Cart

            Expanded(
              child: ListView.builder(
                itemCount: value.cart.length,
                itemBuilder: (context, index) {
                  //get book from cart
                  final Book book = value.cart[index];

                  //get book name
                  final String bookName = book.title;

                  //get book author
                  final String bookAuthor = book.author;

                  //return list title
                  return Container(
                    decoration: BoxDecoration(
                      color: secondaryColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    margin: const EdgeInsets.only(left: 20, top: 20, right: 20),
                    child: ListTile(
                      leading: Image.network(
                        book.imagePath,
                        width: 50,
                        height: 70,
                        fit: BoxFit.cover,
                      ),
                      title: Text(
                        bookName,
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(bookAuthor,
                          style: TextStyle(
                            color: Colors.grey[200],
                          )),
                      trailing: IconButton(
                          onPressed: () => removeFromCart(book, context), //remove
                          icon: Icon(
                            Icons.delete,
                            color: Colors.grey[300],
                          )),
                    ),
                  );
                },
              ),
            ),
            //Rent Button
            // child: MyButton(text: "Borrow Now", onTap: (){})
             
            Padding(
              padding: const EdgeInsets.all(25.0),
              child: SizedBox(   
                //Container(
                width: double.infinity,
                child: MyButton(
                  text: "Borrow Now",
                  onTap: () {
                    // logic เมื่อกด
                  },
                ),
              ),
            ),
//
          ],
        ),
      ),
    );
  }
}
