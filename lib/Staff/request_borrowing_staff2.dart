// request_borrowing_staff2.dart
import 'package:flutter/material.dart';
import 'staff_main.dart' show colour_main;
import 'package:url_launcher/url_launcher.dart';

final String baseUrl = '10.0.2.2:3000';

class RequestBorrowingStaffPage extends StatefulWidget {
  final dynamic gameId;
  final String currentStatus;
  final String gameName;
  final String imageAssetPath; // เช่น "games/catan.jpg"
  final String gameStyle;
  final String players;
  final String time;
  final String glink;

  const RequestBorrowingStaffPage({
    super.key,
    required this.gameId,
    required this.currentStatus,
    required this.gameName,
    required this.imageAssetPath,
    required this.gameStyle,
    required this.players,
    required this.time,
    required this.glink,
  });

  @override
  State<RequestBorrowingStaffPage> createState() =>
      _RequestBorrowingStaffPageState();
}

class _RequestBorrowingStaffPageState extends State<RequestBorrowingStaffPage> {
  Future<void> _launchUrl(String url) async {
    if (url.trim().isEmpty) return;

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
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // รูปภาพ (ใช้ network เหมือน Lender)
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(
                    'http://$baseUrl/${widget.imageAssetPath}',
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
                          size: 80,
                          color: Colors.grey,
                        ),
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 20),
              const Divider(thickness: 1, color: colour_main),
              const SizedBox(height: 20),

              // ข้อมูลเกม (เหมือนเดิมทุกอย่าง)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Label
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
                        'How to play : ',
                        style: TextStyle(color: Colors.grey, fontSize: 18),
                      ),
                    ],
                  ),
                  const SizedBox(width: 20),
                  // Value
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
                      Text(widget.time, style: const TextStyle(fontSize: 18)),
                      const SizedBox(height: 16),
                      InkWell(
                        onTap: () => _launchUrl(widget.glink),
                        child: Text(
                          widget.glink.isEmpty ? 'No link' : widget.glink,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: widget.glink.isEmpty
                                ? Colors.grey
                                : colour_main,
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
    );
  }
}
