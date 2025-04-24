import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  final String text;
  final void Function()? onTap;
  //final double? width;
  final TextStyle? textStyle;
  const MyButton(
      {super.key, required this.text, required this.onTap,this.textStyle,}); //this.width});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 140, 150, 155),
          borderRadius: BorderRadius.circular(40),
        ),
        padding: EdgeInsets.all(20),
        child: Row(
          mainAxisSize: MainAxisSize.min, // 👈 ทำให้ขนาดพอดีกับเนื้อหา
          mainAxisAlignment: MainAxisAlignment.center, // 👈 กลางแนวนอน
          crossAxisAlignment: CrossAxisAlignment.center, // 👈 กลางแนวตั้ง
          children: [
            //text
            Text(
              text,
              style: TextStyle(color: Colors.white),
            ),
            const SizedBox(
              width: 10,
            ),

            //icon
            Icon(
              Icons.arrow_forward,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}