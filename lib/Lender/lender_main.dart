import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'lender_browse_list.dart';
import 'see_request.dart';
import 'HistoryLenderPage.dart';
import '/login/login.dart';

const colour_main = Color(0xFFFF8000);
const colour_available = Color(0xFF729382);
const colour_disable = Color(0xFFFF7C7C);
const colour_borrow = Color(0xFFEFA34B);
final url = '10.0.2.2:3000'; // ✅ ตัด http:// ออกให้เหมือน StudentMain

class LenderMain extends StatefulWidget {
  const LenderMain({super.key});

  @override
  State<LenderMain> createState() => _LenderMainState();
}

class _LenderMainState extends State<LenderMain> with TickerProviderStateMixin {
  late TabController _tabController;
  final int _tabCount = 4;

  int? _lenderId;
  String? _authToken; // ✅ เก็บ token ที่ได้จาก login

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabCount, vsync: this);
    _loadUserData();
  }

  /// ✅ โหลด user_id และ auth_token จาก SharedPreferences
  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final lenderId = prefs.getInt('user_id');
    final authToken = prefs.getString('token');

    if (!mounted) return;

    if (lenderId == null || authToken == null) {
      // ถ้าไม่มีข้อมูล -> กลับไปหน้า Login
      await prefs.remove('user_id');
      await prefs.remove('token');
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const Login()),
        );
      }
      return;
    }

    setState(() {
      _lenderId = lenderId;
      _authToken = authToken;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_lenderId == null || _authToken == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: colour_main)),
      );
    }

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
              if (index == _tabCount - 1) {
                _showLogoutDialog();
                _tabController.index = _tabController.previousIndex;
              }
            },
            tabs: const [
              Tab(icon: Icon(FontAwesomeIcons.gamepad)), // Browse
              Tab(icon: Icon(Icons.inbox)), // Requests
              Tab(icon: Icon(FontAwesomeIcons.history)), // History
              Tab(icon: Icon(Icons.logout)), // Logout
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            const BrowseLender(), // Tab 1
            SeeLenderRequests(
              lenderId: _lenderId!,
              authToken: _authToken!,
            ), // Tab 2
            HistoryLenderPage(
              lenderId: _lenderId!,
              authToken: _authToken!,
            ), // Tab 3
            const Center(child: Text('')), // Tab 4 (logout)
          ],
        ),
      ),
    );
  }

  /// ✅ Popup logout
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.logout, size: 60, color: colour_disable),
            const SizedBox(height: 16),
            Text(
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
