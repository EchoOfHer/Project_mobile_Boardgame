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
final url = 'http://10.0.2.2:3000'; // เพิ่ม protocol

class LenderMain extends StatefulWidget {
  const LenderMain({super.key});

  @override
  State<LenderMain> createState() => _LenderMainState();
}

class _LenderMainState extends State<LenderMain> with TickerProviderStateMixin {
  late final TabController _tabController;
  final int _tabCount = 4;
  int? _lenderId;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabCount, vsync: this);
    _loadLenderId();
  }

  Future<void> _loadLenderId() async {
    final prefs = await SharedPreferences.getInstance();
    final lenderId = prefs.getInt('user_id');
    if (!mounted) return;

    if (lenderId == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const Login()),
      );
      return;
    }

    setState(() {
      _lenderId = lenderId;
      _loading = false;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: colour_main)),
      );
    }

    return Scaffold(
      body: TabBarView(
        controller: _tabController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          BrowseLender(), // ไม่ต้องมี Scaffold หรือ BottomNav
          SeeLenderRequests(lenderId: _lenderId!), // ลบ BottomNav ออก
          HistoryLenderPage(lenderId: _lenderId!), // ลบ AppBar/BottomNav ออก
          const Center(child: Text('')), // Logout placeholder
        ],
      ),
      bottomNavigationBar: _buildTabBar(),
    );
  }

  Widget _buildTabBar() {
    return Container(
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
          Tab(icon: Icon(FontAwesomeIcons.gamepad)),
          Tab(icon: Icon(Icons.inbox)),
          Tab(icon: Icon(FontAwesomeIcons.history)),
          Tab(icon: Icon(Icons.logout)),
        ],
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
            Icon(Icons.logout, size: 60, color: colour_disable),
            const SizedBox(height: 16),
            Text(
              "Log Out",
              style: TextStyle(
                  fontSize: 22, fontWeight: FontWeight.bold, color: colour_disable),
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
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const Login()),
                      (route) => false,
                    );
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
