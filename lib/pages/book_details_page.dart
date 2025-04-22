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
  int quantityCount = 0;

  void decrementQuantity() {
    setState(() {
      if (quantityCount > 0) {
        quantityCount--;
      }
    });
  }

  void incrementQuantity() {
    setState(() {
      if (quantityCount < 5) {
        quantityCount++;
      }
    });
  }

  Future<void> addToCart() async {
    if (quantityCount > 0) {
      final rent = context.read<Rent>();
      rent.addToCart(widget.book, quantityCount);

      // ตัวแปรเก็บผลลัพธ์จาก Dialog
      final shouldNavigateToCart = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          backgroundColor: primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            "Success!",
            style: GoogleFonts.dmSerifDisplay(
              fontSize: 24,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          content: Text(
            "${widget.book.title}\nhas been added to your cart",
            style: GoogleFonts.dmSerifDisplay(
              fontSize: 18,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            SizedBox(
              width: 120,
              child: MyButton(
                text: "Continue",
                onTap: () {
                  Navigator.pop(context, false); // ส่งค่า false กลับ
                },
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: 120,
              child: MyButton(
                text: "View Cart",
                onTap: () {
                  Navigator.pop(context, true); // ส่งค่า true กลับ
                },
              ),
            ),
          ],
        ),
      ) ?? false; // ค่าเริ่มต้นเป็น false ถ้า Dialog ถูกปิดด้วยวิธีอื่น

      // ถ้าผู้ใช้กด View Cart ให้ไปยังหน้าตะกร้า
      if (shouldNavigateToCart) {
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/cartpage');
      } else {
        // ถ้ากด Continue ให้ปิดหน้า details
        if (!mounted) return;
        Navigator.pop(context);
      }
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            "Oops!",
            style: GoogleFonts.dmSerifDisplay(),
          ),
          content: Text(
            "Please select quantity first",
            style: GoogleFonts.dmSerifDisplay(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
      );
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
                Center(
                  child: Image.network(
                    widget.book.imagePath,
                    height: 200,
                    errorBuilder: (context, error, stackTrace) => 
                      const Icon(Icons.broken_image, size: 100),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  widget.book.title,
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  'Author: ${widget.book.author}',
                  style: const TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.star, color: Colors.amber),
                    SizedBox(width: 5),
                    Text('No rating'),
                  ],
                ),
                const SizedBox(height: 20),
                if (widget.book.firstPublishYear != null)
                  Text(
                    'First Published : ${widget.book.firstPublishYear}',
                    style: GoogleFonts.dmSerifDisplay(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                const SizedBox(height: 20),
                if (widget.book.loggedDate != null)
                  Text(
                    'Imported : ${widget.book.loggedDate}',
                    style: GoogleFonts.dmSerifDisplay(
                        fontSize: 16, fontStyle: FontStyle.italic),
                    textAlign: TextAlign.center,
                  ),
              ],
            ),
          ),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
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
                        const SizedBox(width: 16),
                        Text(
                          quantityCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(width: 16),
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
                  ],
                ),
                const SizedBox(height: 16),
                MyButton(
                  text: "Add To Cart",
                  onTap: addToCart,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}