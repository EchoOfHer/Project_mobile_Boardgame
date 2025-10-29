import 'package:flutter/material.dart';
import 'package:boardgame_app/Staff/request_borrowing_staff.dart';
import 'game_data.dart';
import '/login/login.dart';
import 'package:boardgame_app/Staff/HistoryStaffPage.dart';

class StaffBrowse extends StatefulWidget {
  const StaffBrowse({super.key});

  @override
  State<StaffBrowse> createState() => _StaffBrowseState();
}

class _StaffBrowseState extends State<StaffBrowse> {
  final TextEditingController _searchController = TextEditingController();
  late List<dynamic> _filteredGames;
  late List<String> categories;
  String selectedCategory = 'All';

  @override
  void initState() {
    super.initState();

    // Start with one representative per group
    _filteredGames = _getUniqueGames(gameList);

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

  // Helper function to get attribute safely
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
        case 'status':
          return (item as dynamic).status;
        case 'minP':
          return (item as dynamic).minP;
        case 'maxP':
          return (item as dynamic).maxP;
        case 'gTime':
          return (item as dynamic).gTime;
        case 'gameGroup':
          return (item as dynamic).gameGroup;
        default:
          return (item as dynamic)[key];
      }
    } catch (_) {
      return null;
    }
  }

  // ✅ This ensures only one game per gameGroup
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

  // Filtering logic
  void _runFilter() {
    List<dynamic> results = List<dynamic>.from(gameList);

    // Filter category
    if (selectedCategory != 'All') {
      results = results.where((game) {
        final style = (_get(game, 'gameStyle') ?? '').toString().toLowerCase();
        return style == selectedCategory.toLowerCase();
      }).toList();
    }

    // Filter by name
    final String searchQuery = _searchController.text.toLowerCase();
    if (searchQuery.isNotEmpty) {
      results = results.where((game) {
        final name = (_get(game, 'gameName') ?? '').toString().toLowerCase();
        return name.contains(searchQuery);
      }).toList();
    }

    // ✅ Keep only one game per group
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
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(30.0)),
          borderSide: BorderSide(color: Colors.orange),
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

        final String gameName = _get(game, 'gameName')?.toString() ?? '';
        final String gameStyle = _get(game, 'gameStyle')?.toString() ?? '';
        final String picPath = _get(game, 'picPath')?.toString() ?? '';
        final String gameGroup = _get(game, 'gameGroup')?.toString() ?? '';

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
                builder: (context) => RequestBorrowingStaffPage(
                  gameName: gameName,
                  imageAssetPath: picPath,
                  gameStyle: gameStyle,
                  players:
                      "${_get(game, 'minP') ?? 0}-${_get(game, 'maxP') ?? 0} players",
                  time: "${_get(game, 'gTime') ?? 0} min",
                  remaining: remaining,
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
