import 'package:flutter/material.dart';


class Seelender_requests extends StatefulWidget {
  const Seelender_requests({super.key});

  @override
  State<Seelender_requests> createState() => _Seelender_requestsState();
}

class _Seelender_requestsState extends State<Seelender_requests> {
  // --- ข้อมูลจำลองสำหรับแสดงผล ---
  final int borrowedCount = 12;
  final int availableCount = 38;
  final int disabledCount = 3;

  // ข้อมูลจำลองสำหรับ Pending Requests
  final List<Map<String, String>> pendingRequests = [
    {
      'title': 'Exploding kittens',
      'image': 'image/Exploding_Kitten.webp', // (ใช้ path รูปภาพจากโค้ดก่อนหน้า)
      'user': 'Anonymous',
    },
    {
      'title': 'Catan',
      'image': 'image/Catan.jpg', // (ใช้ path รูปภาพจากโค้ดก่อนหน้า)
      'user': 'Anonymous',
    },
  ];
  // --- จบส่วนข้อมูลจำลอง ---


  // --- ฟังก์ชันสำหรับแสดง Pop-up (Approve/Disapprove) ---
  void _showConfirmationDialog({ // ⭐️ เปลี่ยนชื่อเล็กน้อยเพื่อความชัดเจน
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color color,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0), // ขอบมน
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min, // ให้ Column สูงเท่าเนื้อหา
              children: [
                Icon(
                  icon,
                  color: color,
                  size: 100, // ไอคอนขนาดใหญ่
                ),
                const SizedBox(height: 20),
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
    
    // ⬇️⬇️⬇️ 1. ลบส่วนที่ปิดอัตโนมัติออกแล้ว ⬇️⬇️⬇️
    // Future.delayed(const Duration(seconds: 2), () {
    //    ...
    // });
    // ⬆️⬆️⬆️ จบส่วนที่ลบ ⬆️⬆️⬆️
  }
  

  // ⬇️⬇️⬇️ 2. เพิ่มฟังก์ชันสำหรับ Dialog "เหตุผล" ⬇️⬇️⬇️
  void _showDisapprovalDialog({
    required BuildContext context,
    required int index, // รับ index เพื่อใช้ลบ
  }) {
    final _formKey = GlobalKey<FormState>();
    final _reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        // ใช้ StatefulBuilder เพื่อให้ Dialog สามารถ update state ภายในตัวเองได้
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Reason for Disapproval',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.red.shade400,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _reasonController,
                        decoration: InputDecoration(
                          hintText: 'Enter reason...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.red.shade400),
                          ),
                        ),
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a reason';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade400,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        onPressed: () {
                          // ตรวจสอบว่ากรอกเหตุผลหรือยัง
                          if (_formKey.currentState!.validate()) {
                            // 1. ปิด Dialog เหตุผล
                            Navigator.of(context).pop(); 
                            
                            // 2. แสดง Dialog "Disapproved"
                            _showConfirmationDialog(
                              context: context,
                              title: 'Disapproved',
                              icon: Icons.block,
                              color: Colors.red.shade400,
                            );
                            
                            // 3. ลบรายการออกจาก List (อัปเดต UI พื้นหลัง)
                            setState(() {
                              pendingRequests.removeAt(index);
                            });
                          }
                        },
                        child: const Text('Submit'),
                      )
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
  // ⬆️⬆️⬆️ จบส่วนที่เพิ่ม (Dialog เหตุผล) ⬆️⬆️⬆️


  // --- ฟังก์ชันสำหรับจัดการการกด Bottom Nav Bar ---
  void _onNavItemTapped(int index) {
    switch (index) {
      case 0:
        // (Games) - กดกลับไปหน้าแรก (BrowseLender)
        Navigator.pop(context);
        break;
      case 1:
        // (Stats) - เราอยู่ที่หน้านี้แล้ว ไม่ต้องทำอะไร
        break;
      case 2:
        // (Bookings) - TODO: สร้างหน้า Bookings
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Navigate to Bookings (Not Implemented)')),
        );
        break;
      case 3:
        // (Logout) - TODO: ใส่ Logic การ Logout
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Logout Tapped (Not Implemented)')),
        );
        break;
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16.0, 40.0, 16.0, 16.0), // เพิ่ม padding ด้านบน
        children: [
          _buildHeader(),
          const SizedBox(height: 20),
          _buildStatusCards(),
          const SizedBox(height: 30),
          _buildPendingTitle(),
          const SizedBox(height: 20),
          _buildRequestsList(),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(), // 5. Bottom Navigation Bar
    );
  }

  // (rest of the code is unchanged...)

  // --- 1. Widget หัวข้อ "Today's Status" ---
  Widget _buildHeader() {
    return const Text(
      'Today\'s Status',
      style: TextStyle(
        color: Colors.deepOrange,
        fontSize: 28,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  // --- 2. Widget การ์ด Status (Row) ---
  Widget _buildStatusCards() {
    return Row(
      children: [
        _buildStatusCardItem(
          count: borrowedCount,
          label: 'Borrowed',
          color: Colors.orange.shade400,
        ),
        const SizedBox(width: 12),
        _buildStatusCardItem(
          count: availableCount,
          label: 'Available',
          color: Colors.blueGrey.shade400,
        ),
        const SizedBox(width: 12),
        _buildStatusCardItem(
          count: disabledCount,
          label: 'Disabled',
          color: Colors.red.shade400,
        ),
      ],
    );
  }

  // (Helper) Widget สำหรับการ์ด status แต่ละใบ
  Widget _buildStatusCardItem({
    required int count,
    required String label,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          children: [
            Text(
              count.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- 3. Widget หัวข้อ "Pending Requests" ---
  Widget _buildPendingTitle() {
    return Text(
      'Pending Requests (${pendingRequests.length})',
      style: TextStyle(
        color: Colors.deepOrange.shade400,
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  // --- 4. Widget รายการ Requests (ListView) ---
  Widget _buildRequestsList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: pendingRequests.length,
      itemBuilder: (context, index) {
        final request = pendingRequests[index];
        return _buildRequestCard(
          index: index, 
          title: request['title']!,
          imagePath: request['image']!,
          user: request['user']!,
        );
      },
    );
  }

  
  // (Helper) Widget สำหรับการ์ด Request แต่ละใบ
  Widget _buildRequestCard({
    required int index, 
    required String title,
    required String imagePath,
    required String user,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row( // Main row
          crossAxisAlignment: CrossAxisAlignment.start, // จัดให้รูปอยู่บนสุด
          children: [
            // 1. รูปภาพ
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                imagePath,
                width: 60,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 60,
                  height: 80,
                  color: Colors.grey[200],
                  child: const Icon(Icons.broken_image, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(width: 16),

            // 2. จัดเรียง Text และ Buttons ใหม่ด้วย Column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- ส่วนข้อความ (อยู่ข้างบน) ---
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'From : $user',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  
                  const SizedBox(height: 10), // ⭐️ เพิ่มช่องว่างระหว่าง Text และ Buttons

                  // --- ส่วนปุ่ม (อยู่ข้างล่าง) ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end, 
                    children: [
                      
                      // ⬇️⬇️⬇️ 3. แก้ไข onPressed ของ Disapprove ⬇️⬇️⬇️
                      TextButton(
                        onPressed: () {
                          // ⭐️ เรียก Dialog "เหตุผล" ใหม่
                          _showDisapprovalDialog(context: context, index: index);
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.red.shade300,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text('Disapprove', style: TextStyle(fontSize: 12)),
                      ),
                      // ⬆️⬆️⬆️ จบส่วนที่แก้ไข ⬆️⬆️⬆️

                      const SizedBox(width: 8),

                      // ⬇️⬇️⬇️ 4. แก้ไข onPressed ของ Approve (ให้ลบ List ด้วย) ⬇️⬇️⬇️
                      TextButton(
                        onPressed: () {
                          // 1. แสดง Dialog "Approved"
                          _showConfirmationDialog(
                            context: context,
                            title: 'Approved',
                            icon: Icons.assignment_turned_in_outlined, 
                            color: Colors.blueGrey.shade400,
                          );
                          // 2. ลบรายการออกจาก List
                          setState(() {
                            pendingRequests.removeAt(index);
                          });
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.blueGrey.shade300,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text('Approve', style: TextStyle(fontSize: 12)),
                      ),
                      // ⬆️⬆️⬆️ จบส่วนที่แก้ไข ⬆️⬆️⬆️
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  // --- 5. Widget Bottom Navigation Bar ---
  Widget _buildBottomNav() {
    return BottomNavigationBar(
      onTap: _onNavItemTapped,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.style_outlined),
          activeIcon: Icon(Icons.style),
          label: 'Games',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.pie_chart_outline),
          activeIcon: Icon(Icons.pie_chart),
          label: 'Stats',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today_outlined),
          activeIcon: Icon(Icons.calendar_today),
          label: 'Bookings',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.logout),
          activeIcon: Icon(Icons.logout),
          label: 'Logout',
        ),
      ],
      currentIndex: 1, 
      selectedItemColor: Colors.orange[800],
      unselectedItemColor: Colors.grey[600],
      showSelectedLabels: false, 
      showUnselectedLabels: false,
      type: BottomNavigationBarType.fixed,
    );
  }
}