import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '/staff/staff_main.dart'
    show colour_available, colour_disable, colour_main;
import '/staff/game_data.dart'; // ← ต้อง import เพื่อใช้ gameList

class RequestBorrowingLenderPage extends StatefulWidget {
  final String gameName;
  final String imageAssetPath;
  final String gameStyle;
  final String players;
  final String time;
  final String gameGroup; // ← เพิ่ม: ต้องส่ง gameGroup มา
  final String? glink;

  const RequestBorrowingLenderPage({
    super.key,
    required this.gameName,
    required this.imageAssetPath,
    required this.gameStyle,
    required this.players,
    required this.time,
    required this.gameGroup,
    this.glink,
  });

  @override
  State<RequestBorrowingLenderPage> createState() =>
      _RequestBorrowingLenderPageState();
}

class _RequestBorrowingLenderPageState
    extends State<RequestBorrowingLenderPage> {
  bool isBorrowed = false;
  bool showRequestPopup = false;

  // ฟังก์ชันคำนวณคงเหลือจาก gameList
  int get currentRemaining {
    return gameList.where((g) {
      final group = _get(g, 'gameGroup')?.toString() ?? '';
      final status = _get(g, 'status')?.toString().toLowerCase() ?? '';
      return group == widget.gameGroup && status == 'available';
    }).length;
  }

  @override
  void initState() {
    super.initState();
  }

  void handleBorrow() async {
    setState(() {
      showRequestPopup = true;
      isBorrowed = true;
    });

    await Future.delayed(const Duration(seconds: 3));

    if (mounted) {
      setState(() {
        showRequestPopup = false;
      });
    }
  }

  // --- ฟังก์ชัน _get เดิมจาก BrowseLender ---
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
        case 'status':
          return (item as dynamic).status;
        default:
          return (item as dynamic)[key];
      }
    } catch (_) {
      return null;
    }
  }

  Future<void> _launchUrl(String? url) async {
    if (url == null || url.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No link available.')));
      return;
    }

    final String fullUrl = url.startsWith('http') ? url : 'http://$url';
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
    final int remaining = currentRemaining; // คำนวณสดทุกครั้ง

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: colour_main),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.gameName,
          style: const TextStyle(
            color: colour_main,
            fontSize: 30,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ภาพเกม
                  Center(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Image.asset(
                          widget.imageAssetPath,
                          width: 275,
                          height: 275,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 275,
                              height: 275,
                              color: Colors.grey[200],
                              child: const Icon(
                                Icons.broken_image,
                                size: 48,
                                color: Colors.grey,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                  const Divider(thickness: 1, color: colour_main),
                  const SizedBox(height: 20),

                  // ข้อมูล 2 คอลัมน์
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          _Label('Name :'),
                          _Label('Game Style :'),
                          _Label('Players :'),
                          _Label('Time :'),
                          _Label('Remaining :'),
                          _Label('How to play :'),
                        ],
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _Value(widget.gameName, bold: true),
                          _Value(widget.gameStyle),
                          _Value(widget.players),
                          _Value(widget.time),
                          _Value(
                            '$remaining board${remaining != 1 ? 's' : ''}',
                            color: remaining == 0
                                ? colour_disable
                                : Colors.black,
                          ),
                          InkWell(
                            onTap: () => _launchUrl(widget.glink),
                            child: Text(
                              widget.glink?.isNotEmpty == true
                                  ? widget.glink!
                                  : 'No link available',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.black,
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

                  // ปุ่มยืม
                ],
              ),
            ),
          ),

          // Popup ขอสำเร็จ
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
                        'Request Sent',
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

// Reusable Widgets
class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Text(text, style: TextStyle(color: Colors.grey[600], fontSize: 18)),
  );
}

class _Value extends StatelessWidget {
  final String text;
  final Color? color;
  final bool bold;
  const _Value(this.text, {this.color, this.bold = false});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Text(
      text,
      style: TextStyle(
        fontSize: 18,
        fontWeight: bold ? FontWeight.bold : FontWeight.normal,
        color: color ?? Colors.black,
      ),
    ),
  );
}
