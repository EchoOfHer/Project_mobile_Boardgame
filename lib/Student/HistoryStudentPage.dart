import 'dart:async';
import 'package:flutter/material.dart';
import 'package:boardgame_app/Student/Checkrequest.dart';
import 'package:boardgame_app/Student/student_browse_list.dart'; 
import 'package:boardgame_app/login/login.dart'; 



class HistoryStudentPage extends StatefulWidget {
  const HistoryStudentPage({super.key});

  @override
  State<HistoryStudentPage> createState() => _HistoryStudentPageState();
}

class _HistoryStudentPageState extends State<HistoryStudentPage> {
  final TextEditingController _search = TextEditingController();
  Timer? _debounce;

  // ----- mock data -----
  final List<Map<String, String>> _all = [
    {
      'game': 'Exploding Kitten',
      'id': '0001',
      'approvedBy': 'Lender 1',
      'returnedTo': 'Steven',
      'borrowedDate': '15 Oct 2025',
      'returnedDate': '16 Oct 2025',
    },
    {
      'game': 'Catan',
      'id': '0003',
      'approvedBy': 'Lender 3',
      'returnedTo': 'Steven',
      'borrowedDate': '15 Oct 2025',
      'returnedDate': '16 Oct 2025',
    },
    {
      'game': 'One week werewolf',
      'id': '0005',
      'approvedBy': 'Lender 4',
      'returnedTo': 'Steven',
      'borrowedDate': '12 Oct 2025',
      'returnedDate': '14 Oct 2025',
    },
  ];

  late List<Map<String, String>> _filtered;

  // ⬇️⬇️⬇️ 2. กำหนด INDEX ของหน้านี้ (0=Games, 1=Stats, 2=Bookings) ⬇️⬇️⬇️
  final int _selectedIndex = 2; // 2 คือ "Bookings"

  @override
  void initState() {
    super.initState();
    _filtered = List.from(_all);
    _search.addListener(_onSearchChange);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    super.dispose();
  }

  void _onSearchChange() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 200), () {
      final q = _search.text.trim().toLowerCase();
      setState(() {
        if (q.isEmpty) {
          _filtered = List.from(_all);
        } else {
          _filtered = _all.where((m) {
            return (m['game']!.toLowerCase().contains(q)) ||
                (m['id']!.toLowerCase().contains(q)) ||
                (m['approvedBy']!.toLowerCase().contains(q)) ||
                (m['returnedTo']!.toLowerCase().contains(q));
          }).toList();
        }
      });
    });
  }

  void _clearSearch() {
    _search.clear();
    FocusScope.of(context).unfocus();
  }

  // ⬇️⬇️⬇️ 3. เพิ่มฟังก์ชันสำหรับ BOTTOM NAV BAR (คัดลอกจาก BrowseStudent) ⬇️⬇️⬇️

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return; // ไม่ต้องทำอะไรถ้ากดปุ่มของหน้าปัจจุบัน

    switch (index) {
      case 0: // Games
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const BrowseStudent()),
        );
        break;
      case 1: // Stats
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Checkrequest()),
        );
        break;
      case 2: // Bookings (หน้านี้)
        // ไม่ต้องทำอะไร
        break;
      case 3: // Logout
        _showLogoutDialog();
        break;
    }
  }

  void _showLogoutDialog() {
    const Color logoutColor = Color(0xFFFF7C7C);

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
              Icon(Icons.logout, size: 60, color: logoutColor),
              const SizedBox(height: 16),
              Text(
                "Log Out",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: logoutColor,
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
                    child: const Text("Cancle"),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: logoutColor,
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

  Widget _buildBottomNav() {
    return BottomNavigationBar(
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
      currentIndex: _selectedIndex, // ใช้ตัวแปรที่ตั้งค่าไว้ (2)
      onTap: _onItemTapped, // เชื่อมต่อฟังก์ชัน
      selectedItemColor: Colors.orange[800],
      unselectedItemColor: Colors.grey[600],
      showSelectedLabels: false,
      showUnselectedLabels: false,
      type: BottomNavigationBarType.fixed,
    );
  }
  // ⬆️⬆️⬆️ จบส่วน Bottom Nav Bar ⬆️⬆️⬆️

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'History',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFE67E22),
                ),
              ),
              const SizedBox(height: 12),

              // Search
              TextField(
                controller: _search,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'Search by game, borrower . . .',
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Color(0xFFE67E22),
                  ),
                  suffixIcon: (_search.text.isEmpty)
                      ? null
                      : IconButton(
                          onPressed: _clearSearch,
                          icon: const Icon(
                            Icons.close,
                            color: Color(0xFFE67E22),
                          ),
                        ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(
                      color: Color(0xFFFFD6A5),
                      width: 2,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(
                      color: Color(0xFFE67E22),
                      width: 2.5,
                    ),
                  ),
                  hintStyle: const TextStyle(color: Colors.black45),
                ),
              ),

              const SizedBox(height: 20),
              // List section
              Expanded(
                child: _filtered.isEmpty
                    ? const Center(
                        child: Text(
                          'No results found',
                          style: TextStyle(color: Colors.black54),
                        ),
                      )
                    : ListView.separated(
                        itemCount: _filtered.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 16),
                        itemBuilder: (_, i) => HistoryCard(item: _filtered[i]),
                      ),
              ),
            ],
          ),
        ),
      ),
      
      // ⬇️⬇️⬇️ 4. เพิ่ม Bottom Nav Bar เข้าไปใน SCAFFOLD ⬇️⬇️⬇️
      bottomNavigationBar: _buildBottomNav(),
      // ⬆️⬆️⬆️ ⬆️⬆️⬆️ ⬆️⬆️⬆️ ⬆️⬆️⬆️ ⬆️⬆️⬆️ ⬆️⬆️⬆️ ⬆️⬆️⬆️ ⬆️⬆️⬆️
    );
  }
}

// ... (คลาส HistoryCard ไม่ต้องแก้ไข) ...
class HistoryCard extends StatelessWidget {
  final Map<String, String> item;
  const HistoryCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item['game']!,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            'ID : ${item['id']}',
            style: const TextStyle(fontSize: 13, color: Colors.black54),
          ),
          const SizedBox(height: 12),
          _row('Approved by :', item['approvedBy']!),
          _row('Returned to :', item['returnedTo']!),
          const Divider(height: 20, thickness: 0.5),
          _row('Borrowed date :', item['borrowedDate']!),
          _row('Returned date :', item['returnedDate']!),
        ],
      ),
    );
  }

  static Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, color: Colors.black54),
            ),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }
}