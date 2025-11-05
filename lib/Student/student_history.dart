import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static String get baseUrl {
    if (Platform.isIOS) {
      return 'http://localhost:3000';
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2:3000';
    } else {
      return 'http://192.168.1.123:3000';
    }
  }

  static Future<List<Map<String, dynamic>>> fetchHistory({
    required String token,
    required dynamic borrowerId,
    String query = '',
  }) async {
    final uri = Uri.parse('$baseUrl/borrow-history').replace(
      queryParameters: {'borrower_id': borrowerId.toString(), 'q': query},
    );

    final res = await http.get(
      uri,
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    if (res.statusCode != 200) {
      throw Exception('Failed to load history. Status: ${res.statusCode}');
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    return (data['items'] as List).cast<Map<String, dynamic>>();
  }
}

class StudentHistory extends StatefulWidget {
  final int userId;
  const StudentHistory({super.key, required this.userId});

  @override
  State<StudentHistory> createState() => _StudentHistoryState();
}

class _StudentHistoryState extends State<StudentHistory> {
  final TextEditingController _search = TextEditingController();
  Timer? _debounce;

  List<Map<String, dynamic>> _filtered = [];
  bool _loading = true;
  String _error = '';
  String? _token;

  DateTime _parseDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return DateTime(1900);
    try {
      return DateFormat('dd MMM yyyy', 'en_US').parse(dateStr);
    } catch (_) {
      return DateTime(1900);
    }
  }

  // SORTING: Pending/Returning on top, others by latest date
  void _sortHistory(List<Map<String, dynamic>> list) {
    list.sort((a, b) {
      final statusA = (a['status'] ?? '').toString().toLowerCase();
      final statusB = (b['status'] ?? '').toString().toLowerCase();

      // 1. Pending & Returning ขึ้นก่อนเสมอ
      final isActiveA = statusA == 'pending' || statusA == 'returning';
      final isActiveB = statusB == 'pending' || statusB == 'returning';

      if (isActiveA && !isActiveB) return -1;
      if (!isActiveA && isActiveB) return 1;

      // 2. ถ้าสถานะเท่ากัน → เรียงตามวันที่ล่าสุด
      final dateA = _parseDate(a['borrowedDate']);
      final dateB = _parseDate(b['borrowedDate']);
      return dateB.compareTo(dateA); // ใหม่ → เก่า
    });
  }

  Future<void> _loadAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
  }

  Future<void> _fetch() async {
    await _loadAuthData();
    if (_token == null || widget.userId == 0) {
      setState(() {
        _error = 'Please log in again.';
        _loading = false;
      });
      return;
    }

    setState(() => _loading = true);

    try {
      final items = await ApiService.fetchHistory(
        token: _token!,
        borrowerId: widget.userId,
        query: _search.text.trim(),
      );

      _sortHistory(items);
      setState(() => _filtered = items);
    } catch (e) {
      setState(() {
        _error = e.toString().contains('401')
            ? 'Session expired. Please log in again.'
            : 'Error: ${e.toString()}';
      });
    } finally {
      setState(() => _loading = false);
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
    _loadAuthData().then((_) => _fetch());
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
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'History',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE67E22),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _search,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => _fetch(),
                  decoration: InputDecoration(
                    hintText: 'Search by game, lender...',
                    prefixIcon: const Icon(
                      Icons.search,
                      color: Color(0xFFE67E22),
                    ),
                    suffixIcon: _search.text.isEmpty
                        ? null
                        : IconButton(
                            onPressed: _clearSearch,
                            icon: const Icon(
                              Icons.close,
                              color: Color(0xFFE67E22),
                            ),
                          ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
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
                        color: Color(0xFFE67E22),
                        width: 2.5,
                      ),
                    ),
                    hintStyle: const TextStyle(color: Colors.black45),
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: _loading
                      ? const Center(child: CircularProgressIndicator())
                      : _error.isNotEmpty
                      ? Center(
                          child: Text(
                            'Error: $_error',
                            style: const TextStyle(color: Colors.red),
                          ),
                        )
                      : _filtered.isEmpty
                      ? const Center(
                          child: Text(
                            'No results found',
                            style: TextStyle(color: Colors.black54),
                          ),
                        )
                      : ListView.separated(
                          itemCount: _filtered.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 16),
                          itemBuilder: (_, i) =>
                              HistoryCard(item: _filtered[i]),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// CARD (รองรับทุกสถานะ + สีสวย)
class HistoryCard extends StatelessWidget {
  final Map<String, dynamic> item;
  const HistoryCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final status = (item['status'] ?? '').toString().toLowerCase();

    Color statusColor;
    String statusLabel;

    switch (status) {
      case 'pending':
        statusColor = const Color(0xFFE67E22);
        statusLabel = 'Pending';
        break;
      case 'returning':
        statusColor = const Color(0xFFE67E22);
        statusLabel = 'Returning';
        break;
      case 'approve':
        statusColor = const Color(0xFF486E5A);
        statusLabel = 'Approved';
        break;
      case 'disapprove':
        statusColor = const Color(0xFFDD4430);
        statusLabel = 'Disapproved';
        break;
      case 'returned':
        statusColor = const Color(0xFF486E5A);
        statusLabel = 'Returned';
        break;
      case 'cancelled':
        statusColor = Colors.grey;
        statusLabel = 'Cancelled';
        break;
      default:
        statusColor = Colors.black54;
        statusLabel = status;
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
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

          if (status != 'disapprove' && status != 'cancelled')
            _row('Approved by:', item['approvedBy'] ?? '-'),

          Row(
            children: [
              const SizedBox(
                width: 130,
                child: Text(
                  'Status:',
                  style: TextStyle(fontSize: 13, color: Colors.black54),
                ),
              ),
              Text(
                statusLabel,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: statusColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          if (status == 'disapprove' &&
              (item['reason']?.toString().isNotEmpty ?? false))
            _row('Reason:', item['reason'] ?? ''),

          if (status == 'approve' || status == 'returned')
            _row('Returned to:', item['returnedTo'] ?? '-'),

          const Divider(height: 20),
          _row('Borrowed:', item['borrowedDate'] ?? '-'),
          if (status == 'approve' || status == 'returned')
            _row('Returned:', item['returnedDate'] ?? '-'),
        ],
      ),
    );
  }

  static Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
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
