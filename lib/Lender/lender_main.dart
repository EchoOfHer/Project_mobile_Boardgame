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
final url = '10.0.2.2:3000';

class LenderMain extends StatefulWidget {
  final String authToken; // ★ 1. รับ Token จากหน้า Login

  // ★ 2. บังคับให้ส่ง authToken เข้ามา
  const LenderMain({super.key, required this.authToken});

  @override
  State<LenderMain> createState() => _LenderMainState();
}

class _LenderMainState extends State<LenderMain> with TickerProviderStateMixin {
  late TabController _tabController;
  final int _tabCount = 4;

  int? _lenderId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabCount, vsync: this);
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final lenderId = prefs.getInt('user_id');

    if (mounted) {
      setState(() {
        _lenderId = lenderId;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_lenderId == null) {
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
              Tab(icon: Icon(Icons.pie_chart)), // Requests
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
            // ★ 3. ส่ง Token ไปหน้า Requests
            SeeLenderRequests(
              lenderId: _lenderId!,
              authToken: widget.authToken,
            ), // Tab 2
            // ★ 4. ส่ง Token ไปหน้า History
            HistoryLenderPage(authToken: widget.authToken), // Tab 3

            const Center(child: Text('')), // Tab 4 (placeholder)
          ],
        ),
      ),
    );
  }

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
