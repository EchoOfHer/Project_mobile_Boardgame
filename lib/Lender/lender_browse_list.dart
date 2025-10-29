import 'package:flutter/material.dart';
import 'lender_borrowing.dart';

class BrowseLender extends StatefulWidget {
  const BrowseLender({super.key});

  @override
  State<BrowseLender> createState() => _BrowseLenderState();
}

class _BrowseLenderState extends State<BrowseLender> {
  final TextEditingController _searchController = TextEditingController();
  late List<Map<String, dynamic>> _filteredGames;

  final List<Map<String, dynamic>> games = [
    {
      'title': 'Exploding Kittens',
      'image': 'image/Exploding_Kitten.webp',
      'gameStyle': 'Party',
      'players': '2-10 peoples',
      'time': '10 min',
      'remaining': 1,
    },
    {
      'title': 'One Week Werewolf',
      'image': 'image/One_Week_Werewolf.webp',
      'gameStyle': 'Party',
      'players': '3-7 players',
      'time': '10 min',
      'remaining': 3,
    },
    {
      'title': 'Catan',
      'image': 'image/Catan.jpg',
      'gameStyle': 'Strategy',
      'players': '3-4 players',
      'time': '60-120 min',
      'remaining': 2,
    },
    {
      'title': 'Splendor',
      'image': 'image/Splendor.jpg',
      'gameStyle': 'Strategy',
      'players': '2-4 players',
      'time': '30 min',
      'remaining': 0,
    },
    {
      'title': 'Avalon',
      'image': 'image/Avalon.jpg',
      'gameStyle': 'Bluffing',
      'players': '5-10 players',
      'time': '30 min',
      'remaining': 1,
    },
  ];

  final List<String> categories = [
    'All',
    'Family',
    'Party',
    'Bluffing',
    'Abstract',
    'Dice',
    'Strategy'
  ];
  String selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    _filteredGames = List.from(games);
    _searchController.addListener(_runFilter);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _runFilter() {
    List<Map<String, dynamic>> results = List.from(games);
    final String searchQuery = _searchController.text.toLowerCase();

    if (selectedCategory != 'All') {
      results = results.where((game) {
        return game['gameStyle']!.toLowerCase() == selectedCategory.toLowerCase();
      }).toList();
    }

    if (searchQuery.isNotEmpty) {
      results = results.where((game) {
        return game['title']!.toLowerCase().contains(searchQuery);
      }).toList();
    }

    setState(() {
      _filteredGames = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
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
                      'Welcome Lender',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildSearchBar(),
                    const SizedBox(height: 20),
                    _buildCategoryFilters(),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: _buildGameGrid(),
              ),
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
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: const BorderSide(color: Colors.orange),
        ),
      ),
    );
  }

  Widget _buildCategoryFilters() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
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
              margin: const EdgeInsets.only(right: 8.0),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? Colors.orange : Colors.grey[200],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  category,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black54,
                    fontWeight: FontWeight.bold,
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
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemCount: _filteredGames.length,
      itemBuilder: (context, index) {
        final game = _filteredGames[index];

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BorrowGamePage(
                  gameName: game['title']!,
                  imageAssetPath: game['image']!,
                  gameStyle: game['gameStyle']!,
                  players: game['players']!,
                  time: game['time']!,
                  remaining: game['remaining']!,
                ),
              ),
            );
          },
          child: GameCard(
            title: game['title']!,
            imagePath: game['image']!,
          ),
        );
      },
    );
  }
}

class GameCard extends StatelessWidget {
  final String title;
  final String imagePath;

  const GameCard({
    super.key,
    required this.title,
    required this.imagePath,
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
          Expanded(
            child: Image.asset(
              imagePath,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[200],
                  child: const Icon(Icons.broken_image, color: Colors.grey),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}