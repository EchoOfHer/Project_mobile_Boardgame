import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
final url = '10.0.2.2:3000';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _obscureText = true;
  bool _obscureConfirmText = true;
  bool _isLoading = false; // New state for loading indicator

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() => _obscureText = !_obscureText);
  }

  void _toggleConfirmPasswordVisibility() {
    setState(() => _obscureConfirmText = !_obscureConfirmText);
  }

  // Extracted input decoration method for cleaner code
  InputDecoration _buildInputDecoration({
    required String hintText,
    Widget? suffixIcon,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(color: Colors.red.shade400),
      suffixIcon: suffixIcon,
      contentPadding: EdgeInsets.symmetric(
        vertical: screenHeight * 0.015,
        horizontal: screenWidth * 0.05,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide(
          color: Colors.orange.shade200,
          width: 1.5,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: const BorderSide(
          color: Colors.deepOrange,
          width: 2,
        ),
      ),
    );
  }

  void _handleRegister() async {
  if (_formKey.currentState!.validate()) {
    setState(() => _isLoading = true);

    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:3000/api/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'username': username, 'password': password}),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 201) {
        // รับ token และข้อมูล user
        final token = responseData['token'];
        final userId = responseData['user_id'];
        final role = responseData['role'];
        final landingPage = responseData['landingPage'];

        // เก็บ JWT และข้อมูลลง SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', token);
        await prefs.setString('user_id', userId.toString());
        await prefs.setString('username', username);
        await prefs.setString('role', role);
        await prefs.setBool('isLoggedIn', true);

        // แสดงความสำเร็จ
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('ลงทะเบียนสำเร็จ! ยินดีต้อนรับ $username 🎉'),
            backgroundColor: Colors.green,
          ),
        );

        // ไปหน้าหลักของ Student ทันที (เหมือน login)
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/student-main', // หรือชื่อ route ที่คุณตั้งไว้
          (route) => false,
        );

      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(responseData['message'] ?? 'เกิดข้อผิดพลาด'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('ไม่สามารถเชื่อมต่อเซิร์ฟเวอร์ได้'),
          backgroundColor: Colors.red.shade900,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        // Use a transparent app bar to keep the white background uniform
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.deepOrange),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Dice Image
                Image.asset(
                  'image/dice.png',
                  width: screenWidth * 0.25,
                  height: screenWidth * 0.25,
                ),
                SizedBox(height: screenHeight * 0.02),
                Text(
                  'REGISTER',
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

                // Username Field
                TextFormField(
                  controller: _usernameController,
                  decoration: _buildInputDecoration(
                    hintText: 'username',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'กรุณากรอก username';
                    }
                    return null;
                  },
                ),
                SizedBox(height: screenHeight * 0.015),

                // Password Field
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscureText,
                  decoration: _buildInputDecoration(
                    hintText: 'password',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureText ? Icons.visibility : Icons.visibility_off,
                        color: Colors.red.shade400,
                        size: screenWidth * 0.05,
                      ),
                      onPressed: _togglePasswordVisibility,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'กรุณากรอกรหัสผ่าน';
                    } else if (value.length < 6) {
                      return 'รหัสผ่านต้องมีความยาวอย่างน้อย 6 ตัวอักษร';
                    }
                    return null;
                  },
                ),
                SizedBox(height: screenHeight * 0.015),

                // Confirm Password Field
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmText,
                  decoration: _buildInputDecoration(
                    hintText: 'confirm password',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmText
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Colors.red.shade400,
                        size: screenWidth * 0.05,
                      ),
                      onPressed: _toggleConfirmPasswordVisibility,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'กรุณายืนยันรหัสผ่าน';
                    } else if (value != _passwordController.text) {
                      return 'รหัสผ่านไม่ตรงกัน';
                    }
                    return null;
                  },
                ),
                SizedBox(height: screenHeight * 0.02),

                // Login Button Link
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'Login',
                      style: TextStyle(
                        color: Colors.deepOrange,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.03),

                // REGISTER Button
                SizedBox(
                  width: 130,
                  height: screenHeight * 0.06,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleRegister, // Disable button while loading
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.deepOrange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                        side: BorderSide(
                          color: _isLoading ? Colors.grey : Colors.deepOrange, // Change border color when disabled
                          width: 1.5,
                        ),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.deepOrange,
                              strokeWidth: 2.5,
                            ),
                          )
                        : Text(
                            'REGISTER',
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
