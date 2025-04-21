import 'package:flutter/material.dart';
import 'package:libraryapp/pages/cart_page.dart';
import 'package:libraryapp/pages/home.dart';
import 'package:libraryapp/pages/login.dart';
import 'package:libraryapp/pages/menu_page.dart';
import 'package:libraryapp/models/rent.dart';
import 'package:libraryapp/pages/signup.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';


Future<void>
 main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
);
  runApp(
    ChangeNotifierProvider(
      create: (context) => Rent(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const LoginPage(),
      routes:{
        '/home': (context) => const Home(),
        '/menupage':(context) => const MenuPage(),
        '/cartpage':(context) => const CartPage(),
        '/loginpage':(context) => const LoginPage(),
        '/registerpage':(context) => const SignupPage(),
      }
    );
  }
}
  