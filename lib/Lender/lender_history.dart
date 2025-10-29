// lender_history.dart

import 'dart:async';
import 'package:flutter/material.dart';

class LenderHistory extends StatefulWidget {
  const LenderHistory({super.key});

  @override
  State<LenderHistory> createState() => _LenderHistoryState();
}

class _LenderHistoryState extends State<LenderHistory> {
  final TextEditingController _search = TextEditingController();
  Timer? _debounce;

  // ----- mock data -----
  final List<Map<String, String>> _all = [
    {
      'game': 'Exploding Kitten',
      'id': '0001',
      'borrower': 'Student A', // (Lender จะเห็นว่าใครยืม)
      'approvedBy': 'You', // (Lender)
      'returnedTo': 'Steven',
      'borrowedDate': '15 Oct 2025',
      'returnedDate': '16 Oct 2025',
    },
    {
      'game': 'Catan',
      'id': '0003',
      'borrower': 'Student B',
      'approvedBy': 'You', // (Lender)
      'returnedTo': 'Steven',
      'borrowedDate': '15 Oct 2025',
      'returnedDate': '16 Oct 2025',
    },
  ];

  late List<Map<String, String>> _filtered;

  @override
  void initState() {
    super.initState();
    _filtered = List.from(_all);
    _search.addListener(_onSearchChange);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    super.dispose();
  }

  void _onSearchChange() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 200), () {
      final q = _search.text.trim().toLowerCase();
      setState(() {
        if (q.isEmpty) {
          _filtered = List.from(_all);
        } else {
          _filtered = _all.where((m) {
            return (m['game']!.toLowerCase().contains(q)) ||
                (m['id']!.toLowerCase().contains(q)) ||
                (m['borrower']!.toLowerCase().contains(q)) ||
                (m['returnedTo']!.toLowerCase().contains(q));
          }).toList();
        }
      });
    });
  }

  void _clearSearch() {
    _search.clear();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    // ⭐️ คืนค่าเป็น SafeArea ตามที่โจทย์ต้องการ
    return SafeArea(
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

              // Search Bar
              TextField(
                controller: _search,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'Search by game, borrower . . .',
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
              // List section
              Expanded(
                child: _filtered.isEmpty
                    ? const Center(
                        child: Text(
                          'No results found',
                          style: TextStyle(color: Colors.black54),
                        ),
                      )
                    : ListView.separated(
                        itemCount: _filtered.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 16),
                        itemBuilder: (_, i) => HistoryCard(item: _filtered[i]),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// (Helper class สำหรับการ์ด)
class HistoryCard extends StatelessWidget {
  final Map<String, String> item;
  const HistoryCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
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
            item['game']!,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            'ID : ${item['id']}',
            style: const TextStyle(fontSize: 13, color: Colors.black54),
          ),
          const SizedBox(height: 12),
          _row('Borrowed by :', item['borrower']!),
          _row('Approved by :', item['approvedBy']!),
          _row('Returned to :', item['returnedTo']!),
          const Divider(height: 20, thickness: 0.5),
          _row('Borrowed date :', item['borrowedDate']!),
          _row('Returned date :', item['returnedDate']!),
        ],
      ),
    );
  }

  static Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
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