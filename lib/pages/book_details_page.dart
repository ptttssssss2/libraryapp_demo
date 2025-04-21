import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:libraryapp/components/button.dart';
import 'package:libraryapp/models/book.dart';
import 'package:libraryapp/models/rent.dart';
import 'package:libraryapp/theme/colors.dart';
import 'package:provider/provider.dart';

class BookDetailsPage extends StatefulWidget {
  final Book book;

  const BookDetailsPage({super.key, required this.book});

  @override
  State<BookDetailsPage> createState() => _BookDetailsPageState();
}

class _BookDetailsPageState extends State<BookDetailsPage> {
  //quantity
  int quantityCount = 0;

  //decrement quantity
  void decrementQuantity() {
    setState(() {
      if (quantityCount > 0) {
        quantityCount--;
      }
    });
  }

  //increment quantity
  void incrementQuantity() {
    setState(() {
      if (quantityCount < 5) {
        quantityCount++;
      }
    });
  }

  //add cart use if เพิ่มเข้าตะกร้าตามเงื่อนไข
  void addToCart() {
    //only add when Its there
    if (quantityCount > 0) {

      //access to rent
      final rent = context.read<Rent>();

      //add to cart
      rent.addToCart(widget.book, quantityCount);


      //let the user know it was success
      showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: primaryColor,
      builder: (context) => AlertDialog(
        content : Text("Succesfully Added", 
        style:  GoogleFonts.dmSerifDisplay(
        fontSize: 20, color: Colors.white),
        textAlign: TextAlign.center,
        ),
        actions: [
            IconButton(
              onPressed: () {
                Navigator.pop(context);

                Navigator.pop(context);
              },
              icon: Icon(Icons.done),
            ),
          ],
      ));
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.book.title),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // รูปปกหนังสือ
                Center(
                  child: Image.network(
                    widget.book.imagePath,
                    height: 200,
                  ),
                ),
                const SizedBox(height: 20),

                // ชื่อหนังสือ
                Text(
                  widget.book.title,
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 10),

                // ชื่อผู้แต่ง
                Text(
                  'Author: ${widget.book.author}',
                  style: const TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 10),

                // Rating
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.star, color: Colors.amber),
                    SizedBox(width: 5),
                    Text('No rating'),
                  ],
                ),

                const SizedBox(height: 20),
                // ปีที่พิมพ์ครั้งแรก
                if (widget.book.firstPublishYear != null)
                  Text(
                    'First Published : ${widget.book.firstPublishYear}',
                    style: GoogleFonts.dmSerifDisplay(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),

                const SizedBox(height: 20),

                // วันที่เพิ่มเข้ารายการ
                if (widget.book.loggedDate != null)
                  Text(
                    'Imported : ${widget.book.loggedDate}',
                    style: GoogleFonts.dmSerifDisplay(
                        fontSize: 16, fontStyle: FontStyle.italic),
                    textAlign: TextAlign.center,
                  ),
                //
              ],
            ),
          ),
          //

          //price , quantity , add to cart button
          Container(
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: primaryColor,
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    //Price
                    /*Text(
                      "\฿" + widget.book.,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),*/

                    //quantity
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end, //ชิดขวาจ้า
                      children: [
                        //minus button
                        Container(
                          decoration: BoxDecoration(
                            color: secondaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.remove,
                              color: Colors.white,
                            ),
                            onPressed: decrementQuantity,
                          ),
                        ),

                        SizedBox(width: 16),

                        //quantity count
                        Text(
                          quantityCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),

                        SizedBox(width: 16),

                        //plus button
                        Container(
                          decoration: BoxDecoration(
                            color: secondaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.add,
                              color: Colors.white,
                            ),
                            onPressed: incrementQuantity,
                          ),
                        ),
                      ],
                    ),
                    //
                    const SizedBox(height: 16),
                    //add cart
                    MyButton(
                      text: "Add To Cart",
                      onTap: () {
                        addToCart();
                      },
                      //width: 120,
                    ),
                  ],
                ),
              ],
            ),
          )

          //
        ],
      ),
    );
  }
}
