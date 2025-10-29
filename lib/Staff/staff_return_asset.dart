import 'package:flutter/material.dart';

class StaffReturnAsset extends StatefulWidget {
  const StaffReturnAsset({super.key});

  @override
  State<StaffReturnAsset> createState() => _StaffReturnAssetState();
}

// 2. ย้าย Logic, State, และข้อมูลทั้งหมดมาไว้ใน State class นี้
class _StaffReturnAssetState extends State<StaffReturnAsset> {
  List<Map<String, dynamic>> borrowedGames = [
    {
      'title': 'Exploding kittens',
      'id': '0002',
      'from': 'Anonymous',
      'image': 'image/Castle_Panic.webp', 
      'returned': false,
    },
    {
      'title': 'Catan',
      'id': '0003',
      'from': 'Anonymous',
      'image': 'image/Champions_of_Hara.webp', 
      'returned': false,
    },
    {
      'title': 'One week werewolf',
      'id': '0005',
      'from': 'Anonymous',
      'image': 'image/Defenders_of_the_Wild.webp', 
      'returned': false,
    },
  ];
  String searchQuery = "";
  int remainingCount = 0;

  @override
  void initState() {
    super.initState();
    remainingCount = borrowedGames.where((game) => !game['returned']).length;
  }

  void markAsReturned(Map<String, dynamic> game) {
    setState(() {
      borrowedGames.remove(game);
      remainingCount = borrowedGames.where((g) => !g['returned']).length;
    });

    // ⭐️ ใช้ ScaffoldMessenger.of(context) ได้เลย เพราะ StaffMain มี Scaffold รองรับอยู่แล้ว
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("${game['title']} has been returned!"),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // 3. ย้าย build method มา (แต่ตัด Scaffold, AppBar, BottomNav ออก)
  @override
  Widget build(BuildContext context) {
    final filteredList = borrowedGames
        .where((game) => game['title']
            .toString()
            .toLowerCase()
            .contains(searchQuery.toLowerCase()))
        .toList();

    // ⭐️ คืนค่าเป็น SafeArea + Padding (เหมือนหน้า History)
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 4. เพิ่ม Title (เพราะเราลบ AppBar) - ใช้สไตล์เดียวกับหน้า History
            const Text(
              "Return Asset",
              style: TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.bold,
                fontSize: 26,
              ),
            ),
            const SizedBox(height: 12),

            // Search bar (ย้ายมาจาก body)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                  )
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, color: Colors.orange),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        hintText: "Search",
                        border: InputBorder.none,
                      ),
                      onChanged: (value) {
                        setState(() => searchQuery = value);
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // จำนวน asset ที่ยังไม่คืน (ย้ายมาจาก body)
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              transitionBuilder: (child, animation) =>
                  ScaleTransition(scale: animation, child: child),
              child: Text(
                "Assets waiting to return: $remainingCount",
                key: ValueKey<int>(remainingCount),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.orange,
                ),
              ),
            ),
            const SizedBox(height: 10),

            Text(
              "Game on loan (${filteredList.length})...",
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 10),

            // ListView (ย้ายมาจาก body)
            Expanded(
              child: filteredList.isEmpty
                  ? const Center(
                      child: Text(
                        "All assets have been returned 🎉",
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    )
                  : ListView.builder(
                      itemCount: filteredList.length,
                      itemBuilder: (context, index) {
                        final game = filteredList[index];
                        return buildGameCard(game);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // 5. ย้าย helper function (buildGameCard) มาไว้ในนี้ด้วย
  Widget buildGameCard(Map<String, dynamic> game) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                game['image'],
                width: 70,
                height: 90,
                fit: BoxFit.cover,
                // ⭐️ จัดการ Error หากโหลดรูปไม่ได้
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 70,
                    height: 90,
                    color: Colors.grey[200],
                    child: const Icon(Icons.broken_image, color: Colors.grey),
                  );
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    game['title'],
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text("ID : ${game['id']}"),
                  Text("From : ${game['from']}"),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Text("Mark as "),
                      const SizedBox(width: 5),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.tealAccent[700],
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () => markAsReturned(game),
                        child: const Text("Return"),
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