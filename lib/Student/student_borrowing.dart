// lib/Student/student_borrowing.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '/Staff/game_data.dart';
import 'student_main.dart' show colour_main, colour_disable, colour_available, colour_borrow;

dynamic _get(dynamic item, String key) {
  if (item == null) return null;
  final obj = item as GameItem;
  switch (key) {
    case 'gameName': return obj.gameName;
    case 'gameStyle': return obj.gameStyle;
    case 'picPath': return obj.picPath;
    case 'status': return obj.status;
    case 'minP': return obj.minP;
    case 'maxP': return obj.maxP;
    case 'gTime': return obj.gTime;
    case 'g_link': return obj.g_link;
    case 'gameGroup': return obj.gameGroup;
    default: return null;
  }
}

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
  bool _showDuration = false;
  DateTime? _startDate;
  DateTime? _endDate;

  // ตรวจสอบว่าสามารถกด Borrow ได้หรือไม่
  bool get _canBorrow => !_hasRequestedAnyGame && _remaining > 0 && _startDate != null && _endDate != null;

  int get _remaining {
    return gameList
        .where((g) => g.gameGroup == widget.gameGroup && g.status == 'Available')
        .length;
  }

  // เปิด popup เลือกวันที่
  Future<void> _selectDate(bool isStart) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: (isStart ? _startDate : _endDate) ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 90)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.orange,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: Colors.orange),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && mounted) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          if (_endDate != null && _endDate!.isBefore(picked)) {
            _endDate = null;
          }
        } else {
          if (_startDate != null && picked.isBefore(_startDate!)) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('End date cannot be before start date.')),
            );
          } else {
            _endDate = picked;
          }
        }
      });
    }
  }

  // กดปุ่ม Borrow ครั้งแรก → แสดง UI เลือกวัน
  void _onBorrowPressed() {
    if (_hasRequestedAnyGame || _remaining <= 0) return;
    setState(() => _showDuration = true);
  }

  // ยืนยันการยืม
  Future<void> _handleBorrow() async {
    if (!_canBorrow) return;

    setState(() => _showPopup = true);

    // ตั้งค่าสถานะว่าจองแล้ว
    _hasRequestedAnyGame = true;
    _lastRequestedGroup = widget.gameGroup;

    // อัปเดตสถานะเกม
    bool changed = false;
    for (final g in gameList) {
      if (g.gameGroup == widget.gameGroup && g.status == 'Available' && !changed) {
        g.status = 'Borrowing';
        changed = true;
        break;
      }
    }

    await Future.delayed(const Duration(seconds: 3));
    if (mounted) setState(() => _showPopup = false);
  }

  Future<void> _launchUrl(String url) async {
    final String fullUrl = url.trim().isNotEmpty && !url.startsWith('http') ? 'http://$url' : url;
    final Uri uri = Uri.parse(fullUrl);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open the link.')),
        );
      }
    }
  }

  String get _borrowButtonText {
    if (_hasRequestedAnyGame) return 'You already requested a game';
    if (_remaining <= 0) return 'Out of stock';
    return 'Borrow';
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
          style: const TextStyle(color: Colors.orange, fontSize: 22, fontWeight: FontWeight.bold),
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
                          child: const Icon(Icons.broken_image, size: 80, color: Colors.grey),
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
                            Text('Name : ', style: TextStyle(color: Colors.grey, fontSize: 18)),
                            SizedBox(height: 16),
                            Text('Game Style : ', style: TextStyle(color: Colors.grey, fontSize: 18)),
                            SizedBox(height: 16),
                            Text('Players : ', style: TextStyle(color: Colors.grey, fontSize: 18)),
                            SizedBox(height: 16),
                            Text('Time : ', style: TextStyle(color: Colors.grey, fontSize: 18)),
                            SizedBox(height: 16),
                            Text('Remaining : ', style: TextStyle(color: Colors.grey, fontSize: 18)),
                            SizedBox(height: 16),
                            Text('How to play : ', style: TextStyle(color: Colors.grey, fontSize: 18)),
                          ],
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.gameName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 16),
                            Text(widget.gameStyle, style: const TextStyle(fontSize: 18)),
                            const SizedBox(height: 16),
                            Text(widget.players, style: const TextStyle(fontSize: 18)),
                            const SizedBox(height: 16),
                            Text(widget.time, style: const TextStyle(fontSize: 18)),
                            const SizedBox(height: 16),
                            Text(
                              '$_remaining board',
                              style: TextStyle(color: _remaining == 0 ? colour_disable : Colors.black, fontSize: 18),
                            ),
                            const SizedBox(height: 16),
                            InkWell(
                              onTap: () => _launchUrl(widget.glink),
                              child: Text(
                                widget.glink.isEmpty ? 'N/A' : widget.glink,
                                style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],

                  // UI ภาพที่ 2: Duration
                  if (_showDuration) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Duration', style: TextStyle(color: Colors.grey, fontSize: 18)),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => _selectDate(true),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                    decoration: BoxDecoration(
                                      color: colour_available,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      _startDate == null ? 'From' : _formatDate(_startDate),
                                      style: const TextStyle(color: Colors.white, fontSize: 16),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8),
                                child: Text('-', style: TextStyle(fontSize: 20, color: Colors.grey)),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: _startDate == null ? null : () => _selectDate(false),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                    decoration: BoxDecoration(
                                      color: _startDate == null ? Colors.grey[300] : colour_available,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      _endDate == null ? 'To' : _formatDate(_endDate),
                                      style: TextStyle(
                                        color: _startDate == null ? Colors.grey[600] : Colors.white,
                                        fontSize: 16,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
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

                  // ปุ่ม Borrow (เปลี่ยนสถานะเมื่อจองแล้ว)
                  Center(
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _showDuration
                            ? (_canBorrow ? _handleBorrow : null)
                            : (_hasRequestedAnyGame || _remaining <= 0 ? null : _onBorrowPressed),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _hasRequestedAnyGame || _remaining <= 0
                              ? Colors.grey
                              : colour_borrow,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(
                          _borrowButtonText,
                          style: const TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // Success Popup
          if (_showPopup)
            GestureDetector(
              onTap: () {},
              child: Container(
                color: Colors.black54,
                alignment: Alignment.center,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(color: colour_available, shape: BoxShape.circle),
                        child: const Icon(Icons.check, color: Colors.white, size: 50),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Request sent',
                        style: TextStyle(color: Colors.green, fontSize: 22, fontWeight: FontWeight.bold),
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