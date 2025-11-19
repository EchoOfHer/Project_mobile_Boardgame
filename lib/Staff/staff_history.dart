import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '/login/login.dart'; // ✅ Import เพื่อใช้ baseUrl

// --- Color Definitions ---
const Color colour_main_orange = Color(0xFFE67E22);
const Color colour_available_green = Color(0xFF486E5A);
const Color colour_disable_red = Color(0xFFDD4430);

// --- API Service ---
class ApiService {
  // ❌ ลบ get baseUrl เดิมออก
  // ✅ ใช้ baseUrl จาก login.dart

  // Fetch ALL history for STAFF
  static Future<List<Map<String, dynamic>>> fetchStaffHistory({
    required String token,
    String query = '',
  }) async {
    // ✅ ใช้ baseUrl ตัวกลาง
    final uri = Uri.parse(
      '$baseUrl/StaffHistory',
    ).replace(queryParameters: {'q': query});

    final res = await http.get(
      uri,
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    if (res.statusCode != 200) {
      throw Exception(
        'Failed to load staff history. Status: ${res.statusCode}',
      );
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    return (data['items'] as List).cast<Map<String, dynamic>>();
  }
}

// --- STAFF HISTORY PAGE ---
class StaffHistory extends StatefulWidget {
  final String authToken; // ★ 1. เพิ่มตัวแปรรับ Token

  // ★ 2. รับค่าผ่าน Constructor
  const StaffHistory({super.key, required this.authToken});

  @override
  State<StaffHistory> createState() => _StaffHistoryState();
}

class _StaffHistoryState extends State<StaffHistory> {
  final TextEditingController _search = TextEditingController();
  Timer? _debounce;

  List<Map<String, dynamic>> _filtered = [];
  bool _loading = true;
  String _error = '';
  // ❌ ไม่ต้องประกาศ _token แล้ว

  DateTime _parseDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return DateTime(1900);
    try {
      return DateFormat('dd MMM yyyy', 'en_US').parse(dateStr);
    } catch (_) {
      return DateTime(1900);
    }
  }

  void _sortHistory(List<Map<String, dynamic>> list) {
    list.sort((a, b) {
      final dateA = _parseDate(a['borrowedDate']);
      final dateB = _parseDate(b['borrowedDate']);
      return dateB.compareTo(dateA);
    });
  }

  // ❌ ลบ _loadAuthData ออก

  Future<void> _fetch() async {
    // ไม่ต้องเช็ค Token null เพราะรับมาจาก Parent แล้ว

    setState(() {
      _loading = true;
      _error = '';
    });

    try {
      final items = await ApiService.fetchStaffHistory(
        token: widget.authToken, // ✅ ใช้ Token จาก widget โดยตรง
        query: _search.text.trim(),
      );

      _sortHistory(items);
      setState(() => _filtered = items);
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _onSearchChange() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), _fetch);
  }

  void _clearSearch() {
    _search.clear();
    FocusScope.of(context).unfocus();
    _fetch();
  }

  @override
  void initState() {
    super.initState();
    _fetch();
    _search.addListener(_onSearchChange);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _fetch,
        child: Container(
          color: const Color(0xFFF7F7F7),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Staff History',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: colour_main_orange,
                ),
              ),
              const SizedBox(height: 12),

              // SEARCH BAR
              TextField(
                controller: _search,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'Search by student, lender, game, status...',
                  prefixIcon: const Icon(
                    Icons.search,
                    color: colour_main_orange,
                  ),
                  suffixIcon: _search.text.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(
                            Icons.close,
                            color: colour_main_orange,
                          ),
                          onPressed: _clearSearch,
                        ),
                  filled: true,
                  fillColor: Colors.white,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(
                      color: Color(0xFFFFD6A5),
                      width: 2,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(
                      color: colour_main_orange,
                      width: 2.5,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Expanded(
                child: _loading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: colour_main_orange,
                        ),
                      )
                    : _error.isNotEmpty
                    ? Center(child: Text('Error: $_error'))
                    : _filtered.isEmpty
                    ? const Center(
                        child: Text(
                          'No history found.',
                          style: TextStyle(color: Colors.black54),
                        ),
                      )
                    : ListView.separated(
                        itemCount: _filtered.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 16),
                        itemBuilder: (_, i) =>
                            StaffHistoryCard(item: _filtered[i]),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- STAFF HISTORY CARD ---
class StaffHistoryCard extends StatelessWidget {
  final Map<String, dynamic> item;
  const StaffHistoryCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final status = (item['status'] ?? '').toString().toLowerCase();
    Color statusColor;

    switch (status) {
      case 'approve':
        statusColor = colour_available_green;
        break;
      case 'disapprove':
        statusColor = colour_disable_red;
        break;
      case 'returned':
        statusColor = colour_available_green;
        break;
      case 'cancelled':
        statusColor = Colors.grey;
        break;
      default:
        statusColor = colour_main_orange;
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item['game'] ?? '-',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),

          Text(
            'ID: ${item['id'] ?? '-'}',
            style: const TextStyle(fontSize: 13, color: Colors.black54),
          ),

          const SizedBox(height: 12),
          _row("Student:", item['borrowedBy'] ?? '-'),
          _row("Lender:", item['lenderName'] ?? '-'),

          Row(
            children: [
              const SizedBox(
                width: 130,
                child: Text(
                  "Status:",
                  style: TextStyle(fontSize: 13, color: Colors.black54),
                ),
              ),
              Text(
                item['status'] ?? '',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: statusColor,
                ),
              ),
            ],
          ),

          if ((item['reason'] ?? '').toString().isNotEmpty)
            _row("Reason:", item['reason']),

          const Divider(height: 20),
          _row("Borrowed:", item['borrowedDate'] ?? '-'),
          _row("Returned:", item['returnedDate'] ?? '-'),
        ],
      ),
    );
  }

  static Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, color: Colors.black54),
            ),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }
}
