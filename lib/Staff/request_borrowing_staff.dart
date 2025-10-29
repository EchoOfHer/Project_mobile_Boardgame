import 'package:flutter/material.dart';
import 'package:boardgame_app/Staff_screens/staff_main.dart'
    show colour_available, colour_main, colour_available, colour_main;
import 'package:url_launcher/url_launcher.dart';

class RequestBorrowingStaffPage extends StatefulWidget {
  final String gameName;
  final String imageAssetPath;
  final String gameStyle;
  final String players;
  final String time;
  final int remaining;
  final String glink;

  const RequestBorrowingStaffPage({
    super.key,
    required this.gameName,
    required this.imageAssetPath,
    required this.gameStyle,
    required this.players,
    required this.time,
    required this.remaining,
    required this.glink,
  });

  @override
  State<RequestBorrowingStaffPage> createState() =>
      _RequestBorrowingStaffPageState();
}

class _RequestBorrowingStaffPageState extends State<RequestBorrowingStaffPage> {
  bool isBorrowed = false;
  bool showRequestPopup = false;
  late int currentRemaining;

  @override
  void initState() {
    super.initState();
    currentRemaining = widget.remaining;
  }

  void handleBorrow() async {
    setState(() {
      showRequestPopup = true;
      isBorrowed = true;
      if (currentRemaining > 0) {
        currentRemaining--;
      }
    });

    await Future.delayed(const Duration(seconds: 3));

    if (mounted) {
      setState(() {
        showRequestPopup = false;
      });
    }
  }

  Future<void> _launchUrl(String url) async {
    // Prefix with http if missing, but only if the URL is not empty
    final String fullUrl = url.trim().isNotEmpty && !url.startsWith('http')
        ? 'http://$url'
        : url;
    final Uri uri = Uri.parse(fullUrl);

    // Check if the link can be opened
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open the link.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: colour_main, size: 30),
        title: Text(
          widget.gameName,
          style: const TextStyle(
            color: Colors.orange,
            fontSize: 30,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          // ⬇️ ⬇️ ⬇️ 1. ห่อหุ้มเนื้อหาด้วย SingleChildScrollView ⬇️ ⬇️ ⬇️
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      child: ClipRRect(
                        // 1. ClipRRect needs the borderRadius property
                        borderRadius: BorderRadius.circular(20),
                        child: Image.asset(
                          // 2. Image.asset takes the asset path, width, and fit
                          widget.imageAssetPath,
                          width: 275,
                          fit: BoxFit.cover,
                          // NOTE: borderRadius property has been removed from here
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                  const Divider(thickness: 1, color: Colors.orangeAccent),
                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Name : ',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 18,
                            ),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Game Style : ',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 18,
                            ),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Players : ',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 18,
                            ),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Time : ',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 18,
                            ),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Remaining : ',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 18,
                            ),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'How to play : ',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.gameName,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 16),
                          Text(
                            widget.gameStyle,
                            style: TextStyle(fontSize: 18),
                          ),
                          SizedBox(height: 16),
                          Text(widget.players, style: TextStyle(fontSize: 18)),
                          SizedBox(height: 16),
                          Text(widget.time, style: TextStyle(fontSize: 18)),
                          SizedBox(height: 16),
                          Text(
                            '$currentRemaining board',
                            style: TextStyle(
                              color: Colors.red, // Use conditional color
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 16),
                          InkWell(
                            onTap: () => _launchUrl(widget.glink),
                            child: Text(
                              widget.glink,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
