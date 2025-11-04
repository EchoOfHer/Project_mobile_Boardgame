import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart'; // 💡 NEW

import 'student_browse.dart';
import 'student_checkrequests.dart';
import 'student_history.dart';
import 'student_logout.dart';

const colour_main = Color(0xFFFF8000);
const colour_available = Color(0xFF729382);
const colour_disable = Color(0xFFFF7C7C);
const colour_borrow = Color(0xFFEFA34B);
final url = '10.0.2.2:3000';

class StudentMain extends StatefulWidget {
  const StudentMain({super.key});

  @override
  State<StudentMain> createState() => _StudentMainState();
}

class _StudentMainState extends State<StudentMain>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final int _tabCount = 4;

  // 🔑 NEW: State to hold the user ID
  int? _userId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: _tabCount,
      vsync: this,
      initialIndex: 0,
    );
    // 🔑 NEW: Load user ID on initialization
    _loadUserId();
  }

  // 🔑 NEW: Function to load the user ID from SharedPreferences
  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id'); // Retrieve the saved numeric ID
    if (mounted) {
      setState(() {
        _userId = userId;
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
    if (_userId == null) {
      // Show loading indicator while fetching user ID
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: colour_main)),
      );
    }

    // 💡 The logic from your original build method starts here
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
                StudentLogout.show(context);
                _tabController.index = _tabController.previousIndex;
              }
            },
            tabs: const [
              Tab(icon: Icon(FontAwesomeIcons.gamepad)),
              Tab(icon: Icon(Icons.pie_chart)),
              Tab(icon: Icon(FontAwesomeIcons.calendarMinus)),
              Tab(icon: Icon(Icons.logout)),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            const BrowseStudent(),
            // 🔑 PASS the retrieved user ID to StudentCheckrequests
            StudentCheckrequests(userId: _userId!),
            StudentHistory(
              userId: _userId!,
            ), // You should pass it to History too!
            const Center(child: Text('')), // Logout page
          ],
        ),
      ),
    );
  }
}
