import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ===== API SERVICE =====
class ApiService {
  static String get baseUrl {
    if (Platform.isIOS) {
      return 'http://localhost:3000';
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2:3000';
    } else {
      return 'http://192.168.1.123:3000'; // change to your Node.js IP
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
    final items = (data['items'] as List)
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
    return items;
  }
}

// ===== MAIN PAGE =====
class StudentHistory extends StatefulWidget {
  const StudentHistory({super.key});

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
  String? _borrowerId;

  // --- Helper methods ---
  DateTime _parseDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return DateTime(1900);
    try {
      return DateFormat('dd MMM yyyy', 'en_US').parse(dateStr);
    } catch (_) {
      return DateTime(1900);
    }
  }

  void _sortHistory(List<Map<String, dynamic>> list) {
    list.sort(
      (a, b) => _parseDate(
        b['borrowedDate'],
      ).compareTo(_parseDate(a['borrowedDate'])),
    );
  }

  Future<void> _loadAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    final userId = prefs.getInt('user_id');
    _borrowerId = userId?.toString();
  }

  Future<void> _fetch() async {
    if (_token == null || _borrowerId == null) {
      await _loadAuthData();
      if (_token == null || _borrowerId == null) {
        setState(() {
          _error = 'User not logged in or missing ID.';
          _loading = false;
        });
        return;
      }
    }

    setState(() {
      _loading = true;
      _error = '';
    });

    try {
      final items = await ApiService.fetchHistory(
        token: _token!,
        borrowerId: _borrowerId!,
        query: _search.text.trim(),
      );

      _sortHistory(items);

      setState(() {
        _filtered = items;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().contains('401')
            ? 'Authentication failed. Please log in again.'
            : e.toString();
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  void _onSearchChange() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), _fetch);
    setState(() {});
  }

  void _clearSearch() {
    _search.clear();
    FocusScope.of(context).unfocus();
    _fetch();
  }

  @override
  void initState() {
    super.initState();
    _loadAuthData().then((_) {
      _fetch();
    });
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
                    hintText: 'Search by game, lender . . .',
                    prefixIcon: const Icon(
                      Icons.search,
                      color: Color(0xFFE67E22),
                    ),
                    suffixIcon: (_search.text.isEmpty)
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
                      : (_error.isNotEmpty)
                      ? Center(child: Text('Error: $_error'))
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

// ===== CARD WIDGET =====
class HistoryCard extends StatelessWidget {
  final Map<String, dynamic> item;
  const HistoryCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final status = (item['status'] ?? '').toString().toLowerCase();

    // Status color and label mapping
    Color statusColor;
    String statusLabel;

    if (status == 'approve') {
      statusColor = const Color(0xFF486E5A); // green
      statusLabel = 'Approve';
    } else if (status == 'disapprove') {
      statusColor = const Color(0xFFDD4430); // red
      statusLabel = 'Disapprove';
    } else if (status == 'pending') {
      statusColor = const Color(0xFFE67E22); // orange
      statusLabel = 'Pending';
    } else if (status == 'returned') {
      statusColor = const Color(0xFF486E5A); // green
      statusLabel = 'Returned';
    } else {
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
            'Borrow ID : ${item['id'] ?? '-'}',
            style: const TextStyle(fontSize: 13, color: Colors.black54),
          ),
          const SizedBox(height: 12),
          _row('Approved by :', item['approvedBy'] ?? '-'),
          const SizedBox(height: 6),
          Row(
            children: [
              const SizedBox(
                width: 130,
                child: Text(
                  'Status :',
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
              (item['reason']?.isNotEmpty ?? false)) ...[
            _row('Reason :', item['reason'] ?? ''),
            const SizedBox(height: 6),
          ],
          if (status == 'approve' || status == 'returned') ...[
            _row('Returned to :', item['returnedTo'] ?? '-'),
            const SizedBox(height: 6),
          ],
          const Divider(height: 20, thickness: 0.5),
          _row('Borrowed date :', item['borrowedDate'] ?? '-'),
          const SizedBox(height: 6),
          if (status == 'approve' || status == 'returned')
            _row('Returned date :', item['returnedDate'] ?? '-'),
        ],
      ),
    );
  }

  static Widget _row(String label, String value) {
    return Row(
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
    );
  }
}
