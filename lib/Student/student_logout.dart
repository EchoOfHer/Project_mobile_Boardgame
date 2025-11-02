// student_logout.dart

import 'package:flutter/material.dart';
import 'student_main.dart' show url;
// ⭐️ 1. import หน้า Login (ต้องมีไฟล์ /login/login.dart)
import '/login/login.dart';

// ⭐️ 2. เปลี่ยนเป็นคลาสธรรมดา (ไม่ใช่ Widget)
class StudentLogout {
  
  // ⭐️ 3. สร้าง static method ชื่อ show() ตามที่ Main เรียกใช้
  static void show(BuildContext context) {
    const Color logoutColor = Color(0xFFFF7C7C);

    showDialog(
      context: context,
      barrierDismissible: false, // ป้องกันการกดปิดข้างๆ
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
                      
                      // ⭐️ 4. ทำให้ Tab กลับไปหน้าแรก (index 0)
                      DefaultTabController.of(context).animateTo(0);
                    },
                    child: const Text("Cancel"),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: logoutColor,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      Navigator.pop(dialogContext);
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