import 'package:flutter/material.dart';
import 'package:boardgame_app/Student/Checkrequest.dart'; 
import '/login/login.dart'; 


// === หน้าจอหลัก ===
class BrowseStudent extends StatefulWidget {
  const BrowseStudent({super.key});

  @override
  State<BrowseStudent> createState() => _BrowseStudentState();
}

class _BrowseStudentState extends State<BrowseStudent> {
  // ข้อมูลจำลองสำหรับเกม
  final List<Map<String, String>> games = [
    {'title': 'Exploding Kittens', 'image': 'image/Exploding_Kitten.webp'},
    {'title': 'One Week Werewolf', 'image': 'image/One_Week_Werewolf.webp'},
    {'title': 'Catan', 'image': 'image/Catan.jpg'},
    {'title': 'Splendor', 'image': 'image/Splendor.jpg'},
    {'title': 'Avalon', 'image': 'image/Avalon.jpg'},
  ];

  // หมวดหมู่จำลอง
  final List<String> categories = [
    'Family',
    'Party',
    'Bluffing',
    'Abstract',
    'Dice'
  ];
  String selectedCategory = 'Family';

  final int _selectedIndex = 0;

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return; 

    switch (index) {
      case 0: // Games
        break;
      case 1: // Stats 
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Checkrequest()), 
        );
        break;
      case 2: // Bookings
        print("Navigate to Bookings");
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
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: ListView(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'BOARD GAME SS',
                      style: TextStyle(
                        color: Colors.orange,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Welcome Student',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildSearchBar(),
                    const SizedBox(height: 20),
                    _buildCategoryFilters(),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _buildGameGrid(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Search',
        prefixIcon: const Icon(Icons.search, color: Colors.grey),
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: const BorderSide(color: Colors.orange),
        ),
      ),
    );
  }

  Widget _buildCategoryFilters() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category == selectedCategory;

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedCategory = category;
              });
            },
            child: Container(
              margin: const EdgeInsets.only(right: 8.0),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? Colors.orange : Colors.grey[200],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  category,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black54,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGameGrid() {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemCount: games.length,
      itemBuilder: (context, index) {
        return GameCard(
          title: games[index]['title']!,
          imagePath: games[index]['image']!,
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
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
      selectedItemColor: Colors.orange[800],
      unselectedItemColor: Colors.grey[600],
      showSelectedLabels: false,
      showUnselectedLabels: false,
      type: BottomNavigationBarType.fixed,
    );
  }
}

// === Widget ของการ์ดเกมแต่ละใบ ===
class GameCard extends StatelessWidget {
  final String title;
  final String imagePath;

  const GameCard({
    super.key,
    required this.title,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Image.asset(
              imagePath,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[200],
                  child: const Icon(Icons.broken_image, color: Colors.grey),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}