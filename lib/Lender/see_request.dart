import 'package:flutter/material.dart';
import '/login/login.dart';
import 'package:boardgame_app/Staff/staff_main.dart'
    show colour_available, colour_borrow, colour_disable, colour_main;
// ⬇️⬇️⬇️ 1. เพิ่ม IMPORTS ที่จำเป็น ⬇️⬇️⬇️
import 'lender_browse_list.dart'; // (หน้า Games)
import 'HistoryLenderPage.dart'; // (หน้า History/Bookings)
// ⬆️⬆️⬆️ ⬆️⬆️⬆️ ⬆️⬆️⬆️ ⬆️⬆️⬆️ ⬆️⬆️⬆️ ⬆️⬆️⬆️

class SeeLenderRequests extends StatefulWidget {
  const SeeLenderRequests({super.key});

  @override
  State<SeeLenderRequests> createState() => _SeeLenderRequestsState();
}

class _SeeLenderRequestsState extends State<SeeLenderRequests> {
  // ... (โค้ดข้อมูลจำลอง และฟังก์ชัน Dialogs ของคุณเหมือนเดิม) ...
  final int borrowedCount = 12;
  final int availableCount = 38;
  final int disabledCount = 3;

  final List<Map<String, String>> pendingRequests = [
    {
      'title': 'Castle Panic',
      'image': 'image/Castle_Panic.webp',
      'user': 'Anonymous',
      'Fdate': '29',
      'Tdate': '30',
      'month': 'October',
    },
    {
      'title': 'Champions of Hara',
      'image': 'image/Champions_of_Hara.webp',
      'user': 'Anonymous',
      'Fdate': '29',
      'Tdate': '30',
      'month': 'October',
    },
  ];

  void _showConfirmationDialog({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color color,
  }) {
    // ... (โค้ดเดิม ไม่ต้องแก้ไข) ...
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
                Icon(icon, color: color, size: 100),
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
    // ... (โค้ดเดิม ไม่ต้องแก้ไข) ...
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
                          color: colour_disable, // <-- FIXED
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
                            borderSide: BorderSide(color: colour_disable),
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
                          backgroundColor: colour_disable, // <-- FIXED
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
                              color: colour_disable, // <-- FIXED
                            );

                            setState(() {
                              pendingRequests.removeAt(index);
                            });
                          }
                        },
                        child: const Text('Submit'),
                      ),
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
  // ⬇️⬇️⬇️ 2. แก้ไข LOGIC การนำทาง ⬇️⬇️⬇️
  void _onNavItemTapped(int index) {
    // (กำหนด index ของหน้านี้)
    const int currentIndex = 1;
    if (index == currentIndex) return; // ไม่ต้องทำอะไร ถ้ากดปุ่มของหน้าปัจจุบัน

    switch (index) {
      case 0: // (Games) - กดกลับไปหน้าแรก (BrowseLender)
        Navigator.pushReplacement(
          // ⭐️ ใช้ pushReplacement
          context,
          MaterialPageRoute(builder: (context) => const BrowseLender()),
        );
        break;
      case 1: // (Stats) - เราอยู่ที่หน้านี้แล้ว
        break;
      case 2: // (Bookings/History)
        Navigator.pushReplacement(
          // ⭐️ ใช้ pushReplacement
          context,
          MaterialPageRoute(builder: (context) => const HistoryLenderPage()),
        );
        break;
      case 3: // (Logout)
        _showLogoutDialog();
        break;
    }
  }
  // ⬆️⬆️⬆️ จบส่วนแก้ไข ⬆️⬆️⬆️

  // ... (โค้ด _showLogoutDialog ของคุณเหมือนเดิม) ...
  void _showLogoutDialog() {
    // ⭐️ FIXED: ใช้ colour_disable โดยตรง
    // const Color logoutColor = Color(0xFFFF7C7C);

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.logout, size: 60, color: colour_disable), // <-- FIXED
              const SizedBox(height: 16),
              Text(
                "Log Out",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: colour_disable, // <-- FIXED
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
                      backgroundColor: colour_disable, // <-- FIXED
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16.0, 40.0, 16.0, 16.0),
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
    );
  }

  // ... (โค้ด _buildHeader, _buildStatusCards, _buildPendingTitle,
  // _buildRequestsList, _buildRequestCard ของคุณเหมือนเดิม) ...

  Widget _buildHeader() {
    return const Text(
      'Today\'s Status',
      style: TextStyle(
        color: colour_main,
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
          color: colour_borrow,
        ),
        const SizedBox(width: 12),
        _buildStatusCardItem(
          count: availableCount,
          label: 'Available',
          color: colour_available,
        ),
        const SizedBox(width: 12),
        _buildStatusCardItem(
          count: disabledCount,
          label: 'Disabled',
          color: colour_disable,
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
            ),
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
        color: colour_main,
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildRequestsList() {
    return ListView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: pendingRequests.length,
      itemBuilder: (context, index) {
        final request = pendingRequests[index];
        // --- ⭐️ FIX 2: Pass values in ---
        return _buildRequestCard(
          index: index,
          title: request['title']!,
          imagePath: request['image']!,
          user: request['user']!,
          fDate: request['Fdate']!,
          tDate: request['Tdate']!,
          month: request['month']!,
        );
      },
    );
  }

  // --- ⭐️ FIX 1: Add parameters ---
  Widget _buildRequestCard({
    required int index,
    required String title,
    required String imagePath,
    required String user,
    required String fDate,
    required String tDate,
    required String month,
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
                width: 125,
                height: 125,
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
                  // --- ⭐️ FIX 3: Use parameters ---
                  Text(
                    'Duration : $fDate - $tDate $month',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          _showDisapprovalDialog(
                            context: context,
                            index: index,
                          );
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: colour_disable,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(
                          'Disapprove',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: () {
                          _showConfirmationDialog(
                            context: context,
                            title: 'Approved',
                            icon: Icons.assignment_turned_in_outlined,
                            color: colour_available, // <-- FIXED
                          );
                          setState(() {
                            pendingRequests.removeAt(index);
                          });
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: colour_available, // <-- FIXED
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(
                          'Approve',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
