import 'package:flutter/material.dart';
import 'see_request.dart';
import '/login/login.dart';
import 'HistoryLenderPage.dart';
import 'request_borrowing_lender.dart'; 


// === หน้าจอหลัก ===
class BrowseLender extends StatefulWidget {
  const BrowseLender({super.key});

  @override
  State<BrowseLender> createState() => _BrowseLenderState();
}

class _BrowseLenderState extends State<BrowseLender> {
  // ⬇️⬇️⬇️ 2. เพิ่มตัวแปรสำหรับ Search และ Filter ⬇️⬇️⬇️
  final TextEditingController _searchController = TextEditingController();
  late List<Map<String, dynamic>> _filteredGames;
  // ⬆️⬆️⬆️ ⬆️⬆️⬆️ ⬆️⬆️⬆️ ⬆️⬆️⬆️ ⬆️⬆️⬆️ ⬆️⬆️⬆️

  // ⬇️⬇️⬇️ 3. ขยายข้อมูลเกม และเปลี่ยนประเภท List ⬇️⬇️⬇️
  final List<Map<String, dynamic>> games = [
    {
      'title': 'Exploding Kittens',
      'image': 'image/Exploding_Kitten.webp',
      'gameStyle': 'Party',
      'players': '2-10 peoples',
      'time': '10 min',
      'remaining': 1, // ต้องเป็น int (ตัวเลข)
    },
    {
      'title': 'One Week Werewolf',
      'image': 'image/One_Week_Werewolf.webp',
      'gameStyle': 'Party',
      'players': '3-7 players',
      'time': '10 min',
      'remaining': 3, // ต้องเป็น int
    },
    {
      'title': 'Catan',
      'image': 'image/Catan.jpg',
      'gameStyle': 'Strategy',
      'players': '3-4 players',
      'time': '60-120 min',
      'remaining': 2, // ต้องเป็น int
    },
    {
      'title': 'Splendor',
      'image': 'image/Splendor.jpg',
      'gameStyle': 'Strategy',
      'players': '2-4 players',
      'time': '30 min',
      'remaining': 0, // ต้องเป็น int
    },
    {
      'title': 'Avalon',
      'image': 'image/Avalon.jpg',
      'gameStyle': 'Bluffing',
      'players': '5-10 players',
      'time': '30 min',
      'remaining': 1, // ต้องเป็น int
    },
  ];
  // ⬆️⬆️⬆️ จบส่วนแก้ไขข้อมูลเกม ⬆️⬆️⬆️

  // ⬇️⬇️⬇️ 4. เพิ่ม "All" ในหมวดหมู่ และตั้งเป็นค่าเริ่มต้น ⬇️⬇️⬇️
  final List<String> categories = [
    'All', // เพิ่ม 'All'
    'Family',
    'Party',
    'Bluffing',
    'Abstract',
    'Dice',
    'Strategy', // (เพิ่ม Strategy จากข้อมูลเกมของคุณ)
  ];
  String selectedCategory = 'All'; // ตั้ง 'All' เป็นค่าเริ่มต้น
  // ⬆️⬆️⬆️ ⬆️⬆️⬆️ ⬆️⬆️⬆️ ⬆️⬆️⬆️ ⬆️⬆️⬆️ ⬆️⬆️⬆️

  // ⬇️⬇️⬇️ 5. เพิ่มตัวแปรสำหรับ Bottom Nav ⬇️⬇️⬇️
  final int _selectedIndex = 0; // หน้านี้คือ index ที่ 0

