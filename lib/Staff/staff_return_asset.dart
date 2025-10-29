import 'package:flutter/material.dart';
import 'staff_main.dart' show colour_available, colour_main;
import 'game_data.dart'; // <<< Ensure this import path is correct

class StaffReturnAsset extends StatefulWidget {
  const StaffReturnAsset({super.key});

  @override
  State<StaffReturnAsset> createState() => _StaffReturnAssetState();
}

class _StaffReturnAssetState extends State<StaffReturnAsset> {
  // 1. ⭐️ CORRECT TYPE DECLARATION: This must be List<GameItem>
  //    (The previous list of Maps was REMOVED/commented out)
  List<GameItem> borrowedGames = [];

  String searchQuery = "";

  @override
  void initState() {
    super.initState();

    // 2. ⭐️ CORRECT INITIALIZATION: Filter the global gameList.
    //    This filters the List<GameItem> and assigns the result to borrowedGames.
    borrowedGames = gameList
        .where((game) => game.status == 'Borrowing')
        .toList();
  }

  // Function now accepts a GameItem object
  void markAsReturned(GameItem game) {
    // 1. UPDATE THE GLOBAL LIST (gameList)
    final itemToReturn = gameList.firstWhere(
      (item) => item.gameId == game.gameId,
    );

    // Action: Change status to 'Available'
    itemToReturn.status = 'Available';

    // 2. UPDATE THE LOCAL STATE (borrowedGames)
    setState(() {
      // Remove the returned game from the local list displayed on this screen
      borrowedGames.removeWhere((g) => g.gameId == game.gameId);
    });

    // Show SnackBar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "${game.gameName} (ID: ${game.gameId}) has been returned and is now Available!",
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // The build method and buildGameCard widget use the correct GameItem properties:
  // game.gameName, game.gameId, game.picPath, etc., which solves all map access errors.

  @override
  Widget build(BuildContext context) {
    // ... (Code that uses filteredList.length and ListView.builder remains correct)
    final filteredList = borrowedGames
        .where(
          (game) => game.gameName.toString().toLowerCase().contains(
            searchQuery.toLowerCase(),
          ),
        )
        .toList();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ... (Other widgets)
            const Text(
              "Return Asset",
              style: TextStyle(
                color: colour_main,
                fontWeight: FontWeight.w600,
                fontSize: 30,
              ),
            ),
            const SizedBox(height: 30),
            TextField(
              // The InputDecoration must NOT be const if it uses a non-const variable like colour_main.
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                // 1. 'border' is the general default state
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30), // Standard radius
                  borderSide: BorderSide(color: colour_main),
                ),
                // 2. 'enabledBorder' defines the look when the field is NOT focused
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: colour_main),
                ),
                // 3. 'focusedBorder' defines the look when the field IS focused
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(
                    color: colour_main,
                    width: 2,
                  ), // Thicker border when focused
                ),
                hintText: "Search",
                hintStyle: const TextStyle(color: Colors.grey),
                suffixIcon: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
                  child: Icon(Icons.search, color: Colors.grey[400]),
                ),
                // ⭐️ FIX: The conflicting 'border: InputBorder.none,' was removed from here.
              ),
              onChanged: (value) {
                setState(() => searchQuery = value);
              },
            ),
            const SizedBox(height: 20),

            Text(
              "Assets waiting to return (${filteredList.length})...",
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

  Widget buildGameCard(GameItem game) {
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
                game.picPath,
                width: 125,
                height: 125,
                fit: BoxFit.cover,
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
                    game.gameName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text("ID : ${game.gameId}"),
                  Text("Borrowed by : Anonymous"),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Text(
                        "Mark as ",
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(width: 5),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colour_available,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
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
