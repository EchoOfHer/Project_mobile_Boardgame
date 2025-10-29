// lender_main.dart

import 'package:boardgame_app/Lender/see_request.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'lender_browse_list.dart';
import 'lender_seerequests.dart';
import 'HistoryLenderPage.dart'; // ⭐️ 1. Import หน้า History
import 'lender_logout.dart';

const colour_main = Color(0xFFFF8000);

class LenderMain extends StatefulWidget {
  const LenderMain({super.key});

  @override
  State<LenderMain> createState() => _LenderMainState();
}

class _LenderMainState extends State<LenderMain> with TickerProviderStateMixin {
  late TabController _tabController;

  // ⭐️ 2. เปลี่ยนจำนวนแท็บเป็น 4
  final int _tabCount = 4;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: _tabCount,
      vsync: this,
      initialIndex: 0,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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

            // ⭐️ 3. ตรรกะ Logout (แท็บสุดท้ายตอนนี้คือ index 3)
            onTap: (index) {
              if (index == _tabCount - 1) {
                // 3 คือแท็บสุดท้าย
                LenderLogout.show(context);
                _tabController.index = _tabController.previousIndex;
              }
            },

            // ⭐️ 4. เพิ่มไอคอน History
            tabs: const [
              Tab(icon: Icon(FontAwesomeIcons.gamepad)),
              Tab(icon: Icon(Icons.pie_chart)),
              Tab(icon: Icon(FontAwesomeIcons.calendarMinus)),
              Tab(icon: Icon(Icons.logout)), // 3: Logout
            ],
          ),
        ),

        // ⭐️ 5. เพิ่มหน้า History ใน TabBarView
        body: TabBarView(
          controller: _tabController,
          physics: const NeverScrollableScrollPhysics(),
          children: const [
            BrowseLender(), // 0
            LenderSeerequests(), // 1
            HistoryLenderPage(), // 2 (หน้าที่เพิ่มใหม่)
            Center(child: Text('')), // 3 (หน้าเปล่าสำหรับ Logout)
          ],
        ),
      ),
    );
  }
}
