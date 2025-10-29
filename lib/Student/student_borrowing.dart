// lib/Student/student_borrowing.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '/Staff/game_data.dart';
import 'student_main.dart' show colour_main, colour_disable;

/// Helper – works with your GameItem
dynamic _get(dynamic item, String key) {
  if (item == null) return null;
  final obj = item as GameItem;
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
}

/* --------------------------------------------------------------
   GLOBAL STATE
   --------------------------------------------------------------
   * _hasRequestedAnyGame → true after the first borrow
   * _lastRequestedGroup  → keeps the group that was borrowed
   -------------------------------------------------------------- */
bool _hasRequestedAnyGame = false;
String _lastRequestedGroup = '';

class BorrowGamePage extends StatefulWidget {
  final String gameName;
  final String imageAssetPath;
  final String gameStyle;
  final String players;
  final String time;
  final String glink;
  final String gameGroup;

  const BorrowGamePage({
    super.key,
    required this.gameName,
    required this.imageAssetPath,
    required this.gameStyle,
    required this.players,
    required this.time,
    required this.glink,
    required this.gameGroup,
  });

  @override
  State<BorrowGamePage> createState() => _BorrowGamePageState();
}

class _BorrowGamePageState extends State<BorrowGamePage> {
  bool _showPopup = false;

  /* -----------------------------------------------------------
     CAN BORROW ?
     – student has not borrowed anything yet
     – there is at least one copy available
     ----------------------------------------------------------- */
  bool get _canBorrow => !_hasRequestedAnyGame && _remaining > 0;

  int get _remaining {
    return gameList
        .where(
          (g) => g.gameGroup == widget.gameGroup && g.status == 'Available',
        )
        .length;
  }

  Future<void> _handleBorrow() async {
    if (!_canBorrow) return;

    setState(() => _showPopup = true);

    // ---- 1. Mark that a game has been requested (global) ----
    _hasRequestedAnyGame = true;
    _lastRequestedGroup = widget.gameGroup;

    // ---- 2. Reduce one copy from "Available" → "Borrowing" ----
    bool changed = false;
    for (final g in gameList) {
      if (g.gameGroup == widget.gameGroup &&
          g.status == 'Available' &&
          !changed) {
        g.status = 'Borrowing';
        changed = true;
        break;
      }
    }

    await Future.delayed(const Duration(seconds: 3));

    if (mounted) setState(() => _showPopup = false);
  }

  Future<void> _launchUrl(String url) async {
    final String fullUrl = url.trim().isNotEmpty && !url.startsWith('http')
        ? 'http://$url'
        : url;
    final Uri uri = Uri.parse(fullUrl);
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.orange),
          onPressed: () => Navigator.pop(context),
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
          // ── Main content ─────────────────────────────────────
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        widget.imageAssetPath,
                        width: 275,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 275,
                          height: 275,
                          color: Colors.grey[200],
                          child: const Icon(
                            Icons.broken_image,
                            size: 80,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Divider(thickness: 1, color: colour_main),
                  const SizedBox(height: 20),

                  // Two‑column info
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Name : ',
                            style: TextStyle(color: Colors.grey, fontSize: 18),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Game Style : ',
                            style: TextStyle(color: Colors.grey, fontSize: 18),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Players : ',
                            style: TextStyle(color: Colors.grey, fontSize: 18),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Time : ',
                            style: TextStyle(color: Colors.grey, fontSize: 18),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Remaining : ',
                            style: TextStyle(color: Colors.grey, fontSize: 18),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'How to play : ',
                            style: TextStyle(color: Colors.grey, fontSize: 18),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.gameName,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            widget.gameStyle,
                            style: const TextStyle(fontSize: 18),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            widget.players,
                            style: const TextStyle(fontSize: 18),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            widget.time,
                            style: const TextStyle(fontSize: 18),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '$_remaining board',
                            style: TextStyle(
                              color: _remaining == 0
                                  ? colour_disable
                                  : Colors.black,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 16),
                          InkWell(
                            onTap: () => _launchUrl(widget.glink),
                            child: Text(
                              widget.glink.isEmpty ? 'N/A' : widget.glink,
                              style: const TextStyle(
                                color: Colors.black,
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

                  // ── Borrow button (disabled after any request) ───────
                  Center(
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _canBorrow ? _handleBorrow : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _canBorrow
                              ? Colors.orangeAccent
                              : Colors.grey,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          _hasRequestedAnyGame
                              ? 'You already requested a game'
                              : (_remaining <= 0 ? 'Out of stock' : 'Borrow'),
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // ── Popup ───────────────────────────────────────
          if (_showPopup)
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
                        'Request sent',
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
}
