import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // 💡 ต้อง Import shared_preferences
import '../login/login.dart';
// ⚠️ สมมติว่า AppLogout ถูกสร้างและอยู่ใน path ที่เข้าถึงได้
import '../logout.dart' show AppLogout;

// 📝 หมายเหตุ: เนื่องจากคลาส StaffLogout นี้ใช้แค่แสดง Dialog
// และไม่ได้จัดการ Logic การล้างข้อมูลด้วยตัวเอง ผมจะรวม Logic AppLogout ที่ใช้ SharedPrefs
// เข้าไปในคลาสนี้โดยตรงเพื่อความสะดวกในการรัน หากคุณยังไม่ได้สร้าง AppLogout แยก

class StaffLogout {
  static const Color _logoutColor = Color(0xFFFF7C7C);

  // 🔑 ฟังก์ชันสำหรับล้าง SharedPreferences และนำทางกลับไปหน้า Login
  static Future<void> _performLogout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();

    // 1. ลบ Token / User Data ที่บันทึกไว้ (Staff/Lender/Student ใช้ Key เดียวกัน)
    await prefs.remove('token');
    await prefs.remove('user_id');
    await prefs.remove('username');
    await prefs.remove('role');

    // 2. กลับไปหน้า Login และล้าง navigation stack
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const Login()),
      (_) => false,
    );
  }

  static void show(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.logout, size: 60, color: _logoutColor),
            const SizedBox(height: 16),
            const Text(
              "Log Out",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: _logoutColor,
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
                  // Cancel: ปิด Dialog
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _logoutColor,
                    foregroundColor: Colors.white,
                  ),
                  // Confirm: ปิด Dialog และทำการ Logout
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    // ⭐️ FIXED: เรียกใช้ฟังก์ชันที่ล้าง SharedPreferences และนำทาง
                    _performLogout(context);
                  },
                  child: const Text("Confirm"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
