import 'package:flutter/material.dart';
import 'package:boardgame_app/Staff/request_borrowing_staff2.dart';


class StaffBrowse extends StatelessWidget {
  const StaffBrowse({super.key});

  @override
  Widget build(BuildContext context) {
    // ---------- สถานะ (แทน Stateful) ----------
    final searchController = TextEditingController();
    final selectedCategory = ValueNotifier<String>('All');
    final filteredGames = ValueNotifier<List<Map<String, dynamic>>>([]);

    // ---------- ข้อมูลเกม ----------
    final List<Map<String, dynamic>> games = [
      {
        'title': 'Exploding Kittens',
        'image': 'image/Exploding_Kitten.webp',
        'gameStyle': 'Party',
        'players': '2-10 peoples',
        'time': '10 min',
        'remaining': 1,
      },
      {
        'title': 'One Week Werewolf',
        'image': 'image/One_Week_Werewolf.webp',
        'gameStyle': 'Party',
        'players': '3-7 players',
        'time': '10 min',
        'remaining': 3,
      },
      {
        'title': 'Catan',
        'image': 'image/Catan.jpg',
        'gameStyle': 'Strategy',
        'players': '3-4 players',
        'time': '60-120 min',
        'remaining': 2,
      },
      {
        'title': 'Splendor',
        'image': 'image/Splendor.jpg',
        'gameStyle': 'Strategy',
        'players': '2-4 players',
        'time': '30 min',
        'remaining': 0,
      },
      {
        'title': 'Avalon',
        'image': 'image/Avalon.jpg',
        'gameStyle': 'Bluffing',
        'players': '5-10 players',
        'time': '30 min',
        'remaining': 1,
      },
    ];

    final List<String> categories = [
      'All',
      'Family',
      'Party',
      'Bluffing',
      'Abstract',
      'Dice',
      'Strategy',
    ];

    // ---------- ฟังก์ชันกรอง ----------
    void runFilter() {
      final query = searchController.text.toLowerCase();
      final cat = selectedCategory.value;

      var results = List<Map<String, dynamic>>.from(games);

      if (cat != 'All') {
        results = results
            .where((g) => g['gameStyle']!.toLowerCase() == cat.toLowerCase())
            .toList();
      }
      if (query.isNotEmpty) {
        results = results
            .where((g) => g['title']!.toLowerCase().contains(query))
            .toList();
      }

      filteredGames.value = results;
    }

    // เริ่มต้นแสดงเกมทั้งหมด
    WidgetsBinding.instance.addPostFrameCallback((_) {
      filteredGames.value = List.from(games);
    });

    // ---------- UI ----------
    return SafeArea(                 // <-- ยังคงมี SafeArea เหมือนเดิม
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            // ----- Header -----
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
                    'Welcome Staff',
                    style: TextStyle(color: Colors.grey[700], fontSize: 18),
                  ),
                  const SizedBox(height: 20),

                  // Search bar
                  TextField(
                    controller: searchController,
                    onChanged: (_) => runFilter(),
                    decoration: InputDecoration(
                      hintText: 'Search by game title...',
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
                  ),
                  const SizedBox(height: 20),

                  // Category filters
                  SizedBox(
                    height: 40,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final cat = categories[index];
                        return ValueListenableBuilder<String>(
                          valueListenable: selectedCategory,
                          builder: (context, selected, _) {
                            final isSelected = cat == selected;
                            return GestureDetector(
                              onTap: () {
                                selectedCategory.value = cat;
                                runFilter();
                              },
                              child: Container(
                                margin: const EdgeInsets.only(right: 8.0),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 8),
                                decoration: BoxDecoration(
                                  color:
                                      isSelected ? Colors.orange : Colors.grey[200],
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Center(
                                  child: Text(
                                    cat,
                                    style: TextStyle(
                                      color:
                                          isSelected ? Colors.white : Colors.black54,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ----- Game Grid -----
            Expanded(
              child: ValueListenableBuilder<List<Map<String, dynamic>>>(
                valueListenable: filteredGames,
                builder: (context, gamesList, _) {
                  if (gamesList.isEmpty) {
                    return const Center(
                      child: Text(
                        'No games found.',
                        style: TextStyle(color: Colors.grey, fontSize: 18),
                      ),
                    );
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.75,
                    ),
                    itemCount: gamesList.length,
                    itemBuilder: (context, index) {
                      final game = gamesList[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => RequestBorrowingStaffPage(
                                gameName: game['title']!,
                                imageAssetPath: game['image']!,
                                gameStyle: game['gameStyle']!,
                                players: game['players']!,
                                time: game['time']!,
                                remaining: game['remaining']!,
                              ),
                            ),
                          );
                        },
                        child: GameCard(
                          title: game['title']!,
                          imagePath: game['image']!,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------
// GameCard (ไม่เปลี่ยนแปลง)
class GameCard extends StatelessWidget {
  final String title;
  final String imagePath;

  const GameCard({super.key, required this.title, required this.imagePath});

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
              errorBuilder: (_, __, ___) => Container(
                color: Colors.grey[200],
                child: const Icon(Icons.broken_image, color: Colors.grey),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}