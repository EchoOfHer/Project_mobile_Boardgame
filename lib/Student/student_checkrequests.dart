import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // Required for date formatting
import 'student_main.dart' show url;

// Color Definitions
const Color colour_main = Color(0xFFFF8000);
const Color colour_available = Color(0xFF729382);
const Color colour_borrow = Color(0xFFEFA34B);
const Color colour_disable = Color(0xFFFF7C7C);

// --- Date Formatting Helper (DD Mon. - e.g., 12 Nov) ---
String _formatDate(dynamic dateInput) {
  if (dateInput == null) return '';
  try {
    String dateStr = dateInput.toString();
    DateTime dateTime;

    // 1. ตรวจสอบว่ามี Time Zone Indicator (Z/+/T) หรือไม่
    if (dateStr.contains('T') ||
        dateStr.contains('+') ||
        dateStr.endsWith('Z')) {
      // ถ้ามี Time Zone Indicator: แปลงเป็น Local Time (เพื่อแก้ปัญหา Offset จาก Express)
      dateTime = DateTime.parse(dateStr).toLocal();
    } else {
      // 2. ถ้ามีแค่ YYYY-MM-DD (จากคอลัมน์ DATE ใน MySQL):
      // ตีความว่าเป็น Local Date (Non-UTC) ณ เวลา 00:00:00 เพื่อป้องกันการปัดวันที่ถอยหลัง
      dateTime = DateTime.parse(dateStr);
    }

    // Format to DD Mon. (e.g., 12 Nov) <--- FIXED FORMAT
    return DateFormat('dd MMM').format(dateTime);
  } catch (e) {
    return dateInput.toString();
  }
}

// --- Data Model ---
class BorrowItem {
  final int borrowId;
  final String gameName;
  final String picPath;
  final String fromDate;
  final String returnDate;
  final String borrowStatus;
  final String gameInventoryStatus;
  final String howtoLink;

  BorrowItem.fromJson(Map<String, dynamic> json)
    : borrowId = json['borrow_id'] as int,
      gameName = json['game_name'] as String,
      picPath = json['pic_path'] as String,
      // Dates are formatted here
      fromDate = _formatDate(json['from_date']),
      returnDate = _formatDate(json['return_date']),
      borrowStatus = json['borrow_status'] as String,
      gameInventoryStatus = json['game_inventory_status'] as String,
      howtoLink = json['howto_link'] as String;
}
// --- Widget Definition ---

class StudentCheckrequests extends StatefulWidget {
  final int userId;
  const StudentCheckrequests({super.key, required this.userId});

  @override
  State<StudentCheckrequests> createState() => _StudentCheckrequestsState();
}

class _StudentCheckrequestsState extends State<StudentCheckrequests> {
  late Future<List<BorrowItem>> _borrowFuture;

  @override
  void initState() {
    super.initState();
    _borrowFuture = _fetchBorrowRequests();
  }

  // 🔑 Helper function to refresh FutureBuilder
  void _refreshData() {
    if (mounted) {
      setState(() {
        _borrowFuture = _fetchBorrowRequests();
      });
    }
  }

