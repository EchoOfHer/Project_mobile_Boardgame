import 'package:flutter/material.dart';
import 'see_request.dart';
import '/login/login.dart';
import 'HistoryLenderPage.dart';
import 'request_borrowing_lender.dart';
import 'package:boardgame_app/Staff/game_data.dart'; // ← Use shared game data
import '/staff/staff_main.dart' show colour_main, colour_disable;

class BrowseLender extends StatefulWidget {
  const BrowseLender({super.key});

  @override
  State<BrowseLender> createState() => _BrowseLenderState();
}

class _BrowseLenderState extends State<BrowseLender> {
  final TextEditingController _searchController = TextEditingController();
  late List<dynamic> _filteredGames;
  late List<String> categories;
  String selectedCategory = 'All';

  @override
  void initState() {
    super.initState();

    // Initialize with one game per group
    _filteredGames = _getUniqueGames(gameList);

    // Extract unique styles from gameList
    final Set<String> styleSet = <String>{};
    for (final g in gameList) {
      final style = _get(g, 'gameStyle')?.toString().trim() ?? '';
      if (style.isNotEmpty) styleSet.add(style);
    }
    categories = ['All', ...styleSet.toList()];

    _searchController.addListener(_runFilter);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Safely access dynamic fields
  dynamic _get(dynamic item, String key) {
    if (item == null) return null;
    if (item is Map<String, dynamic>) return item[key];

    try {
      switch (key) {
        case 'gameName':
          return (item as dynamic).gameName;
        case 'gameStyle':
          return (item as dynamic).gameStyle;
        case 'picPath':
          return (item as dynamic).picPath;
        case 'minP':
          return (item as dynamic).minP;
        case 'maxP':
          return (item as dynamic).maxP;
        case 'gTime':
          return (item as dynamic).gTime;
        case 'g_link':
          return (item as dynamic).g_link;
        case 'gameGroup':
          return (item as dynamic).gameGroup;
        default:
          return (item as dynamic)[key];
      }
    } catch (_) {
      return null;
    }
  }

  // Get one representative per gameGroup
  List<dynamic> _getUniqueGames(List<dynamic> games) {
    final Map<String, dynamic> uniqueMap = {};
    for (var g in games) {
      final group = _get(g, 'gameGroup')?.toString() ?? '';
      if (group.isNotEmpty && !uniqueMap.containsKey(group)) {
        uniqueMap[group] = g;
      }
    }
    return uniqueMap.values.toList();
  }

  // Filter games
  void _runFilter() {
    List<dynamic> results = List<dynamic>.from(gameList);

    // Filter by category
    if (selectedCategory != 'All') {
      results = results.where((game) {
        final style = (_get(game, 'gameStyle') ?? '').toString().toLowerCase();
        return style == selectedCategory.toLowerCase();
      }).toList();
    }

    // Filter by search
    final String searchQuery = _searchController.text.toLowerCase();
    if (searchQuery.isNotEmpty) {
      results = results.where((game) {
        final name = (_get(game, 'gameName') ?? '').toString().toLowerCase();
        return name.contains(searchQuery);
      }).toList();
    }

    setState(() {
      _filteredGames = _getUniqueGames(results);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          color: Colors.white,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'BOARD GAME SS',
                      style: TextStyle(
                        color: colour_main,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Welcome Lender',
                      style: TextStyle(color: Colors.grey[700], fontSize: 18),
                    ),
                    const SizedBox(height: 20),
                    _buildSearchBar(),
                    const SizedBox(height: 16),
                    _buildCategoryFilters(),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Expanded(child: _buildGameGrid()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Search by game title...',
        suffixIcon: const Icon(Icons.search, color: Colors.grey),
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: colour_main),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: colour_main),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: colour_main, width: 2),
        ),
      ),
    );
  }

  Widget _buildCategoryFilters() {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category == selectedCategory;

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedCategory = category;
              });
              _runFilter();
            },
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 4),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? colour_main : Colors.grey[200],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  category,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGameGrid() {
    if (_filteredGames.isEmpty) {
      return const Center(
        child: Text(
          'No games found.',
          style: TextStyle(color: Colors.grey, fontSize: 18),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 0.75,
      ),
      itemCount: _filteredGames.length,
      itemBuilder: (context, index) {
        final game = _filteredGames[index];

        final String gameName = _get(game, 'gameName')?.toString() ?? '';
        final String picPath = _get(game, 'picPath')?.toString() ?? '';
        final String gameGroup = _get(game, 'gameGroup')?.toString() ?? '';
        final String? glink = _get(game, 'g_link')?.toString(); // Optional

        // Count available copies in group
        final int remaining = gameList.where((g) {
          final gg = _get(g, 'gameGroup')?.toString() ?? '';
          final st = _get(g, 'status')?.toString().toLowerCase() ?? '';
          return gg == gameGroup && st == 'available';
        }).length;

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RequestBorrowingLenderPage(
                  gameName: gameName,
                  imageAssetPath: picPath,
                  gameStyle: _get(game, 'gameStyle')?.toString() ?? '',
                  players:
                      "${_get(game, 'minP') ?? 0}-${_get(game, 'maxP') ?? 0} players",
                  time: "${_get(game, 'gTime') ?? 0} min",
                  gameGroup: gameGroup,
                  glink: glink, // Safe: can be null
                ),
              ),
            );
          },
          child: GameCard(title: gameName, imagePath: picPath),
        );
      },
    );
  }

  void _showLogoutDialog() {
    const Color logoutColor = Color(0xFFFF7C7C);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.logout, size: 60, color: logoutColor),
            const SizedBox(height: 16),
            const Text(
              "Log Out",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: logoutColor,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Are you sure you want to log out?",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                  ),
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text(
                    "Cancel",
                    style: TextStyle(color: Colors.black54),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: logoutColor),
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const Login()),
                      (route) => false,
                    );
                  },
                  child: const Text(
                    "Confirm",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

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
          Expanded(child: _buildImageOrPlaceholder()),
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

  Widget _buildImageOrPlaceholder() {
    if (imagePath.trim().isEmpty) {
      return Container(
        color: Colors.grey[200],
        child: const Icon(Icons.broken_image, size: 48, color: Colors.grey),
      );
    }
    return Image.asset(
      imagePath,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Colors.grey[200],
          child: const Icon(Icons.broken_image, size: 48, color: Colors.grey),
        );
      },
    );
  }
}
