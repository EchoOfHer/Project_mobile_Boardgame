import 'package:flutter/material.dart';
import 'feature/request_borrowing.dart';

class GameData {
  final String name;
  final String imageAssetPath;
  final String style;
  final String players;
  final String time;
  final int remaining;

  const GameData({
    required this.name,
    required this.imageAssetPath,
    required this.style,
    required this.players,
    required this.time,
    required this.remaining,
  });
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  final List<GameData> games = const [
    GameData(
      name: 'Castle Panic',
      imageAssetPath: 'image/Castle_Panic.webp',
      style: 'Co-op',
      players: '1-6',
      time: '60 min',
      remaining: 2,
    ),
    GameData(
      name: 'Champions of Hara',
      imageAssetPath: 'image/Champions_of_Hara.webp',
      style: 'Adventure',
      players: '1-4',
      time: '60-90 min',
      remaining: 1,
    ),
    GameData(
      name: 'Defenders of the Wild',
      imageAssetPath: 'image/Defenders_of_the_Wild.webp',
      style: 'Strategy',
      players: '2-4',
      time: '45 min',
      remaining: 3,
    ),
    GameData(
      name: 'Roll Player Adventures',
      imageAssetPath: 'image/Roll_Player_Adventures.webp',
      style: 'RPG',
      players: '1-4',
      time: '90-120 min',
      remaining: 0,
    ),
    GameData(
      name: 'The Captain is Dead',
      imageAssetPath: 'image/The_Captain_is_Dead.webp',
      style: 'Co-op',
      players: '2-7',
      time: '60-90 min',
      remaining: 1,
    ),
    GameData(
      name: 'The Grizzled',
      imageAssetPath: 'image/The_Grizzled.webp',
      style: 'Co-op',
      players: '2-5',
      time: '30 min',
      remaining: 1,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Boardgame List (Mock)'),
        backgroundColor: Colors.orangeAccent,
      ),
      body: ListView.builder(
        itemCount: games.length,
        itemBuilder: (context, index) {
          final game = games[index];
          return Card(
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
              leading: Image.asset(
                game.imageAssetPath,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              ),
              title: Text(game.name),
              subtitle: Text(game.style),
              trailing: Text('Remain: ${game.remaining}'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BorrowGamePage(
                      gameName: game.name,
                      imageAssetPath: game.imageAssetPath,
                      gameStyle: game.style,
                      players: game.players,
                      time: game.time,
                      remaining: game.remaining,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
