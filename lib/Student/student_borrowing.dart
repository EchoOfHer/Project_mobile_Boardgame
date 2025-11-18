// lib/Student/student_borrowing.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

// (นำเข้า 'url' จาก student_main ตามที่ทีมกำหนด)
import 'student_main.dart'
    show colour_main, colour_disable, colour_available, colour_borrow, url;

// (ลบ final url = '...' ที่ซ้ำซ้อนออก)
final url = '10.0.2.2:3000';

// --- (โค้ดจากเวอร์ชันของทีม) ---
class ThaiDate {
  static final _bangkok = tz.getLocation('Asia/Bangkok');
  static tz.TZDateTime today() {
    final now = tz.TZDateTime.now(_bangkok);
    return tz.TZDateTime(_bangkok, now.year, now.month, now.day);
  }

  static String ymd(DateTime d) =>
      DateFormat('yyyy-MM-dd').format(tz.TZDateTime.from(d, _bangkok));
  static String dm(DateTime d) {
    final local = tz.TZDateTime.from(d, _bangkok);
    return '${local.day}/${local.month.toString().padLeft(2, '0')}';
  }
}
// ------------------------------

class BorrowGamePage extends StatefulWidget {
  final String gameName;
  final String imageAssetPath;
  final String gameStyle;
  final String players;
  final String time;
  final String glink;
  final String gameGroup;
  final dynamic gameId;
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
    required this.gameId,
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
  bool _isRequesting = false;
  bool _hasRequested = false; // (เปลี่ยนชื่อจาก _hasRequestedAnyGame)

  @override
  void initState() {
    super.initState();
    tz_data.initializeTimeZones();
    _checkActiveRequest();
  }

  // (ฟังก์ชันจากเวอร์ชันของทีม - ดีมาก)
  Future<void> _checkActiveRequest() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id');
    if (userId == null) return;

    try {
      final res = await http.get(
        Uri.parse('http://$url/api/check-request/$userId'),
      );
      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        if (json['data'] != null && (json['data'] as List).isNotEmpty) {
          setState(() => _hasRequested = true);
        }
      }
    } catch (_) {}
  }

  void _onBorrowPressed() {
    if (_hasRequested || widget.currentStatus != 'Available') return;
    setState(() {
      _startDate = ThaiDate.today();
      _endDate = _startDate!.add(const Duration(days: 1));
      _showDuration = true;
    });
  }

  //
  // --- 🌟 นี่คือฟังก์ชันที่ MERGE แล้ว 🌟 ---
  //
  Future<void> _handleBorrow() async {
    // 1. ดึง ID ผู้ใช้จริง (จากเวอร์ชันทีม)
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id');
    if (userId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please log in again')));
      return;
    }

    // 2. ตรวจสอบว่ากดได้หรือไม่
    final bool canBorrow =
        !_hasRequested &&
        widget.currentStatus == 'Available' &&
        _startDate != null &&
        _endDate != null &&
        !_isRequesting;

    if (!canBorrow) return;

    setState(() {
      _isRequesting = true;
      _showPopup = true;
    });

    try {
      // 3. เรียก Endpoint ที่ถูกต้อง (ตาม SQL ล่าสุด)
      // (ต้องถามทีมว่า Endpoint คือ /borrow หรือ /request-borrowing)
      final res = await http.post(
        Uri.parse(
          'http://$url/request-borrowing',
        ), // <--- (A) ใช้ Endpoint ที่ตรงกับ SQL
        headers: {'Content-Type': 'application/json'},

        // 4. ส่ง Body ที่ถูกต้อง (ตาม SQL ล่าสุด)
        // (ใหม่) ส่วนที่ 4. ส่ง Body ที่ถูกต้อง (ตาม Express Route)
        body: jsonEncode({
          'game_id': widget.gameId,
          'student_id': userId,
          'start_date': ThaiDate.ymd(_startDate!), // ✅ แก้ไขตรงนี้
          'end_date': ThaiDate.ymd(_endDate!), // ✅ แก้ไขตรงนี้
          'status': 'pending', // (ไม่จำเป็นต้องส่ง แต่เก็บไว้ได้)
        }),
      );

      // 5. จัดการผลลัพธ์ (จากเวอร์ชันทีม)
      if (res.statusCode == 200 || res.statusCode == 201) {
        setState(() => _hasRequested = true);
        widget.onStatusChanged?.call();
      } else {
        final msg = jsonDecode(res.body)['message'] ?? 'Request failed';
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(msg)));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Network error')));
    } finally {
      await Future.delayed(const Duration(seconds: 3));
      if (mounted) {
        setState(() {
          _isRequesting = false;
          _showPopup = false;
        });
      }
    }
  }
  //
  // --- 🌟 สิ้นสุดส่วนที่ MERGE 🌟 ---
  //

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

  String get _buttonText {
    if (_isRequesting) return 'Sending...';
    if (_hasRequested) return 'Already Requested';
    if (widget.currentStatus != 'Available') return 'Unavailable';
    return _showDuration ? 'Confirm' : 'Borrow';
  }

  String _displayDate(DateTime? d) => d == null ? '' : ThaiDate.dm(d);

  @override
  Widget build(BuildContext context) {
    // ... (ส่วน UI ที่เหลือของคุณเหมือนเดิมทุกประการ) ...
    // (คัดลอกโค้ดส่วน build() เดิมของคุณมาวางที่นี่ได้เลย)
    //
    // (ผมจะคัดลอกส่วน build() จากเวอร์ชัน 8e7... มาให้
    // เพราะมันดูเหมือนจะเป็นเวอร์ชันที่อัปเดต UI ล่าสุดแล้ว)
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
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
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
                const Divider(color: colour_main, thickness: 1),
                const SizedBox(height: 20),

                // Game Info
                if (!_showDuration)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Name : ',
                            style: TextStyle(color: Colors.grey, fontSize: 18),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Style : ',
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
                            'How to : ',
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
                          InkWell(
                            onTap: () => _launchUrl(widget.glink),
                            child: Text(
                              widget.glink.isEmpty ? 'N/A' : widget.glink,
                              style: const TextStyle(
                                color: colour_main,
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

                // Duration
                if (_showDuration)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Duration (Today to Tomorrow)',
                          style: TextStyle(color: Colors.grey, fontSize: 18),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: colour_available,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  _displayDate(_startDate),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            const Text(
                              ' to ',
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.grey,
                              ),
                            ),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: colour_available,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  _displayDate(_endDate),
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

                const SizedBox(height: 30),

                // Borrow Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _showDuration
                        ? (_hasRequested || _isRequesting
                              ? null
                              : _handleBorrow)
                        : (_hasRequested ||
                                  widget.currentStatus != 'Available' ||
                                  _isRequesting
                              ? null
                              : _onBorrowPressed),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _hasRequested || _isRequesting
                          ? Colors.grey
                          : colour_borrow,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      _buttonText,
                      style: const TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),

          // SUCCESS POPUP
          if (_showPopup)
            Container(
              color: Colors.black54,
              child: Center(
                child: Container(
                  margin: const EdgeInsets.all(40),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 30,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: colour_available,
                        child: Icon(Icons.check, color: Colors.white, size: 50),
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Request Sent!',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Your borrow request has been submitted.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey, fontSize: 16),
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
