import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
// นำเข้าตัวแปร url จากไฟล์ lender_main (หรือไฟล์หลักของ lender)
import 'lender_main.dart' show url;

// --- Color Definitions ---
const Color colour_main_orange = Color(0xFFE67E22);
const Color colour_available_green = Color(0xFF486E5A);
const Color colour_disable_red = Color(0xFFDD4430);

// --- API Service ---
class ApiService {
  static Future<List<Map<String, dynamic>>> fetchLenderHistory({
    required String token,
    String query = '',
  }) async {
    // ✅ ใช้ Uri.http กับตัวแปร url กลาง
    final uri = Uri.http(url, '/HistoryLenderPage', {'q': query});

    final res = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $token'}, // ✅ มี JWT แล้ว
    );

    if (res.statusCode != 200) {
      throw Exception('Failed to load history. Status: ${res.statusCode}');
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    return (data['items'] as List).cast<Map<String, dynamic>>();
  }
}

// --- Main Lender History Widget ---
class HistoryLenderPage extends StatefulWidget {
  final String authToken;

  const HistoryLenderPage({super.key, required this.authToken});

  @override
  State<HistoryLenderPage> createState() => _HistoryLenderPageState();
}

class _HistoryLenderPageState extends State<HistoryLenderPage> {
  final TextEditingController _search = TextEditingController();
  Timer? _debounce;
  List<Map<String, dynamic>> _filtered = [];
  bool _loading = true;
  String _error = '';

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

  Future<void> _fetch() async {
    setState(() => _loading = true);
    _error = '';

    try {
      final items = await ApiService.fetchLenderHistory(
        token: widget.authToken,
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
      if (mounted) {
        setState(() => _loading = false);
      }
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
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Lender History',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: colour_main_orange,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _search,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => _fetch(),
                  decoration: InputDecoration(
                    hintText: 'Search by game, borrower...',
                    prefixIcon: const Icon(
                      Icons.search,
                      color: colour_main_orange,
                    ),
                    suffixIcon: _search.text.isEmpty
                        ? null
                        : IconButton(
                            onPressed: _clearSearch,
                            icon: const Icon(
                              Icons.close,
                              color: colour_main_orange,
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
                        color: colour_main_orange,
                        width: 2.5,
                      ),
                    ),
                    hintStyle: const TextStyle(color: Colors.black45),
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
                      ? Center(
                          child: Text(
                            'Error: $_error',
                            style: const TextStyle(color: colour_disable_red),
                          ),
                        )
                      : _filtered.isEmpty
                      ? const Center(
                          child: Text(
                            'No history found for approved, disapproved, returned, or cancelled requests.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.black54),
                          ),
                        )
                      : ListView.separated(
                          itemCount: _filtered.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 16),
                          itemBuilder: (_, i) =>
                              LenderHistoryCard(item: _filtered[i]),
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

// --- Lender History Card Widget ---
class LenderHistoryCard extends StatelessWidget {
  final Map<String, dynamic> item;
  const LenderHistoryCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final status = (item['status'] ?? '').toString().toLowerCase();
    Color statusColor;
    String statusLabel;

    switch (status) {
      case 'approve':
        statusColor = colour_available_green;
        statusLabel = 'Approved';
        break;
      case 'disapprove':
        statusColor = colour_disable_red;
        statusLabel = 'Disapproved';
        break;
      case 'returned':
        statusColor = colour_available_green;
        statusLabel = 'Returned';
        break;
      case 'cancelled':
        statusColor = Colors.grey;
        statusLabel = 'Cancelled';
        break;
      case 'pending':
        statusColor = colour_main_orange;
        statusLabel = 'Pending';
        break;
      case 'returning':
        statusColor = colour_main_orange;
        statusLabel = 'Returning';
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
          _row('Borrowed by:', item['borrowedBy'] ?? '-'),

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