  // 🔑 Central function to update status via API (for Cancel and Return)
  Future<bool> _updateBorrowStatus(
    int borrowId,
    String newStatus,
    String actionName,
  ) async {
    final uri = Uri.http(url, '/api/borrow/status/$borrowId');

    try {
      final response = await http.put(
        uri,
        // สำคัญ: ต้องกำหนด Headers เป็น application/json
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'status': newStatus}),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('$actionName request success!')));
        return true;
      } else {
        final data = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${data['message'] ?? 'Failed to update status'}'),
            backgroundColor: colour_disable,
          ),
        );
        return false;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Network error during $actionName: $e'),
          backgroundColor: colour_disable,
        ),
      );
      return false;
    }
  }

  // 🚀 API CALL: Fetch active requests
  Future<List<BorrowItem>> _fetchBorrowRequests() async {
    final uri = Uri.http(url, '/api/check-request/${widget.userId}');

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['data'] == null || data['data'].isEmpty) {
          return [];
        }

        final List<dynamic> jsonList = data['data'];
        return [BorrowItem.fromJson(jsonList.first)];
      } else {
        throw Exception(
          'Failed to load request: Status ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error fetching borrow requests: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Request Status",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w600,
                    color: colour_main,
                  ),
                ),
                const Divider(color: colour_main),
                const SizedBox(height: 10),
                FutureBuilder<List<BorrowItem>>(
                  future: _borrowFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(color: colour_main),
                      );
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Error: ${snapshot.error}',
                          style: TextStyle(color: colour_disable),
                        ),
                      );
                    } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                      final item = snapshot.data!.first;
                      return _buildStatusCard(item);
                    } else {
                      return _buildNoActiveItemText();
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- UI Builder ---

  Widget _buildStatusCard(BorrowItem item) {
    final String status = item.borrowStatus.toLowerCase();

    final bool isPending = status == 'pending';
    final bool isApproved = status == 'approved';
    final bool isReturning = status == 'returning';

    final String currentStatusText;
    final Color statusTextColor;

    if (isApproved) {
      currentStatusText = "In use";
      statusTextColor = colour_available;
    } else if (isReturning) {
      currentStatusText = "Returning in process";
      statusTextColor = Colors.grey;
    } else if (isPending) {
      currentStatusText = "Pending";
      statusTextColor = colour_borrow;
    } else {
      currentStatusText = "Unknown Status ($status)";
      statusTextColor = Colors.black;
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            Container(
              width: 125,
              height: 125,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  'http://$url/${item.picPath}',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.broken_image),
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Info and Button Section
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.gameName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Dates are now formatted as DD Mon. (e.g., 12 Nov)
                  Text("From: ${item.fromDate}\nTo: ${item.returnDate}"),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        currentStatusText,
                        style: TextStyle(
                          color: statusTextColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      // Show Return button only if APPROVED
                      if (isApproved)
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: colour_main,
                            side: const BorderSide(color: colour_main),
                          ),
                          onPressed: () => _showReturningDialog(item.borrowId),
                          child: const Text("Return"),
                        )
                      // Show Cancel button only if PENDING
                      else if (isPending)
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: colour_disable,
                            side: const BorderSide(color: colour_disable),
                          ),
                          onPressed: () => _showCancelDialog(item.borrowId),
                          child: const Text("Cancel"),
                        )
                      else
                        const SizedBox.shrink(),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoActiveItemText() {
    return const Center(
      child: Text(
        "You have no active item or pending request.",
        style: TextStyle(color: Colors.grey),
      ),
    );
  }

  // --- Dialogs ---

  void _showReturningDialog(int borrowId) {
    _updateBorrowStatus(borrowId, 'returning', 'Return').then((success) {
      if (success && mounted) {
        showDialog(
          context: context,
          builder: (dialogContext) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.loop, size: 60, color: colour_available),
                const SizedBox(height: 16),
                const Text(
                  "Returning",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Please contact staff to approve",
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );

        Future.delayed(const Duration(seconds: 2), () {
          if (mounted && Navigator.canPop(context)) {
            Navigator.pop(context);
          }
          _refreshData();
        });
      }
    });
  }

  void _showCancelDialog(int borrowId) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cancel_outlined, size: 60, color: colour_disable),
            const SizedBox(height: 16),
            Text(
              "Cancel",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: colour_disable,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Are you sure you want to cancel your request?",
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                OutlinedButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text("No", style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colour_disable,
                  ),
                  onPressed: () async {
                    Navigator.pop(dialogContext); // 1. ปิด Dialog

                    // 2. เรียก API และรอผลลัพธ์
                    final bool success = await _updateBorrowStatus(
                      borrowId,
                      'cancelled',
                      'Cancel',
                    );

                    // 3. ถ้า API สำเร็จค่อย refresh หน้าจอ
                    if (success) {
                      _refreshData();
                    }
                  },
                  child: const Text(
                    "Yes",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
