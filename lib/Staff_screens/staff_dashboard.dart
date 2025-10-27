import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// Note: Consolidating multiple 'show' imports for the same file is cleaner.
// For this example, I'll assume your staff_main.dart provides these colors.
import 'staff_main.dart'
    show colour_available, colour_borrow, colour_disable, colour_main;

// The original list of game data - kept the original name 'game'
int Borrowed = 0;
int Available = 0;
int Disabled = 0;
List<Map<String, dynamic>> game = [
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

Widget showgame() {
  final List<Widget> widgets = [];
  String? lastGameGroup;

  for (int i = 0; i < game.length; i++) {
    final currentGame = game[i];
    final isNewGroup = lastGameGroup != currentGame['game_group'];

    // Check if the next item has a different group or if it's the last item
    final isLastInGroup =
        i + 1 == game.length ||
        game[i + 1]['game_group'] != currentGame['game_group'];

    // 1. Conditional Group Header
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

    // 3. Conditional Divider
    if (isLastInGroup) {
      widgets.add(
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 10.0),
          child: Divider(height: 1, thickness: 1),
        ),
      );
    }

    // Update the last group for the next iteration
    lastGameGroup = currentGame['game_group'];
  }

  // Returns a Column containing all the dynamic elements
  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: widgets,
  );
}

class StaffDashboard extends StatefulWidget {
  const StaffDashboard({super.key});

  @override
  State<StaffDashboard> createState() => _StaffDashboardState();
}

class _StaffDashboardState extends State<StaffDashboard> {
  @override
  void initState() {
    super.initState();
    // เรียกฟังก์ชันคำนวณสถานะทันทีที่ Widget ถูกสร้าง
    calculate_status();
  }

  void calculate_status() {
    int tempBorrowed = 0;
    int tempDisabled = 0;
    int tempAvailable = 0;
    for (int i = 0; i < game.length; i++) {
      if (game[i]['status'] == 'Borrowed') {
        tempBorrowed += 1;
      } else if (game[i]['status'] == 'Disabled') {
        tempDisabled += 1;
      } else {
        tempAvailable += 1;
      }
    }
    setState(() {
      Borrowed = tempBorrowed;
      Disabled = tempDisabled;
      Available = tempAvailable;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        // The Stack allows the FAB to float over the scrollable content.
        children: [
          // FIX: Wrap the entire content area in a SingleChildScrollView to enable scrolling.
          SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(20),
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
                  // Row of Status Containers (Unchanged)
                  Row(
                    children: [
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
                              '$Borrowed',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 50,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
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
                              '$Available',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 50,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
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
                              Disabled.toString(),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 50,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
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

                  // Manage Board Title (Unchanged)
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

                  // Search TextField (Unchanged)
                  TextField(
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

                  // const SizedBox(height: 10),

                  // The dynamic game list widget is placed here.
                  showgame(),
                ],
              ),
            ),
          ),

          // FloatingActionButton (Unchanged, remains at the bottom right)
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: FloatingActionButton(
                onPressed: () {
                  print('$Disabled');
                },
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
