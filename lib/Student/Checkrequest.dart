import 'package:flutter/material.dart';
import 'student_browse_list.dart';
import 'HistoryStudentPage.dart';
import 'package:boardgame_app/login/login.dart';

class Checkrequest extends StatefulWidget {
  const Checkrequest({super.key});

  @override
  State<Checkrequest> createState() => _CheckrequestState();
}

class _CheckrequestState extends State<Checkrequest> {
  bool hasRequest = true;
  bool isReturning = false;
  bool isCancelling = false;

  final int _selectedIndex = 1; // หน้านี้คือ index 1 (Stats)

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;

    switch (index) {
      case 0: // Games
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const BrowseStudent()),
        );
        break;
      case 1: // Stats
        break;
      case 2: // Bookings
       Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HistoryStudentPage()), // ไปหน้า History
        );
        break;
      case 3: // Logout
        _showLogoutDialog(); // เรียก Dialog ยืนยัน
        break;
    }
  }

  // ⬇️ ⬇️ ⬇️ นี่คือฟังก์ชันที่แก้ไขสี ⬇️ ⬇️ ⬇️
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
              // 1. เปลี่ยนสีไอคอน
              Icon(Icons.logout, size: 60, color: logoutColor),
              const SizedBox(height: 16),
              // 2. เปลี่ยนสีข้อความ "Log Out"
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
                  // 3. เปลี่ยนสีปุ่ม Confirm
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
  // ⬆️ ⬆️ ⬆️ จบส่วนที่แก้ไข ⬆️ ⬆️ ⬆️


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),

      bottomNavigationBar: BottomNavigationBar(
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
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.orange[800],
        unselectedItemColor: Colors.grey[600],
        showSelectedLabels: false,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
      ),
      
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              const Text(
                "Borrow status",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange),
              ),
              Divider(
                color: const Color.fromARGB(255, 255, 115, 0),
              ),
              const SizedBox(height: 10),
              buildBorrowCard(),
              const SizedBox(height: 30),
              const Text(
                "Request status",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange),
              ),
              Divider(
                color: const Color.fromARGB(255, 255, 115, 0),
              ),
              const SizedBox(height: 10),
              hasRequest ? buildRequestCard() : buildNoRequestText(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildBorrowCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Image.asset("image/Castle_Panic.webp",
                width: 70, height: 90, fit: BoxFit.cover),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Exploding kittens",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  const Text("From: 27/10/2025\nTo: 28/10/2025"),
                  const SizedBox(height: 6),
                  Text(
                    isReturning ? "Returning in process" : "In use",
                    style: TextStyle(
                        color: isReturning ? Colors.grey : Colors.green,
                        fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 10),
                  if (!isReturning)
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.orange,
                        side: const BorderSide(color: Colors.orange),
                      ),
                      onPressed: () {
                        setState(() => isReturning = true);
                        showReturningDialog();
                      },
                      child: const Text("Return Assets"),
                    ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget buildRequestCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Image.asset("image/Champions_of_Hara.webp",
                width: 70, height: 90, fit: BoxFit.cover),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Exploding kittens",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  const Text("From: 29/10/2025\nTo: 30/10/2025"),
                  const SizedBox(height: 6),
                  const Text("Pending",
                      style: TextStyle(
                          color: Colors.orange, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 10),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.orange,
                      side: const BorderSide(color: Colors.orange),
                    ),
                    onPressed: showCancelDialog,
                    child: const Text("Cancel request"),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget buildNoRequestText() {
    return const Center(
      child: Text("You have no request", style: TextStyle(color: Colors.grey)),
    );
  }

  void showReturningDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.loop, size: 60, color: Colors.green),
            SizedBox(height: 16),
            Text("Returning",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text("Please contact staff to approve", textAlign: TextAlign.center),
          ],
        ),
      ),
    );
    Future.delayed(const Duration(seconds: 2), () => Navigator.pop(context));
  }

  void showCancelDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cancel_outlined,
                size: 60, color: Colors.redAccent),
            const SizedBox(height: 16),
            const Text("Cancel",
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.red)),
            const SizedBox(height: 8),
            const Text("Are you sure you want to cancel your request?",
                textAlign: TextAlign.center),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("No"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: () {
                    setState(() => hasRequest = false);
                    Navigator.pop(context);
                  },
                  child: const Text("Yes"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}