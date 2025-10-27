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

class _StaffMainState extends State<StaffMain> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      initialIndex: 0,
      child: Scaffold(
        bottomNavigationBar: Container(
          height: 75,
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(width: 0.5, color: colour_main)),
          ),
          child: const TabBar(
            labelColor: colour_main,
            unselectedLabelColor: Colors.grey,
            indicatorColor: colour_main,
            tabs: [
              Tab(icon: Icon(FontAwesomeIcons.gamepad)),
              Tab(icon: Icon(Icons.pie_chart)),
              Tab(icon: Icon(FontAwesomeIcons.boxesPacking)),
              Tab(icon: Icon(FontAwesomeIcons.calendarMinus)),
              Tab(icon: Icon(Icons.logout)),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            StaffBrowse(),
            StaffDashboard(),
            StaffReturnAsset(),
            StaffHistory(),
            StaffLogout(),
          ],
        ),
      ),
    );
  }
}
