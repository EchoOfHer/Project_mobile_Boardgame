import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'student_browse.dart';
import 'student_checkrequests.dart';
import 'student_history.dart';
import 'student_logout.dart';

const colour_main = Color(0xFFFF8000);
const colour_available = Color(0xFF729382);
const colour_disable = Color(0xFFFF7C7C);
const colour_borrow = Color(0xFFEFA34B);

class StudentMain extends StatefulWidget {
  const StudentMain({super.key});

  @override
  State<StudentMain> createState() => _StudentMainState();
}

class _StudentMainState extends State<StudentMain> with TickerProviderStateMixin {
  late TabController _tabController;
  final int _tabCount = 4; // ✅ มี 4 แท็บจริง ๆ

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabCount, vsync: this, initialIndex: 0);
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
            onTap: (index) {
              if (index == _tabCount - 1) {
                // ✅ เรียกกล่อง Logout
                StudentLogout.show(context);

                // ✅ ย้อนกลับไป tab เดิม (ไม่เปลี่ยนหน้า)
                _tabController.index = _tabController.previousIndex;
              }
            },
            tabs: const [
              Tab(icon: Icon(FontAwesomeIcons.gamepad)),      // Browse
              Tab(icon: Icon(Icons.list_alt)),                 // Borrowing
              Tab(icon: Icon(FontAwesomeIcons.calendarMinus)), // History
              Tab(icon: Icon(Icons.logout)),                   // Logout
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          physics: const NeverScrollableScrollPhysics(),
          children: const [
            StudentBrowse(),
            StudentCheckrequests(),
            StudentHistory(),
            Center(child: Text('')), // หน้า logout ว่าง
          ],
        ),
      ),
    );
  }
}
