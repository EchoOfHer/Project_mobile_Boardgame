import 'dart:async';
import 'package:flutter/material.dart';
import 'lender_browse_list.dart';
import 'see_request.dart';
import '/login/login.dart';

class HistoryLenderPage extends StatefulWidget {
  const HistoryLenderPage({super.key});

  @override
  State<HistoryLenderPage> createState() => _HistoryLenderPageState();
}

class _HistoryLenderPageState extends State<HistoryLenderPage> {
  final TextEditingController _search = TextEditingController();
  Timer? _debounce;

  final List<Map<String, String>> _all = [
    {
      'game': 'Exploding Kitten',
      'id': '0001',
      'borrower': 'Jane',
      'status': 'Approve',
      'returnedTo': 'Steven',
      'borrowedDate': '15 Oct 2025',
      'returnedDate': '16 Oct 2025',
    },
    {
      'game': 'Catan',
      'id': '0003',
      'borrower': 'lukpeach',
      'status': 'Disapprove',
      'reason': 'Board game is being repaired.',
      'borrowedDate': '15 Oct 2025',
      'returnedDate': '16 Oct 2025',
    },
    {
      'game': 'One week werewolf',
      'id': '0005',
      'borrower': 'thomas',
      'status': 'Approve',
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
            final game = m['game']?.toLowerCase() ?? '';
            final id = m['id']?.toLowerCase() ?? '';
            final borrower = m['borrower']?.toLowerCase() ?? '';
            final status = m['status']?.toLowerCase() ?? '';
            final reason = m['reason']?.toLowerCase() ?? '';
            final returnedTo = m['returnedTo']?.toLowerCase() ?? '';
            return game.contains(q) ||
                id.contains(q) ||
                borrower.contains(q) ||
                status.contains(q) ||
                reason.contains(q) ||
                returnedTo.contains(q);
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
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: SafeArea(
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

              // Search
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

// ----------- CARD -------------
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
          // Game title
          Text(
            item['game'] ?? '-',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            'ID : ${item['id'] ?? '-'}',
            style: const TextStyle(fontSize: 13, color: Colors.black54),
          ),
          const SizedBox(height: 12),

          // Borrower
          _row('Borrowed by :', item['borrower'] ?? '-'),
          const SizedBox(height: 6),

          // Status (text only, no box)
          Row(
            children: [
              const SizedBox(
                width: 130,
                child: Text(
                  'Status :',
                  style: TextStyle(fontSize: 13, color: Colors.black54),
                ),
              ),
              Expanded(
                child: Text(
                  isApprove ? 'Approve' : 'Disapprove',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isApprove ? approveText : disapproveText,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Reason (เฉพาะ Disapprove)
          if (!isApprove && (item['reason']?.isNotEmpty ?? false)) ...[
            _row('Reason :', item['reason']!),
            const SizedBox(height: 6),
          ],

          // Returned to (เฉพาะ Approve เท่านั้น)
          if (isApprove) ...[
            _row('Returned to :', item['returnedTo'] ?? '-'),
            const SizedBox(height: 6),
          ],

          const Divider(height: 20, thickness: 0.5),

          // Dates
          _row('Borrowed date :', item['borrowedDate'] ?? '-'),
          const SizedBox(height: 6),

          // Returned date (เฉพาะ Approve)
          if (isApprove) _row('Returned date :', item['returnedDate'] ?? '-'),
        ],
      ),
    );
  }

  static Widget _row(String label, String value) {
    return Row(
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
