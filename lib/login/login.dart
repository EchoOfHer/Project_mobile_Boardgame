import 'package:boardgame_app/Lender/lender_main.dart';
import 'package:flutter/material.dart';
import 'register.dart';
import 'package:boardgame_app/Student/student_main.dart';
import 'package:boardgame_app/Staff/staff_main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

final url = '10.0.2.2:3000'; // Local API

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscureText = true;
  bool _loading = false;

  void _togglePasswordVisibility() {
    setState(() => _obscureText = !_obscureText);
  }

  Future<void> _handleLogin() async {
  if (!_formKey.currentState!.validate()) return;

  setState(() => _loading = true);

  String username = _usernameController.text.trim();
  String password = _passwordController.text.trim();

  try {
    final response = await http.post(
      Uri.http(url, '/api/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'username': username, 'password': password}),
    );

    setState(() => _loading = false);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final String token = data['token'];
      final String role = data['role'];
      final int userId = data['user_id'];
      final String loggedInUsername = data['username'];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      await prefs.setString('role', role);
      await prefs.setString('username', loggedInUsername);
      await prefs.setInt('user_id', userId);

      // ตรวจสอบว่าบันทึกข้อมูลสำเร็จ
      print('Stored user_id: ${prefs.getInt('user_id')}');
      print('Stored role: ${prefs.getString('role')}');

      // Navigate based on role
      if (role == 'borrower') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const StudentMain()),
        );
      } else if (role == 'lender') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LenderMain()),
        );
      } else if (role == 'staff') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const StaffMain()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login successful, but unknown Role'),
            backgroundColor: Colors.blue,
          ),
        );
      }
    } else {
      String message = 'Login failed';
      try {
        final errorData = json.decode(response.body);
        message = errorData['message'] ?? message;
      } catch (_) {}

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  } catch (e) {
    setState(() => _loading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Cannot connect to server: $e'),
        backgroundColor: Colors.red,
      ),
    );
  }
}

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.1,
            vertical: screenHeight * 0.05,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'image/dice.png',
                  width: screenWidth * 0.25,
                  height: screenWidth * 0.25,
                ),
                SizedBox(height: screenHeight * 0.02),
                Text(
                  'LOGIN',
                  style: TextStyle(
                    fontSize: screenWidth * 0.07,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepOrange,
                  ),
                ),
                Text(
                  'TO BOARD GAME SS',
                  style: TextStyle(
                    fontSize: screenWidth * 0.03,
                    color: Colors.deepOrange.shade300,
                  ),
                ),
                SizedBox(height: screenHeight * 0.04),
                TextFormField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    hintText: 'username',
                    hintStyle: TextStyle(color: Colors.red.shade400),
                    contentPadding: EdgeInsets.symmetric(
                      vertical: screenHeight * 0.015,
                      horizontal: screenWidth * 0.05,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: BorderSide(
                        color: Colors.orange.shade200,
                        width: 1.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: const BorderSide(
                        color: Colors.deepOrange,
                        width: 2,
                      ),
                    ),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter your Username' : null,
                ),
                SizedBox(height: screenHeight * 0.015),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscureText,
                  decoration: InputDecoration(
                    hintText: 'password',
                    hintStyle: TextStyle(color: Colors.red.shade400),
                    contentPadding: EdgeInsets.symmetric(
                      vertical: screenHeight * 0.015,
                      horizontal: screenWidth * 0.05,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureText ? Icons.visibility : Icons.visibility_off,
                        color: Colors.red.shade400,
                      ),
                      onPressed: _togglePasswordVisibility,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: BorderSide(
                        color: Colors.orange.shade200,
                        width: 1.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: const BorderSide(
                        color: Colors.deepOrange,
                        width: 2,
                      ),
                    ),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter your Password' : null,
                ),
                SizedBox(height: screenHeight * 0.02),
                SizedBox(
                  width: double.infinity,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Register(),
                          ),
                        );
                      },
                      child: const Text(
                        'Register',
                        style: TextStyle(
                          color: Colors.deepOrange,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.03),
                SizedBox(
                  width: 130,
                  height: screenHeight * 0.06,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.deepOrange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        side: const BorderSide(
                          color: Colors.deepOrange,
                          width: 1.5,
                        ),
                      ),
                    ),
                    child: _loading
                        ? const CircularProgressIndicator()
                        : Text(
                            'LOGIN',
                            style: TextStyle(
                              fontSize: screenWidth * 0.04,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
