import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:libraryapp/components/button.dart';
//import 'package:libraryapp/pages/menu_page.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 196, 162, 176),
      body: Center(
        // จัดให้อยู่กลางทั้งแนวตั้งและแนวนอน
        child: Column(
          
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly, // กลางแนวนอน
          children: [
            const SizedBox(height: 120),
            //shopname
            Text(
              "•´¯`•.  ｍａｇｏｒｔａ   .•`¯´•",
              style: GoogleFonts.dmSerifDisplay(fontSize: 28,
              color: Colors.white,
            ),
            ),
            const SizedBox(height: 2),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Image.asset(
                'asset/book-stack.png',
                width: 150,
                height: 150,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 10),
            //shopdetails
            Text(
              "Ｔｈｅ Ｉｎｃｒｅｄｉｂｌｉｌｉｔｙ ｏｆ  ｂｏｏｋｓ",
              style: GoogleFonts.dmSerifDisplay(fontSize: 20,
              color: Colors.white,
             ),
            ),
            const SizedBox(height: 10),
            //shopdescribe
            Text(
              "·.¸¸·´¯`·.¸¸.ஐ ...¤¸¸.·´¯`·.¸·.>>--» [[ ♫~*",
              style: GoogleFonts.dmSerifDisplay(fontSize: 10,
              color: Colors.white,
             ),
            ),
            //button
            const SizedBox(height: 30),
            Center(
            child: MyButton(text: "Get Started",
            onTap :(){
              //go to menu page
              Navigator.pushNamed(context, '/menupage');
            },
            ),
            ),
          ],
        ),
      ),
    );
  }
}