  // ⬇️⬇️⬇️ 6. เพิ่ม initState และ dispose ⬇️⬇️⬇️
  @override
  void initState() {
    super.initState();
    _filteredGames = List.from(games);
    _searchController.addListener(_runFilter);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  // ⬆️⬆️⬆️ ⬆️⬆️⬆️ ⬆️⬆️⬆️ ⬆️⬆️⬆️ ⬆️⬆️⬆️

  // ⬇️⬇️⬇️ 7. ฟังก์ชันหลักสำหรับกรองข้อมูล (Filter) ⬇️⬇️⬇️
  void _runFilter() {
    List<Map<String, dynamic>> results = List.from(games);
    final String searchQuery = _searchController.text.toLowerCase();

    // กรองด้วยหมวดหมู่
    if (selectedCategory != 'All') {
      results = results.where((game) {
        return game['gameStyle']!.toLowerCase() == selectedCategory.toLowerCase();
      }).toList();
    }

    // กรองด้วยการค้นหา
    if (searchQuery.isNotEmpty) {
      results = results.where((game) {
        return game['title']!.toLowerCase().contains(searchQuery);
      }).toList();
    }

    setState(() {
      _filteredGames = results;
    });
  }
  // ⬆️⬆️⬆️ ⬆️⬆️⬆️ ⬆️⬆️⬆️ ⬆️⬆️⬆️ ⬆️⬆️⬆️

  // ⬇️ 8. แก้ไขฟังก์ชันสำหรับจัดการการกด Bottom Nav Bar ⬇️
  void _onNavItemTapped(int index) {
    if (index == _selectedIndex) return; // ถ้ากดหน้าเดิม ไม่ต้องทำอะไร

    switch (index) {
      case 0: // (Games)
        break;
      case 1: // (Stats/Requests)
        Navigator.pushReplacement( // ⭐️ ใช้ pushReplacement
          context,
          MaterialPageRoute(builder: (context) => const SeeLenderRequests()),
        );
        break;
      case 2: // (Bookings/History)
        Navigator.pushReplacement( // ⭐️ เพิ่ม Case นี้
          context,
          MaterialPageRoute(builder: (context) => const HistoryLenderPage()),
        );
        break;
      case 3: // (Logout)
        _showLogoutDialog();
        break;
    }
  }

  // (ฟังก์ชัน _showLogoutDialog โค้ดเดิมของคุณถูกต้องแล้ว)
  void _showLogoutDialog() {
    const Color logoutColor = Color(0xFFFF7C7C);

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                      Navigator.pop(dialogContext);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          // ⬇️⬇️⬇️ 9. เปลี่ยน ListView เป็น Column + Expanded ⬇️⬇️⬇️
          child: Column(
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
                    _buildSearchBar(), // (ส่วนนี้จะถูกแก้ไขโดยฟังก์ชันข้างล่าง)
                    const SizedBox(height: 20),
                    _buildCategoryFilters(), // (ส่วนนี้จะถูกแก้ไขโดยฟังก์ชันข้างล่าง)
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: _buildGameGrid(), // (ส่วนนี้จะถูกแก้ไขโดยฟังก์ชันข้างล่าง)
              ),
            ],
          ),
          // ⬆️⬆️⬆️ ⬆️⬆️⬆️ ⬆️⬆️⬆️ ⬆️⬆️⬆️ ⬆️⬆️⬆️ ⬆️⬆️⬆️
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ⬇️⬇️⬇️ 10. แก้ไข SearchBar ให้ใช้ Controller ⬇️⬇️⬇️
  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController, // <--- เชื่อม Controller
      decoration: InputDecoration(
        hintText: 'Search by game title...', // <--- เปลี่ยน hint text
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
  // ⬆️⬆️⬆️ ⬆️⬆️⬆️ ⬆️⬆️⬆️ ⬆️⬆️⬆️ ⬆️⬆️⬆️ ⬆️⬆️⬆️

  // ⬇️⬇️⬇️ 11. แก้ไข CategoryFilters ให้เรียก _runFilter ⬇️⬇️⬇️
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
              _runFilter(); // <--- เรียกฟังก์ชันฟิลเตอร์เมื่อกดปุ่ม
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
  // ⬆️⬆️⬆️ ⬆️⬆️⬆️ ⬆️⬆️⬆️ ⬆️⬆️⬆️ ⬆️⬆️⬆️ ⬆️⬆️⬆️

  // ⬇️⬇️⬇️ 12. แก้ไข GameGrid ให้ใช้ _filteredGames และคลิกได้ ⬇️⬇️⬇️
  Widget _buildGameGrid() {
    // 12.1: ตรวจสอบว่ามีข้อมูลที่กรองแล้วหรือไม่
    if (_filteredGames.isEmpty) {
      return const Center(
        child: Text(
          'No games found.',
          style: TextStyle(color: Colors.grey, fontSize: 18),
        ),
      );
    }

    // 12.2: สร้าง Grid จาก _filteredGames
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      // (ลบ shrinkWrap และ physics)
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemCount: _filteredGames.length, // <--- ใช้ _filteredGames.length
      itemBuilder: (context, index) {
        final gameData = _filteredGames[index]; // <--- ใช้ _filteredGames[index]
        
        // 12.3: ห่อด้วย GestureDetector
        return GestureDetector(
          onTap: () {
            // ❗️ หมายเหตุ: ผมสมมติว่าคลาสของคุณชื่อ 'RequestBorrowingLenderPage'
            // และรับค่า parameters เหมือนกับ 'BorrowGamePage'
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RequestBorrowingLenderPage(
                  gameName: gameData['title']!,
                  imageAssetPath: gameData['image']!,
                  gameStyle: gameData['gameStyle']!,
                  players: gameData['players']!,
                  time: gameData['time']!,
                  remaining: gameData['remaining']!,
                ),
              ),
            );
          },
          child: GameCard(
            title: gameData['title']!,
            imagePath: gameData['image']!,
          ),
        );
      },
    );
  }
  // ⬆️⬆️⬆️ ⬆️⬆️⬆️ ⬆️⬆️⬆️ ⬆️⬆️⬆️ ⬆️⬆️⬆️ ⬆️⬆️⬆️

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
      currentIndex: _selectedIndex, // <--- 13. เชื่อม Index
      selectedItemColor: Colors.orange[800],
      unselectedItemColor: Colors.grey[600],
      showSelectedLabels: false,
      showUnselectedLabels: false,
      type: BottomNavigationBarType.fixed,
    );
  }
}

// ... (คลาส GameCard ไม่ต้องแก้ไข) ...
class GameCard extends StatelessWidget {
// ... (โค้ดเดิม) ...
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