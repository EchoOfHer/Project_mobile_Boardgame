import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'staff_dashboard.dart';
import 'staff_browse.dart';
import 'staff_return_asset.dart';
import 'staff_history.dart';
import 'staff_logout.dart';
import '/login/login.dart'; // เพื่อใช้หน้า Login ตอน Logout

const colour_main = Color(0xFFFF8000);
const colour_available = Color(0xFF729382);
const colour_disable = Color(0xFFFF7C7C);
const colour_borrow = Color(0xFFEFA34B);
final url = '10.0.2.2:3000';

class StaffMain extends StatefulWidget {
  final String authToken; // ★ 1. เพิ่มตัวแปรรับ Token

  // ★ 2. บังคับรับค่า authToken จากหน้า Login
  const StaffMain({super.key, required this.authToken});

  @override
  State<StaffMain> createState() => _StaffMainState();
}

class _StaffMainState extends State<StaffMain> with TickerProviderStateMixin {
  late TabController _tabController;
  final int _tabCount = 5;

  // ไม่ต้องประกาศ _authToken และ _loadAuthToken แล้ว ใช้ widget.authToken ได้เลย

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabCount, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ไม่ต้องเช็ค null แล้ว เพราะ authToken เป็น required
    return DefaultTabController(
      length: _tabCount,
      child: Scaffold(
        bottomNavigationBar: Container(
          height: 75,
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(width: 0.5, color: colour_main)),
          ),
          child: TabBar(
            controller: _tabController,
            labelColor: colour_main,
            unselectedLabelColor: Colors.grey,
            indicatorColor: colour_main,
            onTap: (index) {
              if (index == 4) {
                // เรียก Dialog Logout
                _showLogoutDialog();
                // ป้องกัน Tab เปลี่ยนไปหน้าว่าง
                _tabController.index = _tabController.previousIndex;
              }
            },
            tabs: const [
              Tab(icon: Icon(FontAwesomeIcons.gamepad)),
              Tab(icon: Icon(Icons.pie_chart)),
              Tab(icon: Icon(FontAwesomeIcons.boxesPacking)),
              Tab(icon: Icon(FontAwesomeIcons.calendarMinus)),
              Tab(icon: Icon(Icons.logout)),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            // ★ 3. ส่ง Token ไปยังหน้าลูกๆ (ตอนนี้หน้าลูกอาจจะยังไม่รับ เดี๋ยวเราไปแก้ต่อ)
            StaffBrowse(authToken: widget.authToken),
            StaffDashboard(authToken: widget.authToken),
            StaffReturnAsset(authToken: widget.authToken),
            StaffHistory(authToken: widget.authToken),
            const Center(child: Text('')), // หน้าเปล่าสำหรับแท็บ Logout
          ],
        ),
      ),
    );
  }

  // เพิ่มฟังก์ชัน Logout ให้สมบูรณ์ (ลอกมาจาก Lender)
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.logout, size: 60, color: colour_disable),
            const SizedBox(height: 16),
            const Text(
              "Log Out",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: colour_disable,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Are you sure you want to log out?",
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
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colour_disable,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.remove('user_id');
                    await prefs.remove('auth_token');
                    if (mounted) {
                      Navigator.pop(dialogContext);
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const Login()),
                        (route) => false,
                      );
                    }
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
