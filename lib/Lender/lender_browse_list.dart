// lib/Lender/lender_browse_list.dart
import 'package:flutter/material.dart';
import 'request_borrowing_lender.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

final String url = '10.0.2.2:3000'; // Local API
const Color colour_main = Colors.orange;

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
      case 'game_id':
        return obj.game_id;
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

class BrowseLender extends StatefulWidget {
  const BrowseLender({super.key});

  @override
  State<BrowseLender> createState() => _BrowseLenderState();
}

class _BrowseLenderState extends State<BrowseLender> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _allGames = [];
  List<dynamic> _filteredGames = [];
  List<String> categories = ['All'];
  String selectedCategory = 'All';
  bool _isLoading = true;
  String? _lenderName;

  @override
  void initState() {
    super.initState();
    _loadLenderName();
    _fetchGames();
    _searchController.addListener(_runFilter);
  }

  @override
  void dispose() {
    _searchController.removeListener(_runFilter);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadLenderName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _lenderName = prefs.getString('username') ?? 'Lender';
    });
  }

  Future<void> _fetchGames() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(Uri.parse('http://$url/api/games'));
      if (response.statusCode == 200) {
        final List<dynamic> fetchedGames = json.decode(response.body);
        setState(() {
          _allGames = fetchedGames;
          _buildCategories();
          _runFilter();
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
        debugPrint('Failed to fetch games: ${response.statusCode}');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint('Error fetching games: $e');
    }
  }

  void _buildCategories() {
    final Set<String> styleSet = {};
    for (final g in _allGames) {
      final style = _get(g, 'gameStyle')?.toString().trim() ?? '';
      if (style.isNotEmpty) styleSet.add(style);
    }
    categories = ['All', ...styleSet.toList()];
  }

  void _runFilter() {
    List<dynamic> results = List<dynamic>.from(_allGames);

    if (selectedCategory != 'All') {
      results = results.where((game) {
        final style = (_get(game, 'gameStyle') ?? '').toString().toLowerCase();
        return style == selectedCategory.toLowerCase();
      }).toList();
    }

    final query = _searchController.text.toLowerCase();
    if (query.isNotEmpty) {
      results = results.where((game) {
        final name = (_get(game, 'gameName') ?? '').toString().toLowerCase();
        return name.contains(query);
      }).toList();
    }

    if (mounted) setState(() => _filteredGames = results);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'BOARD GAME SS',
                    style: TextStyle(
                        color: colour_main,
                        fontSize: 24,
                        fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Welcome ${_lenderName ?? 'Lender'}',
                    style: TextStyle(color: Colors.grey[700], fontSize: 18),
                  ),
                  const SizedBox(height: 20),
                  _buildSearchBar(),
                  const SizedBox(height: 16),
                  _buildCategoryFilters(),
                ],
              ),
            ),
            Expanded(child: _buildGameGrid()),
          ],
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
          borderSide: const BorderSide(color: colour_main),
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
                color: isSelected ? colour_main : Colors.grey[200],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  category,
                  style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 13),
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
      return const Center(child: CircularProgressIndicator(color: colour_main));
    }

    if (_filteredGames.isEmpty) {
      return RefreshIndicator(
        onRefresh: _fetchGames,
        color: colour_main,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 100),
            Center(
              child: Text('No games found.',
                  style: TextStyle(color: Colors.grey, fontSize: 18)),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchGames,
      color: colour_main,
      child: GridView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, crossAxisSpacing: 14, mainAxisSpacing: 14),
        itemCount: _filteredGames.length,
        itemBuilder: (context, index) {
          final game = _filteredGames[index];
          final name = _get(game, 'gameName') ?? '';
          final pic = _get(game, 'picPath') ?? '';
          final status = _get(game, 'status') ?? 'Available';
          final gameId = _get(game, 'game_id');

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => RequestBorrowingLenderPage(
                    gameId: gameId,
                    currentStatus: status,
                    gameName: name,
                    imageAssetPath: pic,
                    gameStyle: _get(game, 'gameStyle') ?? '',
                    players:
                        "${_get(game, 'minP') ?? 0}-${_get(game, 'maxP') ?? 0} players",
                    time: "${_get(game, 'gTime') ?? 0} min",
                    gameGroup: _get(game, 'gameGroup') ?? '',
                    glink: _get(game, 'g_link') ?? '',
                  ),
                ),
              );
            },
            child: GameCard(title: name, imagePath: pic, status: status),
          );
        },
      ),
    );
  }
}

class GameCard extends StatelessWidget {
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
          Expanded(child: _buildImageWithStatus()),
          Padding(
            padding: const EdgeInsets.all(10),
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

  Widget _buildImageWithStatus() {
    return Stack(
      children: [
        Positioned.fill(child: _buildImageOrPlaceholder()),
        if (status != 'Available')
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: status == 'Borrowing'
                    ? Colors.red.shade600
                    : Colors.grey.shade700,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                status,
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildImageOrPlaceholder() {
    if (imagePath.isEmpty) {
      return Container(
        color: Colors.grey[200],
        child: const Icon(Icons.broken_image, size: 48, color: Colors.grey),
      );
    }
    return Image.network(
      'http://$url/$imagePath',
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(
        color: Colors.grey[200],
        child: const Icon(Icons.broken_image, size: 48, color: Colors.grey),
      ),
    );
  }
}
