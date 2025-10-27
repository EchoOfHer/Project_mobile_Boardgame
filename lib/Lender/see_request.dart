import 'package:flutter/material.dart';
import '/login/login.dart';


class Seelender_requests extends StatefulWidget {
  const Seelender_requests({super.key});

  @override
  State<Seelender_requests> createState() => _Seelender_requestsState();
}

class _Seelender_requestsState extends State<Seelender_requests> {
  // ... (โค้ดข้อมูลจำลอง และฟังก์ชัน _showConfirmationDialog, _showDisapprovalDialog เหมือนเดิม) ...
  final int borrowedCount = 12;
  final int availableCount = 38;
  final int disabledCount = 3;

  final List<Map<String, String>> pendingRequests = [
    {
      'title': 'Exploding kittens',
      'image': 'image/Exploding_Kitten.webp', 
      'user': 'Anonymous',
    },
    {
      'title': 'Catan',
      'image': 'image/Catan.jpg', 
      'user': 'Anonymous',
    },
  ];
  
  void _showConfirmationDialog({
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
            borderRadius: BorderRadius.circular(20.0), 
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min, 
              children: [
                Icon(
                  icon,
                  color: color,
                  size: 100, 
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
  }
  
  void _showDisapprovalDialog({
    required BuildContext context,
    required int index, 
  }) {
    final _formKey = GlobalKey<FormState>();
    final _reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
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
                          if (_formKey.currentState!.validate()) {
                            Navigator.of(context).pop(); 
                            
                            _showConfirmationDialog(
                              context: context,
                              title: 'Disapproved',
                              icon: Icons.block,
                              color: Colors.red.shade400,
                            );
                            
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
      // ⬇️ 2. แก้ไข case 3: Logout
      case 3:
        _showLogoutDialog(); // เรียก Dialog ยืนยัน
        break;
      // ⬆️ จบส่วนที่แก้ไข
    }
  }

  // ⬇️ 3. เพิ่มฟังก์ชันสำหรับแสดง Dialog (ใช้สี #FF7C7C)
  void _showLogoutDialog() {
    // สร้างตัวแปรสี #FF7C7C
    const Color logoutColor = Color(0xFFFF7C7C);

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) { 
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.logout, size: 60, color: logoutColor),
              const SizedBox(height: 16),
              Text(
                "Log Out",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: logoutColor, // ใช้สีที่กำหนด
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Are you sure you want to log out of your account?",
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
                    onPressed: () {
                      Navigator.pop(dialogContext); // ปิด Dialog
                    },
                    child: const Text("Cancle"), // สะกด "Cancle" ตามในรูป
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: logoutColor, // ใช้สีที่กำหนด
                      foregroundColor: Colors.white, 
                    ),
                    onPressed: () {
                      Navigator.pop(dialogContext); 
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const Login()),
                        (Route<dynamic> route) => false,
                      );
                    },
                    child: const Text("Confirm"),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
  // ⬆️ จบส่วนที่เพิ่ม ⬆️


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

  // ... (โค้ด _buildHeader, _buildStatusCards, _buildPendingTitle, 
  // _buildRequestsList, _buildRequestCard, _buildBottomNav เหมือนเดิม) ...

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
        child: Row( 
          crossAxisAlignment: CrossAxisAlignment.start, 
          children: [
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

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                  
                  const SizedBox(height: 10), 

                  Row(
                    mainAxisAlignment: MainAxisAlignment.end, 
                    children: [
                      
                      TextButton(
                        onPressed: () {
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

                      const SizedBox(width: 8),

                      TextButton(
                        onPressed: () {
                          _showConfirmationDialog(
                            context: context,
                            title: 'Approved',
                            icon: Icons.assignment_turned_in_outlined, 
                            color: Colors.blueGrey.shade400,
                          );
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