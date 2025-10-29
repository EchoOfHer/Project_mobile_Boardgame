import 'dart:async';
import 'package:flutter/material.dart';

class StudentHistory extends StatefulWidget {
  const StudentHistory({super.key});

  @override
  State<StudentHistory> createState() => _StudentHistoryState();
}

class _StudentHistoryState extends State<StudentHistory> {
  final TextEditingController _search = TextEditingController();
  Timer? _debounce;

  // ----- mock data -----
  final List<Map<String, String>> _all = [
    {
      'game': 'Exploding Kitten',
      'id': '0001',
      'status': 'Approve',
      'approvedBy': 'Lender 1',
      'returnedTo': 'Steven',
      'borrowedDate': '15 Oct 2025',
      'returnedDate': '16 Oct 2025',
    },
    {
      'game': 'Catan',
      'id': '0003',
      'status': 'Disapprove',
      'reason': 'Board game is being repaired.',
      'approvedBy': 'Lender 3',
      'borrowedDate': '15 Oct 2025',
      'returnedDate': '16 Oct 2025',
    },
    {
      'game': 'One week werewolf',
      'id': '0005',
      'status': 'Approve',
      'approvedBy': 'Lender 4',
      'returnedTo': 'Steven',
      'borrowedDate': '12 Oct 2025',
      'returnedDate': '14 Oct 2025',
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
            return (m['game']?.toLowerCase().contains(q) ?? false) ||
                (m['id']?.toLowerCase().contains(q) ?? false) ||
                (m['approvedBy']?.toLowerCase().contains(q) ?? false) ||
                (m['returnedTo']?.toLowerCase().contains(q) ?? false) ||
                (m['status']?.toLowerCase().contains(q) ?? false);
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

              // Search bar
              TextField(
                controller: _search,
                textInputAction: TextInputAction.search,
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

              // History List
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

// -------- CARD --------
class HistoryCard extends StatelessWidget {
  final Map<String, String> item;
  const HistoryCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final status = item['status'] ?? '';
    final isApprove = status.toLowerCase() == 'approve';
    const approveText = Color(0xFF486E5A);
    const disapproveText = Color(0xFFDD4430);

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
          //  Title
          Text(
            item['game']!,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(
            'ID : ${item['id']}',
            style: const TextStyle(fontSize: 13, color: Colors.black54),
          ),
          const SizedBox(height: 12),

          //  Details
          _row('Approved by :', item['approvedBy'] ?? '-'),
          const SizedBox(height: 6),

          //  Status
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
                isApprove ? 'Approve' : 'Disapprove',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isApprove ? approveText : disapproveText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          //  Reason (เฉพาะ Disapprove)
          if (!isApprove && (item['reason']?.isNotEmpty ?? false)) ...[
            _row('Reason :', item['reason']!),
            const SizedBox(height: 6),
          ],

          //  Returned to (เฉพาะ Approve)
          if (isApprove) ...[
            _row('Returned to :', item['returnedTo'] ?? '-'),
            const SizedBox(height: 6),
          ],

          const Divider(height: 20, thickness: 0.5),

          //  Dates
          _row('Borrowed date :', item['borrowedDate'] ?? '-'),
          const SizedBox(height: 6),
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
