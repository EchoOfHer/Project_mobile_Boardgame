import 'package:flutter/material.dart';

const colour_main = Color(0xFFFF8000);
const colour_available = Color(0xFF729382);
const colour_disable = Color(0xFFFF7C7C);
const colour_borrow = Color(0xFFEFA34B);

class StaffDashboard extends StatefulWidget {
  const StaffDashboard({super.key});

  @override
  State<StaffDashboard> createState() => _StaffDashboardState();
}

class _StaffDashboardState extends State<StaffDashboard> {
  // Corrected Dart syntax for a List of Maps
  List<Map<String, dynamic>> game = [
    {
      'game_name': 'Castle Panic',
      'game_group': 'Castle Panic',
      'game_id': 0001,
      'status': 'Disable',
      'pic_path': 'image/Castle_Panic.webp',
    },
    {
      'game_name': 'Castle Panic',
      'game_group': 'Castle Panic',
      'game_id': 0002,
      'status': 'Disable',
      'pic_path': 'image/Champions_of_Hara.webp',
    },
    {
      'game_name': 'Champions of Hara',
      'game_group': 'Champions of Hara',
      'game_id': 0003,
      'status': 'Disable',
      'pic_path': 'image/Champions_of_Hara.webp',
    },
    {
      'game_name': 'Defenders of the Wild',
      'game_group': 'Defenders of the Wild',
      'game_id': 0004,
      'status': 'Disable',
      'pic_path': 'image/Defenders_of_the_Wild.webp',
    },
    {
      'game_name': 'Roll Player Adventures',
      'game_group': 'Roll Player Adventures',
      'game_id': 0005,
      'status': 'Disable',
      'pic_path': 'image/Roll_Player_Adventures.webp',
    },
    {
      'game_name': 'The Captain is Dead',
      'game_group': 'The Captain is Dead',
      'game_id': 0006,
      'status': 'Disable',
      'pic_path': 'image/The_Captain_is_Dead.webp',
    },
    {
      'game_name': 'The Grizzled',
      'game_group': 'The Grizzled',
      'game_id': 0007,
      'status': 'Disable',
      'pic_path': 'image/The_Grizzled.webp',
    },
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: ListView(
            children: [
              Text(
                "Today's Status",
                style: TextStyle(
                  color: colour_main,
                  fontSize: 35,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 20),
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
                          '12',
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
                  Spacer(),
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
                          '12',
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
                  Spacer(),
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
                          '12',
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
              SizedBox(height: 10),
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
              TextField(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white, // Light purple background
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
                  hintStyle: TextStyle(color: Colors.grey),
                ),
              ),
              SizedBox(height: 20),
              Row(children: [Text('Game')]),
            ],
          ),
        ),
      ),
    );
  }
}
