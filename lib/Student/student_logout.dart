import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
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
                        const String apiUrl = 'http://localhost:3000/api/logout';

                        // 🔹 ตัวอย่างการเรียก API logout
                        final response = await http.post(
                          Uri.parse(apiUrl),
                          headers: {
                            'Content-Type': 'application/json',
                            // ถ้ามี token ให้เพิ่มบรรทัดนี้:
                            // 'Authorization': 'Bearer $token',
                          },
                        );

                        if (response.statusCode == 200) {
                          final data = json.decode(response.body);
                          debugPrint('Logout success: ${data['message']}');
                        } else {
                          debugPrint('Logout failed: ${response.body}');
                        }
                      } catch (e) {
                        debugPrint('Logout error: $e');
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
