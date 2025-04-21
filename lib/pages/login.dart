import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:libraryapp/theme/colors.dart';
import 'package:libraryapp/components/button.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      body: Center(
        // จัดให้อยู่กลางทั้งแนวตั้งและแนวนอน
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly, // กลางแนวนอน
          children: [
            const SizedBox(height: 120),
            //shopname
            Text(
              "Margorta",
              style: GoogleFonts.dmSerifDisplay(
                fontSize: 40,
                color: Colors.white,
              ),
            ),
            Text(
              "Library Book",
              style: GoogleFonts.dmSerifDisplay(
                fontSize: 20,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 2),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Image.asset(
                'asset/storytelling.png',
                width: 150,
                height: 150,
                fit: BoxFit.contain,
              ),
            ),

            Text(
              "Login",
              style: GoogleFonts.dmSerifDisplay(
                fontSize: 20,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 10),
            //username
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: TextField(
                // readOnly: true,
                //onTap: () {
                  //Navigator.push(
                  //context,
                //},
              
                decoration: InputDecoration(
                  labelText: "username", // ← ตรงนี้จะทำให้มีข้อความ "username" อยู่ด้านบนช่อง
                  labelStyle: TextStyle(color: Colors.white),
                  floatingLabelBehavior: FloatingLabelBehavior.always, // ถ้าพื้นหลังเข้ม ใช้สีขาว
                  hintText: "Enter Username",
                  hintStyle: TextStyle(color: Colors.white),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
              ),
            ),

            //password
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: TextField(
                readOnly: true,
                onTap: () {
                  //Navigator.push(
                  //context,
                },
                decoration: InputDecoration(
                  labelText: "Password", // ← ตรงนี้จะทำให้มีข้อความ "username" อยู่ด้านบนช่อง
                  labelStyle: TextStyle(color: Colors.white),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  hintText: "Enter Password",
                  hintStyle: TextStyle(color: Colors.white),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
              ),
            ),

            //button
            const SizedBox(height: 30),
            Center(
              child: MyButton(
                text: "login",
                onTap: () {
                  //go to menu page
                  Navigator.pushNamed(context, '/home');
                },
              ),
            ),

            //dont have an account sign up
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Don't have an account?",
                  style: TextStyle(color: Colors.white),
                ),
                const SizedBox(width: 5),
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(
                        context, '/registerpage'); // ไปหน้า Register
                  },
                  child: Text(
                    "Sign up",
                    style: TextStyle(
                      color: Colors.yellowAccent,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
            //
          ],
        ),
      ),
    );
  }
}
