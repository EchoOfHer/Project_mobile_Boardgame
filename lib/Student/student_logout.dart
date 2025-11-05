import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart'; // 🔑 NEW: Import SharedPreferences
import 'student_main.dart' show url;
import '/login/login.dart';

class StudentLogout {
  static void show(BuildContext context) {
    const Color logoutColor = Color(0xFFFF7C7C);

    showDialog(
      context: context,
      barrierDismissible: false, // ป้องกันการกดนอกกรอบแล้วปิด
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
                      Navigator.pop(dialogContext);

                      try {
                        const String apiUrl =
                            'http://localhost:3000/api/logout';

                        // 🔹 ตัวอย่างการเรียก API logout (ไม่จำเป็นต้องรอผล)
                        await http.post(
                          Uri.parse(apiUrl),
                          headers: {'Content-Type': 'application/json'},
                        );

                        // 🔑 FIX: เคลียร์ข้อมูล Token และ User จาก SharedPreferences
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.remove('token');
                        await prefs.remove('username');
                        await prefs.remove('user_id');
                        // Note: การใช้ remove() เป็นวิธีที่ปลอดภัยที่สุดในการเคลียร์ Session
                      } catch (e) {
                        debugPrint(
                          'Logout process error (API call or clear storage failed): $e',
                        );
                      }

                      // 🔹 กลับไปหน้า Login
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const Login()),
                        (Route<dynamic> route) => false,
                      );
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
