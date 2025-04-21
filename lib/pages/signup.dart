import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:libraryapp/theme/colors.dart';
import 'package:libraryapp/components/button.dart';

class SignupPage extends StatelessWidget {
  const SignupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      //body: Center( // คอมเม้นต์ไว้ตามที่คุณต้องการ
      body: Stack(
        children: [
          // ใช้ Stack เพื่อควบคุมตำแหน่งลูกศร
          Positioned(
            top: 20, // ปรับระยะห่างจากด้านบนให้น้อยลง
            left: 10, // ปรับระยะห่างจากด้านซ้าย
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Navigator.pop(context); // กลับไปยังหน้าก่อนหน้า (login)
              },
            ),
          ),
          // เนื้อหาที่เหลือ
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const SizedBox(height: 40), // ปรับขนาดให้เหมาะสมหลังจากลูกศร
              Text(
                "Margorta",
                style: GoogleFonts.dmSerifDisplay(
                  fontSize: 40,
                  color: Colors.white,
                ),
              ),
              //const SizedBox(height: 2),
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
                "Signup",
                style: GoogleFonts.dmSerifDisplay(
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              // ฟอร์ม email
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: TextField(
                  decoration: InputDecoration(
                  labelText: "Email", // ← ตรงนี้จะทำให้มีข้อความ "username" อยู่ด้านบนช่อง
                  labelStyle: TextStyle(color: Colors.white),
                   floatingLabelBehavior: FloatingLabelBehavior.always, // ถ้าพื้นหลังเข้ม ใช้สีขาว
                    hintText: "Enter your email",
                    hintStyle: TextStyle(color: Colors.white),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: TextField(
                  decoration: InputDecoration(
                  labelText: "Username", // ← ตรงนี้จะทำให้มีข้อความ "username" อยู่ด้านบนช่อง
                  labelStyle: TextStyle(color: Colors.white),
                   floatingLabelBehavior: FloatingLabelBehavior.always,// ถ้าพื้นหลังเข้ม ใช้สีขาว
                    hintText: "Enter your username",
                    hintStyle: TextStyle(color: Colors.white),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                ),
              ),


              // ฟอร์ม password
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: TextField(
                  decoration: InputDecoration(
                  labelText: "Password", // ← ตรงนี้จะทำให้มีข้อความ "username" อยู่ด้านบนช่อง
                  labelStyle: TextStyle(color: Colors.white),
                    hintText: "password",
                    hintStyle: TextStyle(color: Colors.white),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                ),
              ),
              // ปุ่ม Signup
              const SizedBox(height: 30),
              Center(
                child: MyButton(
                  text: "signup",
                  onTap: () {
                    //go to menu page
                    //Navigator.pushNamed(context, '/login');
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
