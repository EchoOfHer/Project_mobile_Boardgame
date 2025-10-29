import 'package:flutter/material.dart';


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
  final List<String> categories = ['Family', 'Party', 'Bluffing', 'Abstract', 'Dice'];
  String selectedCategory = 'Family';

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

  // === ส่วน Search Bar ===
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

  // === ส่วน Filter หมวดหมู่ ===
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

  // === ส่วน Grid ของเกม ===
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

  // === ส่วน Bottom Navigation ===
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
          icon: Icon(Icons.calendar_today_outlined), // ไอคอนปฏิทิน (ตรงกับภาพ screenshot)
          activeIcon: Icon(Icons.calendar_today),
          label: 'Bookings',
        ),
        
        // ⬇️⬇️⬇️ แก้ไขไอคอน Logout ตรงนี้ ⬇️⬇️⬇️
        BottomNavigationBarItem(
          // เปลี่ยนจาก Icons.logout_outlined เป็น Icons.logout 
          // เพื่อให้ตรงกับในรูปภาพ ที่เป็นไอคอนแบบทึบตลอดเวลา
          icon: Icon(Icons.logout), 
          activeIcon: Icon(Icons.logout),
          label: 'Logout',
        ),
        // ⬆️⬆️⬆️ จบส่วนที่แก้ไข ⬆️⬆️⬆️
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