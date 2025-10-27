import 'package:flutter/material.dart';

class ReturnAssetPage extends StatefulWidget {
  const ReturnAssetPage({super.key});

  @override
  State<ReturnAssetPage> createState() => _ReturnAssetPageState();
}

class _ReturnAssetPageState extends State<ReturnAssetPage>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> borrowedGames = [
    {
      'title': 'Exploding kittens',
      'id': '0002',
      'from': 'Anonymous',
      'image': 'image/Castle_Panic.jpeg',
      'returned': false,
    },
    {
      'title': 'Catan',
      'id': '0003',
      'from': 'Anonymous',
      'image': 'image/Champions_of_Hara.jpeg',
      'returned': false,
    },
    {
      'title': 'One week werewolf',
      'id': '0005',
      'from': 'Anonymous',
      'image': 'image/Defenders_of_the_Wild.jpeg',
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

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("${game['title']} has been returned!"),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredList = borrowedGames
        .where((game) => game['title']
            .toString()
            .toLowerCase()
            .contains(searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          "Return Asset",
          style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.history_outlined), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.qr_code_outlined), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.people_outline), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.logout_outlined), label: ''),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search bar
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

            // จำนวน asset ที่ยังไม่คืน พร้อม animation
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
