  import 'package:flutter/material.dart';
  import 'package:shared_preferences/shared_preferences.dart';
  import '/login/login.dart';

  class AppLogout {
    static Future<void> logout(BuildContext context) async {
      final prefs = await SharedPreferences.getInstance();

      // ลบ Token / User Data
      await prefs.remove('token');
      await prefs.remove('user_id');
      await prefs.remove('username');
      await prefs.remove('role');

      // หรือใช้ clear() ถ้าต้องการล้างทุกค่า
      // await prefs.clear();

      // กลับไปหน้า Login และล้าง navigation stack
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const Login()),
        (route) => false,
      );
    }
  }
