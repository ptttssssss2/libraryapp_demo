import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:libraryapp/components/button.dart';
import 'package:libraryapp/theme/colors.dart'; // Make sure to import your primaryColor

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: primaryColor,
          image: DecorationImage(
            image: const AssetImage('asset/bookshelf2.jpg'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              primaryColor.withOpacity(0.7), // ปรับความโปร่งใสของสีที่ซ้อนทับ
              BlendMode.softLight,
            ),
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [


                const SizedBox(height: 40),
                // Welcome text
                Text(
                  "Welcome!",
                  style: GoogleFonts.dmSerifDisplay(
                    fontSize: 28,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        blurRadius: 10,
                        color: Colors.black.withOpacity(0.5),
                        offset: const Offset(2, 2),
                      ),
                    ],
                  ),
                ),


                const SizedBox(height: 30),
                // Book stack image with transparent container
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1), // Slightly transparent container
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Image.asset(
                    'asset/cook-book.png',
                    width: 150,
                    height: 150,
                    fit: BoxFit.contain,
                  ),
                ),



                const SizedBox(height: 30),
                // Decorative text
                Text(
                  "·.¸¸·´¯`·.¸¸.ஐ ...¤¸¸.·´¯`·.¸·.>>--» [[ ♫~*",
                  style: GoogleFonts.dmSerifDisplay(
                    fontSize: 15,
                    color: Colors.white,
                  ),
                ),


                const SizedBox(height: 40),
                // Get Started button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: MyButton( //จาก button.dart
                    text: "Get Started", //require text
                    onTap: () { //กดไปเมนู
                      Navigator.pushNamed(context, '/menupage'); //require onTap
                    },
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}