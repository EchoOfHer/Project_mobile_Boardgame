import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:boardgame_app/Staff/Add_New_Game.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'EditGame.dart';
import 'staff_main.dart'
    show colour_available, colour_borrow, colour_disable, colour_main;

import 'game_data.dart';

final String url = '10.0.2.2:3000';

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
  final String authToken;
  final VoidCallback? onEditPressed;
  const GameCard({
    super.key,
    required this.game,
    required this.onStatusTap,
    required this.authToken,
    this.onEditPressed,
  });

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
              child: Image.network(
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
              onPressed: isBorrowed ? null
                  : () async {
                      final newStatus = game.status == 'Available'
                          ? 'Disabled'
                          : 'Available';
                      final success = await _updateGameStatus(
                        game.gameId,
                        newStatus,
                      );
                      if (success && context.mounted) {
                        _showStatusPopup(context, newStatus);
                      }
                      onStatusTap?.call();
                    },
              icon: Icon(config.icon, color: config.color, size: 40),
              tooltip: isBorrowed
                  ? 'Cannot change while borrowed'
                  : 'Toggle Available/Disabled',
            ),
            const SizedBox(width: 8),

    // เพิ่มปุ่ม Edit ตรงนี้
    IconButton(
      onPressed: onEditPressed,
      icon: const Icon(Icons.edit, color: Colors.blue, size: 32),
      tooltip: 'Edit Game',
    ),
            const SizedBox(width: 20),
          ],
        ),
      ),
    );
  }

  void _showStatusPopup(BuildContext context, String status) {
    final isEnabled = status == 'Available';
    late BuildContext dialogContext;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        dialogContext = ctx; // เก็บ context ของ dialog
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isEnabled ? Icons.check_circle : Icons.cancel,
                    color: isEnabled ? Colors.green : Colors.red,
                    size: 80,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isEnabled ? 'Enabled' : 'Disabled',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isEnabled ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (dialogContext.mounted) {
        Navigator.of(dialogContext).pop();
      }
    });
  }

  // --- อัปเดตสถานะไป Backend ---
  Future<bool> _updateGameStatus(int inventoryId, String newStatus) async {
  try {
    final response = await http.put(
      Uri.parse('http://$url/staff/game/status/$inventoryId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken', // ใช้ได้!
      },
      body: jsonEncode({'status': newStatus}),
    );

    print("Update: ${response.statusCode} ${response.body}");
    return response.statusCode == 200 && jsonDecode(response.body)['success'] == true;
  } catch (e) {
    print("Update error: $e");
    return false;
  }
}

  ({Color color, IconData icon}) _getStatusConfig(
    String status,
    bool isBorrowed,
  ) {
    if (isBorrowed || status == 'Borrowing')
      return (color: Colors.grey.shade400, icon: Icons.lock_outline);
    return switch (status) {
      'Available' => (color: colour_available, icon: Icons.play_circle_fill),
      'Disabled' => (color: colour_disable, icon: FontAwesomeIcons.ban),
      _ => (color: Colors.grey, icon: Icons.help),
    };
  }
}

class GroupedGameList extends StatelessWidget {
  final List<GameItem> games;
  final Function(int gameId) onStatusToggle;
  final String authToken; // เพิ่ม

  const GroupedGameList({
    super.key,
    required this.games,
    required this.onStatusToggle,
    required this.authToken, // เพิ่ม
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
                // ElevatedButton(
                //   onPressed: () async {
                //     final updatedGame = await Navigator.push(
                //       context,
                //       MaterialPageRoute(
                //         builder: (_) => EditGame(
                //           game: game,
                //           groupCount: groupCount,
                //           onCountChanged: (newCount) {
                //             final parent = context
                //                 .findAncestorStateOfType<
                //                   _StaffDashboardState
                //                 >();
                //             parent?.adjustGroupCount(game.gameGroup, newCount);
                //           },
                //         ),
                //       ),
                //     );
                //     if (updatedGame != null && context.mounted) {
                //       final parent = context
                //           .findAncestorStateOfType<_StaffDashboardState>();
                //       parent?.updateGame(updatedGame);
                //     }
                //   },
                //   style: ElevatedButton.styleFrom(
                //     backgroundColor: colour_borrow,
                //   ),
                //   child: const Text(
                //     'Edit',
                //     style: TextStyle(color: Colors.white),
                //   ),
                // ),
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
    onEditPressed: () async {
      // ดึงข้อมูลกลุ่มทั้งหมด
      final group = games.where((g) => g.gameGroup == game.gameGroup).toList();
      final groupCount = group.length;

      final updatedGame = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => EditGame(
            game: game,
            groupCount: groupCount,
            onCountChanged: (newCount) {
              // เรียกกลับไปที่ StaffDashboard
              final parent = context.findAncestorStateOfType<_StaffDashboardState>();
              parent?.adjustGroupCount(game.gameGroup, newCount);
            },
          ),
        ),
      );

      if (updatedGame != null && context.mounted) {
        final parent = context.findAncestorStateOfType<_StaffDashboardState>();
        parent?.updateGame(updatedGame);
      }
    },
    authToken: authToken,
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
  final String authToken; // เพิ่ม
  const StaffDashboard({super.key, required this.authToken});

