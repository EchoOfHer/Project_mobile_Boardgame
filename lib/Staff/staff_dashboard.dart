// file: staff_dashboard.dart

import 'package:boardgame_app/Staff/Add_New_Game.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'EditGame.dart';
import 'staff_main.dart'
    show colour_available, colour_borrow, colour_disable, colour_main;
// 👇 1. Import the data model and the mutable global list
import 'game_data.dart';

class StatusCard extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  const StatusCard({
    super.key,
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 115,
      height: 115,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: color,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            count.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 50,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class GameCard extends StatelessWidget {
  final GameItem game;
  final VoidCallback? onStatusTap;
  const GameCard({super.key, required this.game, required this.onStatusTap});

  @override
  Widget build(BuildContext context) {
    final isBorrowed = game.status == 'Borrowed' || game.status == 'Borrowing';
    final config = _getStatusConfig(game.status, isBorrowed);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                game.picPath,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    game.gameName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'ID: ${game.gameId}',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Status: ${game.status}',
                    style: TextStyle(
                      color: config.color,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: isBorrowed ? null : onStatusTap,
              icon: Icon(config.icon, color: config.color, size: 40),
              tooltip: isBorrowed
                  ? 'Cannot change while borrowed'
                  : 'Toggle Available/Disabled',
            ),
            const SizedBox(width: 20),
          ],
        ),
      ),
    );
  }

  ({Color color, IconData icon}) _getStatusConfig(
    String status,
    bool isBorrowed,
  ) {
    if (isBorrowed)
      return (color: Colors.grey.shade400, icon: Icons.lock_outline);
    return switch (status) {
      'Available' => (color: colour_available, icon: Icons.play_disabled),
      'Disabled' => (color: colour_disable, icon: FontAwesomeIcons.play),
      _ => (color: Colors.grey, icon: Icons.help),
    };
  }
}

class GroupedGameList extends StatelessWidget {
  final List<GameItem> games;
  final Function(int gameId) onStatusToggle;

  const GroupedGameList({
    super.key,
    required this.games,
    required this.onStatusToggle,
  });

  @override
  Widget build(BuildContext context) {
    if (games.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 30),
        child: Center(
          child: Text('No games found.', style: TextStyle(color: Colors.grey)),
        ),
      );
    }

    final List<Widget> children = [];
    String? lastGroup;

    for (int i = 0; i < games.length; i++) {
      final game = games[i];
      final isNewGroup = lastGroup != game.gameGroup;

      final isLastInGroup =
          i == games.length - 1 || games[i + 1].gameGroup != game.gameGroup;

      if (isNewGroup) {
        final group = games
            .where((g) => g.gameGroup == game.gameGroup)
            .toList();
        final groupCount = group.length;

        children.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              children: [
                Text(
                  game.gameGroup,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () async {
                    final updatedGame = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditGame(
                          game: game,
                          groupCount: groupCount,
                          onCountChanged: (newCount) {
                            final parent = context
                                .findAncestorStateOfType<
                                  _StaffDashboardState
                                >();
                            parent?.adjustGroupCount(game.gameGroup, newCount);
                          },
                        ),
                      ),
                    );
                    if (updatedGame != null && context.mounted) {
                      final parent = context
                          .findAncestorStateOfType<_StaffDashboardState>();
                      parent?.updateGame(updatedGame);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colour_borrow,
                  ),
                  child: const Text(
                    'Edit',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        );
      } else if (i > 0) {
        children.add(const SizedBox(height: 8));
      }

      children.add(
        GameCard(
          key: ValueKey(game.gameId),
          game: game,
          onStatusTap: () => onStatusToggle(game.gameId),
        ),
      );

      if (isLastInGroup) {
        children.add(
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10.0),
            child: Divider(height: 1, thickness: 1, color: colour_main),
          ),
        );
      }
      lastGroup = game.gameGroup;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    );
  }
}

class StaffDashboard extends StatefulWidget {
  const StaffDashboard({super.key});
  @override
  State<StaffDashboard> createState() => _StaffDashboardState();
}

class _StaffDashboardState extends State<StaffDashboard> {
  late List<GameItem> _filteredGames;
  int borrowedCount = 0, availableCount = 0, disabledCount = 0;

  @override
  void initState() {
    super.initState();

    gameList.sort((a, b) => a.gameGroup.compareTo(b.gameGroup));

    _filteredGames = List.from(gameList);
    _updateStatusCounts();
  }

  void _updateStatusCounts() {
    borrowedCount = gameList
        .where((g) => g.status == 'Borrowed' || g.status == 'Borrowing')
        .length;
    availableCount = gameList.where((g) => g.status == 'Available').length;
    disabledCount = gameList.where((g) => g.status == 'Disabled').length;
    if (mounted) setState(() {});
  }

  void _filterGames(String query) {
    setState(() {
      _filteredGames = query.isEmpty
          ? List.from(gameList)
          : gameList
                .where(
                  (g) => g.gameName.toLowerCase().contains(query.toLowerCase()),
                )
                .toList();
    });
  }

  void _toggleAvailableDisabled(int gameId) {
    final game = gameList.firstWhere((g) => g.gameId == gameId);
    if (game.status == 'Borrowed' || game.status == 'Borrowing') return;
    setState(() {
      game.status = game.status == 'Available' ? 'Disabled' : 'Available';
      _updateStatusCounts();
    });
  }

