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

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // โหลดและบันทึกหนังสือเมื่อเริ่มแอป
  try {
    await fetchWantToReadBooks();
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
            return WillPopScope(
              onWillPop: () async => false,
              child: const MainNavigation(),
            );
          }
          
          return const LoginPage();
        },
      ),
      routes: {
        '/main': (context) => WillPopScope(
              onWillPop: () async => false,
              child: const MainNavigation(),
            ),
        '/home': (context) => WillPopScope(
              onWillPop: () async => false,
              child: const Home(),
            ),
        '/menupage': (context) => WillPopScope(
              onWillPop: () async => false,
              child: const MenuPage(),
            ),
        '/cartpage': (context) => WillPopScope(
              onWillPop: () async => false,
              child: const CartPage(),
            ),
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
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const MenuPage(),
    const Home(),
    const CartPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WillPopScope(
        onWillPop: () async => false,
        child: _pages[_currentIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
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