  @override
  State<StaffDashboard> createState() => _StaffDashboardState();
}

class _StaffDashboardState extends State<StaffDashboard> {
  late List<GameItem> _filteredGames;
  int borrowedCount = 0, availableCount = 0, disabledCount = 0;
  bool _isLoading = true;
  @override
  void initState() {
    super.initState();
    _filteredGames = [];
    gameList.clear(); // ล้างข้อมูลเก่า
    fetchDashboardData(); // เรียกแค่ครั้งเดียว
  }

  Future<void> fetchDashboardData() async {
  if (!mounted) return;
  setState(() => _isLoading = true);

 try {
    print("Fetching dashboard...");
    final response = await http.get(
      Uri.parse('http://$url/staff/dashboard'),
      headers: {
        'Authorization': 'Bearer ${widget.authToken}', // เพิ่มบรรทัดนี้
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print("Dashboard response: $data");

      if (data['success'] == true) {
        final summary = data['summary'] ?? {};
        setState(() {
          borrowedCount = summary['pending_bookings'] ?? 0;
          availableCount = summary['approved_bookings'] ?? 0;
          disabledCount = summary['rejected_bookings'] ?? 0;
        });
      }
    }

    await fetchGames();
  } catch (e) {
    print("Dashboard ERROR: $e");
    await fetchGames();
  } finally {
    if (mounted) setState(() => _isLoading = false);
  }
}

  Future<void> fetchGames() async {
    try {
      print("Fetching games from http://$url/staff/games...");
      final response = await http.get(
        Uri.parse('http://$url/staff/games'),
        headers: {'Authorization': 'Bearer ${widget.authToken}'},
      );

      print("Response status: ${response.statusCode}");
      if (response.statusCode != 200) {
        print("API Error: ${response.body}");
        return;
      }

      final data = jsonDecode(response.body);
      if (!data['success']) {
        print("API not success: ${data['message']}");
        return;
      }

      final List<dynamic> gamesJson = data['games'];
      print("Found ${gamesJson.length} game groups");

      final List<GameItem> loadedGames = [];

      for (var json in gamesJson) {
        final List<String> ids =
            (json['itemIds'] as List?)?.cast<String>() ?? [];
        final List<String> statuses =
            (json['itemStatuses'] as List?)?.cast<String>() ?? [];

        if (ids.isEmpty) continue;

        for (int i = 0; i < ids.length; i++) {
          final status = i < statuses.length ? statuses[i] : 'Available';
          loadedGames.add(
            GameItem(
              gameId: int.tryParse(ids[i]) ?? 0,
              gameName: json['gameName']?.toString() ?? 'Unknown',
              gameGroup: json['gameName']?.toString() ?? 'Unknown',
              gameStyle: (json['styleId'] ?? 0).toString(),
              gTime: int.tryParse(json['gameTime'].toString()) ?? 60,
              minP: int.tryParse(json['minPlayers'].toString()) ?? 1,
              maxP: int.tryParse(json['maxPlayers'].toString()) ?? 1,
              g_link: json['howToLink']?.toString() ?? '',
              picPath: 'http://$url/${json['picPath']}',
              status: _mapStatus(status),
            ),
          );
        }
      }

      print("Loaded ${loadedGames.length} GameItems");

      setState(() {
        gameList
          ..clear()
          ..addAll(loadedGames)
          ..sort((a, b) => a.gameGroup.compareTo(b.gameGroup));
        _filteredGames = List.from(gameList);
        _updateStatusCounts();
      });
    } catch (e) {
      print("Load games ERROR: $e");
    }
  }

  String _mapStatus(String? s) {
    final status = (s ?? '').toLowerCase().trim();
    return switch (status) {
      'borrowing' => 'Borrowing',
      'available' => 'Available',
      'disabled' => 'Disabled',
      _ => s ?? 'Available', // ใช้ raw status ถ้าไม่ match
    };
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
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else
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
                    authToken: widget.authToken, // ส่งต่อ
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
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AddNewGame()),
                  );
                  if (result is Map &&
                      result['game_name']?.toString().isNotEmpty == true) {
                    _addNewGames(result);
                    await fetchGames(); // รีเฟรช
                  }
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
