import 'package:flutter/material.dart';

class BorrowGamePage extends StatefulWidget {
  final String gameName;
  final String imageAssetPath;
  final String gameStyle;
  final String players;
  final String time;
  final int remaining;

  const BorrowGamePage({
    super.key,
    required this.gameName,
    required this.imageAssetPath,
    required this.gameStyle,
    required this.players,
    required this.time,
    required this.remaining,
  });

  @override
  State<BorrowGamePage> createState() => _BorrowGamePageState();
}

class _BorrowGamePageState extends State<BorrowGamePage> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.orange),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          widget.gameName,
          style: const TextStyle(
            color: Colors.orange,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Image.asset(
                    widget.imageAssetPath,
                    width: 180,
                    fit: BoxFit.cover,
                  ),
                ),

                const SizedBox(height: 20),
                const Divider(thickness: 1, color: Colors.orangeAccent),
                const SizedBox(height: 20),

                // Game Info
                _buildInfoRow('Name : ', widget.gameName),
                _buildInfoRow('Game Style : ', widget.gameStyle),
                _buildInfoRow('Players : ', widget.players),
                _buildInfoRow('Time : ', widget.time),

                // Remaining section
                Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(
                        text: 'Remaining : ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text: '$currentRemaining board',
                        style: TextStyle(
                          color: currentRemaining <= 0
                              ? Colors.red
                              : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                _buildInfoRow(
                  'How to play : ',
                  'Official website',
                  isLink: true,
                ),

                const Spacer(),

                // Borrow button
                Center(
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: (isBorrowed || currentRemaining <= 0)
                          ? null
                          : handleBorrow,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: (isBorrowed || currentRemaining <= 0)
                            ? Colors.grey
                            : Colors.orangeAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Borrow',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          if (showRequestPopup)
            GestureDetector(
              onTap: () {},
              child: Container(
                color: Colors.black54,
                alignment: Alignment.center,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 30,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.green.shade500,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 50,
                        ),
                      ),
                      const SizedBox(height: 20),

                      const Text(
                        'Request send',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isLink = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(
              text: value,
              style: TextStyle(
                color: isLink ? Colors.blue : Colors.black,
                decoration: isLink
                    ? TextDecoration.underline
                    : TextDecoration.none,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