  void updateGame(GameItem updatedGame) {
    final oldGroup = gameList
        .firstWhere((g) => g.gameId == updatedGame.gameId)
        .gameGroup;
    setState(() {
      for (int i = 0; i < gameList.length; i++) {
        if (gameList[i].gameGroup == oldGroup) {
          gameList[i] = GameItem(
            gameId: gameList[i].gameId,
            gameName: updatedGame.gameName,
            gameGroup: updatedGame.gameGroup,
            gameStyle: updatedGame.gameStyle,
            gTime: updatedGame.gTime,
            minP: updatedGame.minP,
            maxP: updatedGame.maxP,
            picPath: gameList[i].picPath,
            g_link: updatedGame.g_link,
            status: gameList[i].status,
          );
        }
      }

      gameList.sort((a, b) => a.gameGroup.compareTo(b.gameGroup));
      _filteredGames = List.from(gameList);
      _updateStatusCounts();
    });
  }

  void adjustGroupCount(String groupName, int newCount) {
    final currentGames = gameList
        .where((g) => g.gameGroup == groupName)
        .toList();
    final currentCount = currentGames.length;
    final borrowedCount = currentGames
        .where((g) => g.status == 'Borrowed' || g.status == 'Borrowing')
        .length;

    if (newCount < borrowedCount) return;

    if (newCount > currentCount) {
      final maxId = gameList.isEmpty
          ? 0
          : gameList.map((g) => g.gameId).reduce((a, b) => a > b ? a : b);
      final baseId = maxId + 1;
      final first = currentGames.first;

      final newItems = <GameItem>[];
      for (int i = currentCount; i < newCount; i++) {
        final newGame = GameItem(
          gameId: baseId + (i - currentCount),
          gameName: first.gameName,
          gameGroup: groupName,
          gameStyle: first.gameStyle,
          gTime: first.gTime,
          minP: first.minP,
          maxP: first.maxP,
          picPath: first.picPath,
          g_link: first.g_link,
          status: 'Available',
        );
        newItems.add(newGame);
      }

      final groupStartIndex = gameList.indexWhere(
        (g) => g.gameGroup == groupName,
      );
      final groupEndIndex = groupStartIndex + currentCount;

      gameList.insertAll(groupEndIndex, newItems);
    } else if (newCount < currentCount) {
      final toRemove = currentGames
          .where((g) => g.status != 'Borrowed' && g.status != 'Borrowing')
          .toList();

      final removeCount = currentCount - newCount;
      if (toRemove.length < removeCount) return;

      toRemove.sort((a, b) => b.gameId.compareTo(a.gameId));
      for (int i = 0; i < removeCount; i++) {
        final idToRemove = toRemove[i].gameId;
        gameList.removeWhere((g) => g.gameId == idToRemove);
      }
    }

    setState(() {
      _filteredGames = List.from(gameList);
      _updateStatusCounts();
    });
  }

  void _addNewGames(Map newGameData) {
    // Safely parse count, default to 1
    final count =
        int.tryParse(newGameData['game_count']?.toString() ?? '1') ?? 1;
    final maxId = gameList.isEmpty
        ? 0
        : gameList.map((g) => g.gameId).reduce((a, b) => a > b ? a : b);
    final baseId = maxId + 1;

    final String gameName = newGameData['game_name']?.toString() ?? 'Unknown';

    final String link = newGameData['game_how2']?.toString() ?? '';
    final String picPath =
        'image/${newGameData['game_imageP'] ?? 'default.jpg'}';

    for (int i = 0; i < count; i++) {
      gameList.add(
        GameItem(
          gameName: gameName,
          gameGroup: gameName,
          gameStyle: newGameData['game_style']?.toString() ?? '',
          gameId: baseId + i,
          minP: int.tryParse(newGameData['min_P'].toString()) ?? 1,
          maxP: int.tryParse(newGameData['max_P'].toString()) ?? 1,
          gTime: int.tryParse(newGameData['game_time'].toString()) ?? 60,
          status: 'Available',
          picPath: picPath,
          g_link: link,
        ),
      );
    }

    gameList.sort((a, b) => a.gameGroup.compareTo(b.gameGroup));

    setState(() {
      _filteredGames = List.from(gameList);
      _updateStatusCounts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          SingleChildScrollView(
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
                Row(
                  children: [
                    StatusCard(
                      label: 'Borrowed',
                      count: borrowedCount,
                      color: colour_borrow,
                    ),
                    const Spacer(),
                    StatusCard(
                      label: 'Available',
                      count: availableCount,
                      color: colour_available,
                    ),
                    const Spacer(),
                    StatusCard(
                      label: 'Disabled',
                      count: disabledCount,
                      color: colour_disable,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  'Manage Board',
                  style: TextStyle(
                    color: colour_main,
                    fontSize: 25,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  onChanged: _filterGames,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(color: colour_main),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(color: colour_main),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(color: colour_main, width: 2),
                    ),
                    hintText: 'Search game name . . .',
                    hintStyle: const TextStyle(color: Colors.grey),
                    suffixIcon: Icon(Icons.search, color: Colors.grey[400]),
                  ),
                ),
                const SizedBox(height: 20),
                GroupedGameList(
                  games: _filteredGames,
                  onStatusToggle: _toggleAvailableDisabled,
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: FloatingActionButton(
                backgroundColor: colour_main,
                shape: const CircleBorder(),
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AddNewGame()),
                  );
                  if (result is Map &&
                      result['game_name']?.toString().isNotEmpty == true)
                    _addNewGames(result);
                },
                child: const Icon(Icons.add, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
