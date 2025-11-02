// lib/Student/browse_student.dart
import 'package:flutter/material.dart';
import 'dart:convert'; // For JSON decoding
import 'package:http/http.dart' as http; // For network requests
// REMOVED: import '/Staff/game_data.dart'; // NO LONGER USED
import '/login/login.dart';
import 'student_main.dart' show colour_main;
import 'student_borrowing.dart'; // ← BorrowGamePage

final url = '10.0.2.2:3000';

/// Shared _get helper (same as in BorrowGamePage)
dynamic _get(dynamic item, String key) {
  if (item == null) return null;
  // This supports both Map<String, dynamic> from JSON and dynamic objects
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
      case 'game_id': // Added to support new data structure
        return obj.game_id;
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
  // New state variables for API data handling
  List<dynamic> _allGames = []; // The list fetched from the API
  late List<dynamic> _filteredGames;
  late List<String> categories = ['All']; // Initialize default
  String selectedCategory = 'All';
  bool _isLoading = true; // Loading state

  @override
  void initState() {
    super.initState();
    _filteredGames = []; // Initialize empty
    _fetchGames(); // Start fetching data
    _searchController.addListener(_runFilter);
  }

  @override
  void dispose() {
    _searchController.removeListener(_runFilter);
    _searchController.dispose();
    super.dispose();
  }

  /// 🌐 Fetches the game list from the Express API
  Future<void> _fetchGames() async {
    // Set loading state only if it's the initial load or a manual refresh
    if (_allGames.isEmpty) {
      if (mounted) setState(() => _isLoading = true);
    }

    try {
      final response = await http.get(Uri.parse('http://$url/api/games'));

      if (response.statusCode == 200) {
        final List<dynamic> fetchedGames = json.decode(response.body);

        // Ensure setState is only called if the widget is still mounted
        if (mounted) {
          setState(() {
            _allGames = fetchedGames; // Store the original fetched list
            _buildCategories(); // Build categories based on new data
            _runFilter(); // Apply initial filter/sort
            _isLoading = false; // Data loaded
          });
        }
      } else {
        print('Failed to load games. Status code: ${response.statusCode}');
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Network error: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _buildCategories() {
    final Set<String> styleSet = {};
    // Use the fetched list: _allGames
    for (final g in _allGames) {
      final style = _get(g, 'gameStyle')?.toString().trim() ?? '';
      if (style.isNotEmpty) styleSet.add(style);
    }
    categories = ['All', ...styleSet.toList()];
  }

  void _runFilter() {
    // Start with the full, unfiltered game list: _allGames
    List<dynamic> results = List<dynamic>.from(_allGames);

    // 1. Filter by category
    if (selectedCategory != 'All') {
      results = results.where((game) {
        final style = (_get(game, 'gameStyle') ?? '').toString().toLowerCase();
        return style == selectedCategory.toLowerCase();
      }).toList();
    }

    // 2. Filter by search
    final query = _searchController.text.toLowerCase();
    if (query.isNotEmpty) {
      results = results.where((game) {
        final name = (_get(game, 'gameName') ?? '').toString().toLowerCase();
        return name.contains(query);
      }).toList();
    }

    // 3. Custom sorting logic: Group by name, then prioritize 'Available' status
    results.sort((a, b) {
      final groupA = _get(a, 'gameGroup')?.toString() ?? '';
      final groupB = _get(b, 'gameGroup')?.toString() ?? '';
      final statusA = _get(a, 'status')?.toString() ?? '';
      final statusB = _get(b, 'status')?.toString() ?? '';

      // Primary Sort: Sort by Game Group alphabetically
      final groupComparison = groupA.compareTo(groupB);
      if (groupComparison != 0) {
        return groupComparison;
      }

      // Secondary Sort: Prioritize 'Available' items within the same group
      if (statusA == 'Available' && statusB != 'Available') {
        return -1; // A comes before B
      }
      if (statusA != 'Available' && statusB == 'Available') {
        return 1; // B comes before A
      }

      return 0;
    });

    if (mounted) {
      setState(() {
        _filteredGames = results;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          color: Colors.white,
          child: Column(
            children: [
              // Header (remains static)
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
              // Expanded area for the grid, now supporting pull-to-refresh
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
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.orange),
      );
    }

    if (_filteredGames.isEmpty) {
      // 🌟 Wrap the Center widget with RefreshIndicator for pull-down refresh on an empty list
      return RefreshIndicator(
        onRefresh: _fetchGames, // Calls the fetch function on pull-down
        color: Colors.orange,
        child: ListView(
          // Use ListView here so RefreshIndicator works even when empty
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 100), // Add padding to center the text
            Center(
              child: Text(
                'No games found.',
                style: TextStyle(color: Colors.grey, fontSize: 18),
              ),
            ),
          ],
        ),
      );
    }

    // 🌟 Wrap the GridView.builder with RefreshIndicator for pull-down refresh
    return RefreshIndicator(
      onRefresh: _fetchGames, // Calls the fetch function on pull-down
      color: Colors.orange,
      child: GridView.builder(
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
          final status = _get(game, 'status')?.toString() ?? '';

          return GestureDetector(
            onTap: () {
              // Note: The game object retrieved from the API now contains game_id
              final gameId = _get(game, 'game_id');
              // We pass the individual item's status, which is correct

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
                    gameGroup: gameGroup,
                    // Pass the game_id, which is unique per physical item/row
                    gameId: gameId,
                    // 🌟 Pass the individual item status
                    currentStatus: status,
                    // Pass callback to refresh the list after borrowing
                    onStatusChanged: () {
                      // Re-fetch data to reflect the change on the server
                      _fetchGames();
                    },
                  ),
                ),
              );
            },
            // Pass individual item status for the badge/grayscale logic
            child: GameCard(
              title: gameName,
              imagePath: picPath,
              status: status,
            ),
          );
        },
      ),
    );
  }
}

