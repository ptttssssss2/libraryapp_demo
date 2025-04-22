import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:libraryapp/theme/colors.dart';
import 'package:libraryapp/components/button.dart';
import 'package:libraryapp/services/auth_service.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  bool _isSuccess = false;

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final result = await _authService.signup(
          email: _emailController.text.trim(),
          username: _usernameController.text.trim(),
          password: _passwordController.text.trim(),
        );

        if (result) {
          // Update displayName in Firebase Auth
          await FirebaseAuth.instance.currentUser?.updateProfile(
            displayName: _usernameController.text.trim(),
          );
          
          setState(() {
            _isSuccess = true;
          });
          
          Fluttertoast.showToast(
            msg: 'Signup successful! Redirecting...',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.green,
            textColor: Colors.white,
          );
          
          await Future.delayed(const Duration(milliseconds: 1500));
          
          if (!mounted) return;
          Navigator.pushReplacementNamed(context, '/home');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        if (!_isSuccess) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pushReplacementNamed(context, '/loginpage'),
        ),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
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
              const SizedBox(height: 20),
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
                "Sign Up",
                style: GoogleFonts.dmSerifDisplay(
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              // Email Field
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: TextFormField(
                  controller: _emailController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: "Email",
                    labelStyle: const TextStyle(color: Colors.white),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    hintText: "Enter your email",
                    hintStyle: const TextStyle(color: Colors.white70),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(color: Colors.white),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(color: Colors.white),
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 15),
              // Username Field
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: TextFormField(
                  controller: _usernameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: "Username",
                    labelStyle: const TextStyle(color: Colors.white),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    hintText: "Enter your username",
                    hintStyle: const TextStyle(color: Colors.white70),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(color: Colors.white),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(color: Colors.white),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your username';
                    }
                    if (value.length < 4) {
                      return 'Username must be at least 4 characters';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 15),
              // Password Field
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: TextFormField(
                  controller: _passwordController,
                  style: const TextStyle(color: Colors.white),
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "Password",
                    labelStyle: const TextStyle(color: Colors.white),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    hintText: "Enter your password",
                    hintStyle: const TextStyle(color: Colors.white70),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(color: Colors.white),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(color: Colors.white),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: _isLoading
                    ? Center(
                        child: Column(
                          children: [
                            const CircularProgressIndicator(color: Colors.white),
                            if (_isSuccess)
                              Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Text(
                                  "Signup Successful!",
                                  style: GoogleFonts.dmSerifDisplay(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      )
                    : MyButton(
                        text: "Sign Up",
                        onTap: _signUp,
                      ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}