import 'package:boardgame_app/Lender/lender_main.dart';
import 'package:flutter/material.dart';
import 'register.dart';
import 'package:boardgame_app/Student/student_main.dart';
import 'package:boardgame_app/Lender/lender_browse_list.dart';
import 'package:boardgame_app/Staff/staff_main.dart';


final url = '10.0.0.2:3000';

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

  void _togglePasswordVisibility() {
    setState(() => _obscureText = !_obscureText);
  }

  // ⬇️⬇️⬇️ นี่คือส่วนที่แก้ไขตามที่คุณขอ ⬇️⬇️⬇️
  void _handleLogin() {
    // 1. ตรวจสอบว่ากรอกข้อมูลครบ (validate)
    if (_formKey.currentState!.validate()) {
      // 2. ดึงค่า username และ password จาก controller
      String username = _usernameController.text;
      String password = _passwordController.text;

      

      if (username == "student" && password == "123456") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const StudentMain()),
        );
      } else if (username == "lender" && password == "123456") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LenderMain()),
        );
      } else if (username == "staff" && password == "123456") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const StaffMain()),
        );
      } else {
        // --- ล็อกอินไม่สำเร็จ ---
        // แสดง SnackBar แจ้งเตือน
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Username หรือ Password ไม่ถูกต้อง'),
            backgroundColor: Colors.red, // สีพื้นหลังแจ้งเตือน
          ),
        );
      }
    }
  }
  // ⬆️⬆️⬆️ จบส่วนที่แก้ไข ⬆️⬆️⬆️

  // ⬇️⬇️⬇️ เพิ่มส่วนนี้เพื่อคืน Memory เมื่อปิดหน้า ⬇️⬇️⬇️
  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
  // ⬆️⬆️⬆️ จบส่วนที่เพิ่ม ⬆️⬆️⬆️

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.1, // ปรับความกว้างขอบตามจอ
            vertical: screenHeight * 0.05,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'image/dice.png',
                  width: screenWidth * 0.2, // ปรับภาพให้สัมพันธ์กับจอ
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

                // Username field
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

                // Password field
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
                        size: screenWidth * 0.05,
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
                        padding:
                            EdgeInsets.zero, // เอา padding ออกเพื่อให้ดูเนียน
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
                    onPressed:
                        _handleLogin, // <--- เรียกใช้ฟังก์ชันที่แก้ไขแล้ว
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
                    child: Text(
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
