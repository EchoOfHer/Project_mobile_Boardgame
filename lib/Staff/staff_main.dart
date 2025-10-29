import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'staff_dashboard.dart';
import 'staff_browse.dart';
import 'staff_return_asset.dart';
import 'staff_history.dart';
import 'staff_logout.dart';

const colour_main = Color(0xFFFF8000);
const colour_available = Color(0xFF729382);
const colour_disable = Color(0xFFFF7C7C);
const colour_borrow = Color(0xFFEFA34B);

class StaffMain extends StatefulWidget {
  const StaffMain({super.key});

  @override
  State<StaffMain> createState() => _StaffMainState();
}

class _StaffMainState extends State<StaffMain> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this, initialIndex: 0);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
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
                // กดแท็บ Logout → แสดง dialog แทนการเปลี่ยนหน้า
                StaffLogout.show(context);
                // ป้องกันไม่ให้เปลี่ยนไปแท็บที่ 5
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
          children: const [
            StaffBrowse(),
            StaffDashboard(),
            StaffReturnAsset(),
            StaffHistory(),
            Center(child: Text('')), // หน้าเปล่าสำหรับแท็บ Logout (ไม่แสดง)
          ],
        ),
      ),
    );
  }
}