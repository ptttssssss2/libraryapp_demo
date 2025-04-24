import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:libraryapp/pages/cart_page.dart';
import 'package:libraryapp/pages/home.dart';
import 'package:libraryapp/pages/login.dart';
import 'package:libraryapp/pages/menu_page.dart';
import 'package:libraryapp/models/rent.dart';
import 'package:libraryapp/pages/signup.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:libraryapp/models/api_service.dart';
import 'package:libraryapp/pages/history_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // โหลดและบันทึกหนังสือเมื่อเริ่มแอป
  try {
    final apiService = ApiService();
    await apiService.fetchWantToReadBooks();
  } catch (e) {
    debugPrint('Error loading books: $e');
  }

  runApp(
    ChangeNotifierProvider(
      create: (context) => Rent(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          
          if (snapshot.hasData) {
            return const MainNavigation();
          }
          
          return const LoginPage();
        },
      ),
      routes: {
        '/main': (context) => const MainNavigation(),
        '/home': (context) => const Home(),
        '/menupage': (context) => const MenuPage(),
        '/cartpage': (context) => const CartPage(),
        '/historypage': (context) => const HistoryPage(),
        '/loginpage': (context) => const LoginPage(),
        '/registerpage': (context) => const SignupPage(),
      },
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0; // ตัวแปรเก็บ index ของหน้าใน bottom navigation

  final List<Widget> _pages = [
    const MenuPage(),
    const Home(),
    const CartPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ใช้ PopScope เพื่อป้องกันไม่ให้ผู้ใช้กด back ออกไปจากหน้าโดยไม่ได้ตั้งใจ
      body: PopScope(
        canPop: false,
        child: _pages[_currentIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex, // กำหนด index ที่แสดงอยู่ปัจจุบัน
        onTap: (index) {
          setState(() {
          // เมื่อผู้ใช้กดที่ปุ่มในแถบด้านล่าง ให้เปลี่ยนหน้า
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book),
            label: 'Menu',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
        ],
      ),
    );
  }
}