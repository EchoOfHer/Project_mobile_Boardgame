import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// Note: Ensure your 'staff_main.dart' file is in the correct directory
// and exports these color constants.
import 'staff_main.dart'
    show colour_available, colour_borrow, colour_disable, colour_main;

// -----------------------------------------------------------------------------
// Helper Widgets (Built outside the State Class)
// -----------------------------------------------------------------------------

Widget _buildGameCard(Map<String, dynamic> currentGame) {
  final gameStatus = currentGame['status'];
  late Color statusColor;
  late IconData statusIcon;

  // Logic for color and icon based on status
  if (gameStatus == 'Available') {
    statusColor = colour_available;
    statusIcon = Icons.play_disabled;
  } else if (gameStatus == 'Disabled') {
    statusColor = colour_disable;
    statusIcon = FontAwesomeIcons.play;
  } else {
    // Borrowed/Borrowing
    statusColor = colour_borrow;
    statusIcon = FontAwesomeIcons.dice;
  }

  return Card(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
    child: Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 1. The Image
          ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Image.asset(
              currentGame['pic_path'],
              width: 100,
              height: 100,
              fit: BoxFit.cover,
              // Fallback if image path is invalid
              errorBuilder: (context, error, stackTrace) => Container(
                width: 100,
                height: 100,
                color: Colors.grey.shade300,
                child: const Icon(
                  Icons.broken_image,
                  size: 40,
                  color: Colors.grey,
                ),
              ),
            ),
          ),

          const SizedBox(width: 16),

          // 2. The Text Column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  currentGame['game_name'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'ID: ${currentGame['game_id']}',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  'Status: $gameStatus',
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          // 3. The Trailing Icon
          IconButton(
            onPressed: () {},
            icon: Icon(statusIcon, color: statusColor, size: 40),
          ),
          const SizedBox(width: 20),
        ],
      ),
    ),
  );
}

// -----------------------------------------------------------------------------
// Dynamic Game List Widget (MODIFIED to accept the list)
// -----------------------------------------------------------------------------
Widget showgame({required List<Map<String, dynamic>> listToShow}) {
  final List<Widget> widgets = [];
  String? lastGameGroup;

  // Handles the case where the list is empty after filtering
  if (listToShow.isEmpty) {
    return const Padding(
      padding: EdgeInsets.only(top: 30),
      child: Center(
        child: Text(
          'No games found matching your search.',
          style: TextStyle(color: Colors.grey),
        ),
      ),
    );
  }

  for (int i = 0; i < listToShow.length; i++) {
    final currentGame = listToShow[i];
    final nextGameGroup = i + 1 < listToShow.length
        ? listToShow[i + 1]['game_group']
        : null;

    final isNewGroup = lastGameGroup != currentGame['game_group'];
    final isLastInGroup =
        i + 1 == listToShow.length ||
        nextGameGroup != currentGame['game_group'];

    // 1. Conditional Group Header (Title and Edit button)
    if (isNewGroup) {
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 8.0),
          child: Row(
            children: [
              Text(
                currentGame['game_group'],
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(backgroundColor: colour_borrow),
                child: const Text(
                  'Edit',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      // Small spacer between cards of the same group
      widgets.add(const SizedBox(height: 8));
    }

    // 2. The Game Card Widget
    widgets.add(_buildGameCard(currentGame));

    // 3. Conditional Divider (at the end of a group)
    if (isLastInGroup) {
      widgets.add(
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 10.0),
          child: Divider(height: 1, thickness: 1, color: colour_main),
        ),
      );
    }

    lastGameGroup = currentGame['game_group'];
  }

  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: widgets,
  );
}

// -----------------------------------------------------------------------------
// StaffDashboard StatefulWidget and State Class
// -----------------------------------------------------------------------------

class StaffDashboard extends StatefulWidget {
  const StaffDashboard({super.key});

  @override
  State<StaffDashboard> createState() => _StaffDashboardState();
}

class _StaffDashboardState extends State<StaffDashboard> {
  // 🌟 STATE VARIABLES (MUST BE INSIDE State Class)
  int Borrowed = 0;
  int Available = 0;
  int Disabled = 0;
  List<Map<String, dynamic>> _filteredGameList = [];

