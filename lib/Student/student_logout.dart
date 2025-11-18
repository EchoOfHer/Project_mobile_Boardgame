import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'student_main.dart' show url;
import '/login/login.dart';

// 💡 NEW: Logic การ Logout ที่สมบูรณ์แบบ
class AppLogout {
  static Future<void> logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();

    // ลบ Token / User Data
    await prefs.remove('token');
    await prefs.remove('user_id');
    await prefs.remove('username');
    await prefs.remove('role');

    // กลับไปหน้า Login และล้าง navigation stack
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const Login()),
      (route) => false,
    );
  }
}

class StudentLogout {
  static void show(BuildContext context) {
    const Color logoutColor = Color(0xFFFF7C7C);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.logout, size: 60, color: logoutColor),
              const SizedBox(height: 16),
              const Text(
                "Log Out",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: logoutColor,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Are you sure you want to log out of your account?",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300],
                      foregroundColor: Colors.black54,
                    ),
                    onPressed: () {
                      Navigator.pop(dialogContext); // ปิด Dialog
                      // หากเป็นการกด 'Cancel' ต้องกลับไปที่ Tab แรก (Index 0)
                      DefaultTabController.of(context).animateTo(0);
                    },
                    child: const Text("Cancel"),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: logoutColor,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () async {
                      // 1. ปิด Dialog ก่อน
                      Navigator.pop(dialogContext);

                      // 2. เรียก API Logout (ถ้าจำเป็น)
                      try {
                        // 🔹 ใช้ตัวแปร url ที่ Import มา (ซึ่งควรเป็น '10.0.2.2:3000')
                        final String apiUrl = 'http://$url/api/logout';

                        // Note: ไม่จำเป็นต้องรอผลตอบรับของ Logout API
                        await http.post(
                          Uri.parse(apiUrl),
                          headers: {'Content-Type': 'application/json'},
                        );
                      } catch (e) {
                        debugPrint(
                          'Logout API call failed, proceeding with local logout: $e',
                        );
                      }

                      // 3. 🔑 ล้างข้อมูลและนำทางไปหน้า Login โดยใช้ AppLogout
                      await AppLogout.logout(context);
                    },
                    child: const Text("Confirm"),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
