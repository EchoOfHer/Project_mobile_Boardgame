// lib/Student/student_borrowing.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert'; // Added for JSON encoding
import 'package:http/http.dart' as http; // Added for API call

// REMOVED: import '/Staff/game_data.dart'; // No longer using local gameList
import 'student_main.dart'
    show colour_main, colour_disable, colour_available, colour_borrow;

// NOTE: Removed the old dynamic _get helper as the data structure is now Map<String, dynamic>
// from the API, and no longer relies on the local GameItem class.
final url = '10.0.2.2:3000'; // Define the URL again for use in this file

// ตัวแปรสถานะการจอง (แชร์ทั้งแอป)
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
  final dynamic gameId; // <<<--- FIX 1: ADD gameId FIELD
  final String currentStatus;
  final VoidCallback? onStatusChanged;

  const BorrowGamePage({
    super.key,
    required this.gameName,
    required this.imageAssetPath,
    required this.gameStyle,
    required this.players,
    required this.time,
    required this.glink,
    required this.gameGroup,
    required this.gameId, // <<<--- FIX 1: ADD gameId TO CONSTRUCTOR
    required this.currentStatus,
    this.onStatusChanged,
  });

  @override
  State<BorrowGamePage> createState() => _BorrowGamePageState();
}

class _BorrowGamePageState extends State<BorrowGamePage> {
  bool _showPopup = false;
  bool _showDuration = false;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isRequesting = false; // New state for API call loading

  bool get _isItemAvailable => widget.currentStatus == 'Available';

  // ตรวจสอบว่าสามารถกด Borrow ได้หรือไม่ (เมื่อวันที่ถูกตั้งค่าอัตโนมัติแล้ว)
  bool get _canBorrow =>
      !_hasRequestedAnyGame &&
      _isItemAvailable &&
      _startDate != null &&
      _endDate != null &&
      !_isRequesting; // Cannot borrow while already requesting

  // REMOVED: The _remaining getter as it depends on the removed 'gameList'

  // 🗑️ REMOVED: ไม่ใช้ Date Picker อีกต่อไป
  Future<void> _selectDate(bool isStart) async {
    // This function is now just a placeholder, as the date is set automatically in _onBorrowPressed
  }

  // 🌟 FIXED: _onBorrowPressed จะตั้งค่าวันที่ 'วันนี้' และ 'พรุ่งนี้' อัตโนมัติ
  void _onBorrowPressed() {
    if (_hasRequestedAnyGame || !_isItemAvailable) return;

    // Use DateTime.now() to set the dates for the reservation
    final DateTime today = DateTime.now().toLocal().copyWith(
      hour: 0,
      minute: 0,
      second: 0,
      millisecond: 0,
      microsecond: 0,
    );
    final DateTime tomorrow = today.add(const Duration(days: 1));

    setState(() {
      _startDate = today;
      _endDate = tomorrow;
      _showDuration = true; // Show the confirmation screen
    });
  }

  /// 🌐 Replaced local data modification with API call to request borrowing
  Future<void> _handleBorrow() async {
    if (!_canBorrow) return;

    setState(() {
      _isRequesting = true;
      _showPopup = true;
    });

    try {
      final response = await http.post(
        Uri.parse('http://$url/request-borrowing'), // Your new POST endpoint
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'game_id': widget.gameId, // Send the unique game ID
          'start_date': _startDate!.toIso8601String().substring(0, 10),
          'end_date': _endDate!.toIso8601String().substring(0, 10),
          // You will need to add student_id/user_id here
          // 'student_id': 123456,
        }),
      );

      if (response.statusCode == 200) {
        // Assume success, show success popup
        _hasRequestedAnyGame = true;
        _lastRequestedGroup = widget.gameGroup;

        // Call the refresh function on the previous page
        if (widget.onStatusChanged != null) {
          widget.onStatusChanged!();
        }
      } else {
        // Handle API error response (e.g., already borrowed, game disabled)
        final errorMsg =
            json.decode(response.body)['message'] ?? 'Borrow request failed.';
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: $errorMsg')));
        }
      }
    } catch (e) {
      print('Borrow API network error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Network error. Could not send request.'),
          ),
        );
      }
    } finally {
      // Hide popup and reset requesting state after a short delay
      await Future.delayed(const Duration(seconds: 3));
      if (mounted) {
        setState(() {
          _isRequesting = false;
          _showPopup = false;
        });
      }
    }
  }

  Future<void> _launchUrl(String url) async {
    final String fullUrl = url.trim().isNotEmpty && !url.startsWith('http')
        ? 'http://$url'
        : url;
    final Uri uri = Uri.parse(fullUrl);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open the link.')),
        );
      }
    }
  }

  String get _borrowButtonText {
    if (_isRequesting) return 'Requesting...'; // Show loading state
    if (_hasRequestedAnyGame) return 'You already requested a game';
    if (!_isItemAvailable) return 'Unavailable: ${widget.currentStatus}';
    if (_showDuration && (_startDate == null || _endDate == null))
      return 'Duration Error';

    // Updated button text for the two stages
    return _showDuration ? 'Confirm Borrow' : 'Borrow';
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return '${date.day}/${date.month.toString().padLeft(2, '0')}';
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
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Game Image
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

                  // UI ภาพที่ 1: ข้อมูลเกม
                  if (!_showDuration) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Name : ',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 18,
                              ),
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Game Style : ',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 18,
                              ),
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Players : ',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 18,
                              ),
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Time : ',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 18,
                              ),
                            ),
                            SizedBox(height: 16),
                            Text(
                              'How to play : ',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 18,
                              ),
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
                  ],

                  // UI ภาพที่ 2: Duration (Confirmation of fixed dates)
                  if (_showDuration) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Duration (Today - Tomorrow)',
                            style: TextStyle(color: Colors.grey, fontSize: 18),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    color: colour_available,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    _startDate == null
                                        ? 'Error: Date not set'
                                        : _formatDate(_startDate),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8),
                                child: Text(
                                  '-',
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    color: colour_available,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    _endDate == null
                                        ? 'Error: Date not set'
                                        : _formatDate(_endDate),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 30),

                  // ปุ่ม Borrow
                  Center(
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        // If showDuration is true, check _canBorrow (which ensures dates are set)
                        onPressed: _showDuration
                            ? (_canBorrow ? _handleBorrow : null)
                            : (_hasRequestedAnyGame ||
                                      !_isItemAvailable ||
                                      _isRequesting
                                  ? null
                                  : _onBorrowPressed), // Trigger automatic date set
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              _hasRequestedAnyGame ||
                                  !_isItemAvailable ||
                                  _isRequesting
                              ? Colors.grey
                              : colour_borrow,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          _borrowButtonText,
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

          // Success Popup (Updated to check for _isRequesting)
          if (_showPopup && _isRequesting)
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
                          color: colour_available,
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
