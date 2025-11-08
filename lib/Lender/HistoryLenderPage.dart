import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async'; // สำหรับ Timer และ Debounce
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Constants ที่นำมาจาก lender_main.dart
const colour_main = Color(0xFFFF8000);
const colour_disable = Color(0xFFFF7C7C);
const colour_borrow = Color(0xFFEFA34B);
const url = '10.0.2.2:3000';

class HistoryLenderPage extends StatefulWidget {
  final int lenderId;
  const HistoryLenderPage({super.key, required this.lenderId});

  @override
  State<HistoryLenderPage> createState() => _HistoryLenderPageState();
}

class _HistoryLenderPageState extends State<HistoryLenderPage> {
  List<dynamic> _historyItems = [];
  bool _isLoading = true;
  String _searchQuery = '';
  Timer? _debounce; // สำหรับ Debounce Search
  
  // ตัวแปรสำหรับ API Call
  String? _jwtToken;

  @override
  void initState() {
    super.initState();
    _loadTokenAndFetchHistory();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  // 1. โหลด Token และเรียก API
  Future<void> _loadTokenAndFetchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _jwtToken = prefs.getString('token');
    });

    if (_jwtToken != null) {
      _fetchHistory();
    } else {
      // Handle case where token is missing (e.g., redirect to login)
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // 2. ฟังก์ชันเรียก API สำหรับดึงประวัติ
  Future<void> _fetchHistory() async {
    if (_jwtToken == null) return;

    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }
    
    // สร้าง URL ด้วย query parameter 'q'
    final apiUri = Uri.parse('http://$url/api/lender/history?q=$_searchQuery');

    try {
      final response = await http.get(
        apiUri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_jwtToken', // ใช้ Token ใน Header
        },
      ).timeout(const Duration(seconds: 15)); // เพิ่ม Timeout ให้ API

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (mounted) {
          setState(() {
            _historyItems = data['items'] ?? [];
          });
        }
      } else {
        // Log หรือแสดง error message จาก server
        print('Failed to load history. Status: ${response.statusCode}, Body: ${response.body}');
        if (mounted) {
          _showSnackBar('Failed to load history: ${response.statusCode}');
        }
        _historyItems = [];
      }
    } on TimeoutException catch (_) {
       if (mounted) {
          _showSnackBar('การโหลดข้อมูลใช้เวลานานเกินไป');
          print('Timeout fetching lender history.');
          _historyItems = [];
       }
    } catch (e) {
      print('Error fetching history: $e');
      if (mounted) {
         _showSnackBar('เกิดข้อผิดพลาดในการเชื่อมต่อ');
         _historyItems = [];
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // 3. ฟังก์ชันสำหรับ Debounce Search
  void _onSearchChanged(String query) {
    _searchQuery = query;
    // ยกเลิก Timer ตัวเก่า (ถ้ามี)
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    
    // ตั้ง Timer ใหม่
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _fetchHistory(); // เรียก API หลังจากผู้ใช้หยุดพิมพ์ 500ms
    });
  }
  
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
        backgroundColor: colour_disable,
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ประวัติการยืม/คืน'),
        backgroundColor: colour_main,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: _onSearchChanged, // ใช้ Debounce
              decoration: InputDecoration(
                hintText: 'ค้นหาด้วยชื่อเกม...',
                prefixIcon: const Icon(Icons.search, color: colour_main),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: const BorderSide(color: colour_main),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: const BorderSide(color: colour_main, width: 2.0),
                ),
              ),
            ),
          ),
          
          // Content Area (History List or Loading/Error)
          Expanded(
            child: _buildHistoryContent(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildHistoryContent() {
    if (_isLoading) {
      // แสดง Loading Indicator ตรงกลางเมื่อกำลังโหลดหรือค้นหา
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: colour_main),
            SizedBox(height: 16),
            Text('กำลังโหลดประวัติ...', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    if (_historyItems.isEmpty) {
      // แสดงข้อความเมื่อไม่พบรายการ
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              FontAwesomeIcons.exclamationCircle,
              size: 50,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 10),
            Text(
              _searchQuery.isEmpty ? 'ไม่พบรายการประวัติ' : 'ไม่พบรายการสำหรับ "${_searchQuery}"',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    
    // แสดงรายการประวัติ
    return ListView.builder(
      itemCount: _historyItems.length,
      itemBuilder: (context, index) {
        final item = _historyItems[index];
        return _buildHistoryCard(item);
      },
    );
  }

  // Card แสดงรายละเอียดประวัติ
  Widget _buildHistoryCard(Map<String, dynamic> item) {
    Color statusColor = Colors.grey;
    IconData statusIcon = Icons.hourglass_empty;

    switch (item['status']) {
      case 'Approved':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'Disapproved':
        statusColor = colour_disable;
        statusIcon = Icons.cancel;
        break;
      case 'Returned':
        statusColor = Colors.blue.shade700;
        statusIcon = Icons.history;
        break;
      case 'Cancelled':
        statusColor = Colors.red.shade700;
        statusIcon = Icons.close;
        break;
      case 'Returning':
        statusColor = colour_borrow; // สีส้ม
        statusIcon = Icons.assignment_return;
        break;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row 1: Status & Borrow ID
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(statusIcon, color: statusColor, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      item['status'] ?? 'Unknown',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
                Text(
                  'ID: ${item['id']}',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
            const Divider(height: 15, thickness: 0.5),

            // Row 2: Game Name
            Text(
              item['game'] ?? 'N/A',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colour_main,
              ),
            ),
            const SizedBox(height: 5),

            // Row 3: Borrower
            _buildDetailRow(
              icon: FontAwesomeIcons.user,
              label: 'ผู้ยืม:',
              value: item['borrower'] ?? 'N/A',
            ),

            // Row 4: Borrowed Date
            _buildDetailRow(
              icon: Icons.calendar_today,
              label: 'วันที่ยืม:',
              value: item['borrowedDate'] ?? 'N/A',
            ),

            // Row 5: Return Date
            _buildDetailRow(
              icon: Icons.date_range, // <-- แก้ไขตรงนี้
              label: 'วันกำหนดคืน:',
              value: item['returnedDate'] ?? 'N/A',
            ),
            
            // Row 6: Approved By (Lender)
            if (item['approvedBy'] != null)
              _buildDetailRow(
                icon: Icons.person_add_alt_1,
                label: 'อนุมัติโดย:',
                value: item['approvedBy'],
              ),

            // Row 7: Returned To (Staff)
            if (item['returnedTo'] != null && item['status'] == 'Returned')
              _buildDetailRow(
                icon: Icons.person_pin,
                label: 'รับคืนโดย:',
                value: item['returnedTo'],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({required IconData icon, required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.black54),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}