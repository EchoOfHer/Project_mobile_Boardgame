import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'staff_dashboard.dart';
import 'staff_browse.dart';
import 'staff_return_asset.dart';
import 'staff_history.dart';
import 'staff_logout.dart';

const colour_main = Color(0xFFFF8000);
const colour_available = Color(0xFF729382);
const colour_disable = Color(0xFFFF7C7C);
const colour_borrow = Color(0xFFEFA34B);
final url = '10.0.2.2:3000';

class StaffMain extends StatefulWidget {
  const StaffMain({super.key});

  @override
  State<StaffMain> createState() => _StaffMainState();
}

class _StaffMainState extends State<StaffMain> with TickerProviderStateMixin {
  late TabController _tabController;
  final int _tabCount = 5;

  String? _authToken;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabCount, vsync: this);
    _loadAuthToken();
  }

  Future<void> _loadAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (mounted) {
      setState(() {
        _authToken = token;
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
    // รอโหลด authToken
    if (_authToken == null) {
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
              if (index == 4) {
                StaffLogout.show(context);
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
            StaffBrowse( ), // ส่ง token ให้ widget ลูก
            StaffDashboard(authToken: _authToken!),
            StaffReturnAsset(),
            StaffHistory( ),
            const Center(child: Text('')), // หน้าเปล่าสำหรับแท็บ Logout
          ],
        ),
      ),
    );
  }
}