  // The static game data list
  final List<Map<String, dynamic>> game = const [
    {
      'game_name': 'Castle Panic',
      'game_group': 'Castle Panic',
      'game_id': 1,
      'status': 'Borrowed',
      'pic_path': 'image/Castle_Panic.webp',
    },
    {
      'game_name': 'Castle Panic',
      'game_group': 'Castle Panic',
      'game_id': 2,
      'status': 'Disabled',
      'pic_path': 'image/Castle_Panic.webp',
    },
    {
      'game_name': 'Champions of Hara',
      'game_group': 'Champions of Hara',
      'game_id': 3,
      'status': 'Borrowing',
      'pic_path': 'image/Champions_of_Hara.webp',
    },
    {
      'game_name': 'Defenders of the Wild',
      'game_group': 'Defenders of the Wild',
      'game_id': 4,
      'status': 'Disabled',
      'pic_path': 'image/Defenders_of_the_Wild.webp',
    },
    {
      'game_name': 'Roll Player Adventures',
      'game_group': 'Roll Player Adventures',
      'game_id': 5,
      'status': 'Available',
      'pic_path': 'image/Roll_Player_Adventures.webp',
    },
    {
      'game_name': 'The Captain is Dead',
      'game_group': 'The Captain is Dead',
      'game_id': 6,
      'status': 'Disabled',
      'pic_path': 'image/The_Captain_is_Dead.webp',
    },
    {
      'game_name': 'The Grizzled',
      'game_group': 'The Grizzled',
      'game_id': 7,
      'status': 'Disabled',
      'pic_path': 'image/The_Grizzled.webp',
    },
  ];

  // 🌟 AUTOMATIC STATUS CALCULATION
  @override
  void initState() {
    super.initState();
    _filteredGameList = game;
    calculate_status();
  }

  void calculate_status() {
    int tempBorrowed = 0;
    int tempDisabled = 0;
    int tempAvailable = 0;

    // Calculates status based on the FULL list
    for (int i = 0; i < game.length; i++) {
      if (game[i]['status'] == 'Borrowed' || game[i]['status'] == 'Borrowing') {
        tempBorrowed += 1;
      } else if (game[i]['status'] == 'Disabled') {
        tempDisabled += 1;
      } else {
        tempAvailable += 1;
      }
    }

    // Updates the state variables and refreshes the UI
    setState(() {
      Borrowed = tempBorrowed;
      Disabled = tempDisabled;
      Available = tempAvailable;
    });
  }

  // 🌟 SEARCH FILTERING LOGIC
  void _filterGameList(String query) {
    final filteredList = game.where((item) {
      final gameName = item['game_name'].toString().toLowerCase();
      final searchTerm = query.toLowerCase();

      // If query is empty, it returns true for all items (show all)
      return gameName.contains(searchTerm);
    }).toList();

    setState(() {
      _filteredGameList = filteredList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          // Makes the content scrollable
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Today's Status",
                    style: TextStyle(
                      color: colour_main,
                      fontSize: 30,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Status Containers (Linked to state variables)
                  Row(
                    children: [
                      // BORROWED
                      Container(
                        width: 115,
                        height: 115,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: colour_borrow,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              Borrowed.toString(), // 🌟 Dynamic value
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 50,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text(
                              'Borrowed',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      // AVAILABLE
                      Container(
                        width: 115,
                        height: 115,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: colour_available,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              Available.toString(), // 🌟 Dynamic value
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 50,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text(
                              'Available',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      // DISABLED
                      Container(
                        width: 115,
                        height: 115,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: colour_disable,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              Disabled.toString(), // 🌟 Dynamic value
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 50,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text(
                              'Disabled',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Manage Board Title
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 15.0),
                    child: Text(
                      'Manage Board',
                      style: TextStyle(
                        color: colour_main,
                        fontSize: 25,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  // Search TextField
                  TextField(
                    onChanged: _filterGameList, // 🌟 Calls filter logic
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: colour_main, width: 1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: colour_main, width: 1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: colour_main, width: 1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      suffixIcon: Icon(Icons.search, color: Colors.grey[400]),
                      hintText: 'Search game name . . .',
                      hintStyle: const TextStyle(color: Colors.grey),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Dynamic Game List (Uses the filtered list)
                  showgame(listToShow: _filteredGameList),
                ],
              ),
            ),
          ),

          // FloatingActionButton
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: FloatingActionButton(
                onPressed: () {},
                shape: const CircleBorder(),
                backgroundColor: colour_main,
                child: const Icon(Icons.add, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
