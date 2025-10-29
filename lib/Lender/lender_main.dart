// lender_main.dart

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// ⭐️ 1. Import หน้าของ Lender (ตามรูป)
import 'lender_browse_list.dart';
import 'lender_seerequests.dart';
import 'lender_logout.dart'; // ⭐️ (ไฟล์นี้ต้องสร้างใหม่)

// ⭐️ 2. ใช้สีหลัก
const colour_main = Color(0xFFFF8000);

class LenderMain extends StatefulWidget {
  const LenderMain({super.key});

  @override
  State<LenderMain> createState() => _LenderMainState();
}

class _LenderMainState extends State<LenderMain> with TickerProviderStateMixin {
  late TabController _tabController;
  // ⭐️ 3. กำหนดจำนวนแท็บ (Browse, Request, Logout)
  final int _tabCount = 3; 

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
            
            // ⭐️ 4. ตรรกะการ Logout (แท็บสุดท้าย index = 2)
            onTap: (index) {
              if (index == _tabCount - 1) { // 2 คือแท็บสุดท้าย
                // เรียกใช้ static method show จาก LenderLogout
                LenderLogout.show(context);
                
                // ป้องกันไม่ให้เปลี่ยนไปแท็บที่ 3 (หน้าเปล่า)
                _tabController.index = _tabController.previousIndex;
              }
            },
            
            // ⭐️ 5. กำหนดไอคอนสำหรับ Lender
            tabs: const [
              Tab(icon: Icon(FontAwesomeIcons.gamepad)), // Browse List
              Tab(icon: Icon(Icons.list_alt)),           // See Request
              Tab(icon: Icon(Icons.logout)),             // Logout
            ],
          ),
        ),
        
        // ⭐️ 6. กำหนดหน้าต่างๆ ใน TabBarView
        body: TabBarView(
          controller: _tabController,
          // ปิดการเลื่อนเปลี่ยนหน้าด้วยนิ้ว
          physics: const NeverScrollableScrollPhysics(), 
          children: const [
            BrowseLender(),   // 0
            LenderSeerequests(),         // 1
            Center(child: Text('')), // 2 (หน้าเปล่าสำหรับ Logout)
          ],
        ),
      ),
    );
  }
}