// -------------------------------------------------------------------

// === Game Card (Includes Status Badge and Grayscale Filter) ===
class GameCard extends StatelessWidget {
  // ... (GameCard class remains unchanged)
  final String title;
  final String imagePath;
  final String status;

  const GameCard({
    super.key,
    required this.title,
    required this.imagePath,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Image area
          Expanded(child: _buildImageWithStatus()),

          // Game Name area
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

  // Helper to build the image and layer the status badge on top
  Widget _buildImageWithStatus() {
    return Stack(
      children: [
        // 1. The main content (Image or Placeholder)
        Positioned.fill(child: _buildImageOrPlaceholder()),

        // 2. The Status Badge, conditionally positioned at the top right corner
        Positioned(
          top: 8.0,
          right: 8.0,
          // Only show the badge if the status is NOT 'Available'
          child: status != 'Available'
              ? _buildStatusBadge(status)
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  // Helper to create the actual badge widget with conditional styling
  Widget _buildStatusBadge(String text) {
    Color backgroundColor;
    IconData icon;

    switch (text) {
      case 'Borrowing':
        backgroundColor = Colors.red.shade600;
        icon = Icons.handshake;
        break;
      case 'Disabled':
        backgroundColor = Colors.grey.shade700;
        icon = Icons.block;
        break;
      default:
        backgroundColor = Colors.blue.shade600;
        icon = Icons.info_outline;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // Image loading/placeholder logic with conditional Grayscale filter
  Widget _buildImageOrPlaceholder() {
    Widget imageWidget;

    if (imagePath.trim().isEmpty) {
      imageWidget = Container(
        color: Colors.grey[200],
        child: const Icon(Icons.broken_image, size: 48, color: Colors.grey),
      );
    } else {
      imageWidget = Image.asset(
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

    // Apply grayscale filter if status is 'Borrowing' or 'Disabled'
    if (status == 'Borrowing' || status == 'Disabled') {
      return ColorFiltered(
        // Standard grayscale matrix
        colorFilter: const ColorFilter.matrix(<double>[
          0.2126,
          0.7152,
          0.0722,
          0,
          0,
          0.2126,
          0.7152,
          0.0722,
          0,
          0,
          0.2126,
          0.7152,
          0.0722,
          0,
          0,
          0,
          0,
          0,
          1,
          0,
        ]),
        child: imageWidget,
      );
    } else {
      // Return the image without the filter for 'Available' status
      return imageWidget;
    }
  }
}
