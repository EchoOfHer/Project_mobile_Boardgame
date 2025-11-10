import 'package:flutter/material.dart';
import 'package:boardgame_app/Lender/lender_main.dart';
import 'package:boardgame_app/Student/student_main.dart';
import 'package:boardgame_app/Staff/staff_main.dart';
import 'package:boardgame_app/login/register.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const String baseUrl = '10.0.2.2:3000'; // สำหรับ Emulator เท่านั้น

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

    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    try {
      final uri = Uri.parse('http://10.0.2.2:3000/api/login');
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      setState(() => _loading = false);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', data['token'] ?? '');
        await prefs.setString('role', data['role'] ?? '');
        await prefs.setInt('user_id', data['user_id'] ?? 0);
        await prefs.setString('username', data['username'] ?? '');

        // เลือกหน้า Main ตาม role
        Widget nextPage;
        switch (data['role']) {
          case 'borrower':
            nextPage = const StudentMain();
            break;
          case 'lender':
            nextPage = const LenderMain();
            break;
          case 'staff':
            nextPage = const StaffMain();
            break;
          default:
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Unknown role.')));
            return;
        }

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => nextPage),
        );
      } else {
        final body = jsonDecode(response.body);
        final message = body['message'] ?? 'Login failed';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cannot connect to server.\n$e'),
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
                _buildTextField(
                  controller: _usernameController,
                  hint: 'Username',
                  validatorMsg: 'Please enter your Username',
                ),
                SizedBox(height: screenHeight * 0.015),
                _buildTextField(
                  controller: _passwordController,
                  hint: 'Password',
                  icon: _obscureText ? Icons.visibility : Icons.visibility_off,
                  isPassword: true,
                  validatorMsg: 'Please enter your Password',
                  onIconTap: _togglePasswordVisibility,
                ),
                SizedBox(height: screenHeight * 0.02),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const Register()),
                      );
                    },
                    child: const Text(
                      'Register',
                      style: TextStyle(
                        color: Colors.deepOrange,
                        fontWeight: FontWeight.w600,
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
                        side: const BorderSide(color: Colors.deepOrange),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    IconData? icon,
    required String validatorMsg,
    bool isPassword = false,
    VoidCallback? onIconTap,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword && _obscureText,
      decoration: InputDecoration(
        hintText: hint,
        // *** ADDED contentPadding to increase left space ***
        contentPadding: const EdgeInsets.fromLTRB(25.0, 15.0, 20.0, 15.0),

        prefixIcon: null,
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(icon, color: Colors.deepOrange),
                onPressed: onIconTap,
              )
            : null,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: BorderSide(color: Colors.orange.shade200),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(30.0)),
          borderSide: BorderSide(color: Colors.deepOrange, width: 2),
        ),
      ),
      validator: (value) =>
          value == null || value.isEmpty ? validatorMsg : null,
    );
  }
}
