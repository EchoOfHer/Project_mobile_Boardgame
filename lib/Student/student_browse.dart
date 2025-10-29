// lib/Student/browse_student.dart
import 'package:flutter/material.dart';
import '/Staff/game_data.dart'; // ← gameList
import '/login/login.dart';
import 'student_main.dart' show colour_main;
import 'student_borrowing.dart'; // ← BorrowGamePage

/// Shared _get helper (same as in BorrowGamePage)
dynamic _get(dynamic item, String key) {
  if (item == null) return null;
  if (item is Map<String, dynamic>) return item[key];
  try {
    final obj = item as dynamic;
    switch (key) {
      case 'gameName':
        return obj.gameName;
      case 'gameStyle':
        return obj.gameStyle;
      case 'picPath':
        return obj.picPath;
      case 'status':
        return obj.status;
      case 'minP':
        return obj.minP;
      case 'maxP':
        return obj.maxP;
      case 'gTime':
        return obj.gTime;
      case 'g_link':
        return obj.g_link;
      case 'gameGroup':
        return obj.gameGroup;
      default:
        return null;
    }
  } catch (_) {
    return null;
  }
}

class BrowseStudent extends StatefulWidget {
  const BrowseStudent({super.key});

  @override
  State<BrowseStudent> createState() => _BrowseStudentState();
}

class _BrowseStudentState extends State<BrowseStudent> {
  final TextEditingController _searchController = TextEditingController();
  late List<dynamic> _filteredGames;
  late List<String> categories;
  String selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    _filteredGames = _getUniqueGames(gameList);
    _buildCategories();
    _searchController.addListener(_runFilter);
  }

  @override
  void dispose() {
    _searchController.removeListener(_runFilter);
    _searchController.dispose();
    super.dispose();
  }

  void _buildCategories() {
    final Set<String> styleSet = {};
    for (final g in gameList) {
      final style = _get(g, 'gameStyle')?.toString().trim() ?? '';
      if (style.isNotEmpty) styleSet.add(style);
    }
    categories = ['All', ...styleSet.toList()];
  }

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
    final query = _searchController.text.toLowerCase();
    if (query.isNotEmpty) {
      results = results.where((game) {
        final name = (_get(game, 'gameName') ?? '').toString().toLowerCase();
        return name.contains(query);
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
              // Header
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
                      'Welcome Student',
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
          borderSide: const BorderSide(color: Colors.orange),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Colors.orange),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Colors.orange, width: 2),
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
              setState(() => selectedCategory = category);
              _runFilter(); // ← Fixed: Now updates grid
            },
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 4),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? Colors.orange : Colors.grey[200],
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

        final gameName = _get(game, 'gameName')?.toString() ?? '';
        final gameStyle = _get(game, 'gameStyle')?.toString() ?? '';
        final picPath = _get(game, 'picPath')?.toString() ?? '';
        final gameGroup = _get(game, 'gameGroup')?.toString() ?? '';
        final glink = _get(game, 'g_link')?.toString() ?? '';

        return GestureDetector(
          onTap: () {
            // Inside itemBuilder of GridView
            final gameGroup = _get(game, 'gameGroup')?.toString() ?? '';

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BorrowGamePage(
                  gameName: gameName,
                  imageAssetPath: picPath,
                  gameStyle: gameStyle,
                  players:
                      "${_get(game, 'minP') ?? 0}-${_get(game, 'maxP') ?? 0} peoples",
                  time: "${_get(game, 'gTime') ?? 0} min",
                  glink: glink,
                  gameGroup: gameGroup, // ← REQUIRED
                ),
              ),
            );
          },
          child: GameCard(title: gameName, imagePath: picPath),
        );
      },
    );
  }
}

// === Game Card (unchanged) ===
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
