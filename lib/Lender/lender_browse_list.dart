import 'package:flutter/material.dart';
import 'see_request.dart'; 
import '/login/login.dart';

// === หน้าจอหลัก ===
class BrowseLender extends StatefulWidget {
  const BrowseLender({super.key});

  @override
  State<BrowseLender> createState() => _BrowseLenderState();
}

class _BrowseLenderState extends State<BrowseLender> {
  // ... (โค้ดข้อมูลเกมและหมวดหมู่ของคุณ เหมือนเดิม) ...
  final List<Map<String, String>> games = [
    {'title': 'Exploding Kittens', 'image': 'image/Exploding_Kitten.webp'},
    {'title': 'One Week Werewolf', 'image': 'image/One_Week_Werewolf.webp'},
    {'title': 'Catan', 'image': 'image/Catan.jpg'},
    {'title': 'Splendor', 'image': 'image/Splendor.jpg'},
    {'title': 'Avalon', 'image': 'image/Avalon.jpg'},
  ];
  final List<String> categories = [
    'Family',
    'Party',
    'Bluffing',
    'Abstract',
    'Dice'
  ];
  String selectedCategory = 'Family';


  // ⬇️ 2. แก้ไขฟังก์ชันสำหรับจัดการการกด Bottom Nav Bar ⬇️
  void _onNavItemTapped(int index) {
    switch (index) {
      case 0:
        // (Games) - เราอยู่ที่หน้านี้แล้ว ไม่ต้องทำอะไร
        break;
      case 1:
        // (Stats/Requests) - ⭐️ นี่คือส่วนที่ไปหน้า See Requests ⭐️
        Navigator.push( // ใช้ push เพื่อให้ย้อนกลับมาหน้านี้ได้
          context,
          MaterialPageRoute(builder: (context) => const Seelender_requests()),
        );
        break;
      case 2:
        // (Bookings) - TODO: สร้างหน้า Bookings
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Navigate to Bookings (Not Implemented)')),
        );
        break;
      // ⬇️ 3. แก้ไข case 3: Logout
      case 3:
        _showLogoutDialog(); // เรียก Dialog ยืนยัน
        break;
      // ⬆️ จบส่วนที่แก้ไข
    }
  }
  
  // ⬇️ 4. เพิ่มฟังก์ชันสำหรับแสดง Dialog (ใช้สี #FF7C7C)
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
      body: Container(
        // ... (โค้ด body ของคุณ เหมือนเดิม) ...
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
                      'Welcome Lender',
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

  // ... (โค้ด _buildSearchBar, _buildCategoryFilters, _buildGameGrid, _buildBottomNav เหมือนเดิม) ...
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
      currentIndex: 0, 
      selectedItemColor: Colors.orange[800],
      unselectedItemColor: Colors.grey[600],
      showSelectedLabels: false,
      showUnselectedLabels: false,
      type: BottomNavigationBarType.fixed,
    );
  }
}

// ... (โค้ด class GameCard เหมือนเดิม) ...
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