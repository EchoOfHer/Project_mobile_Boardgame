import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '/Lender/lender_main.dart' show colour_main, colour_available, colour_disable;

class SeeLenderRequests extends StatefulWidget {
  final int lenderId;
  final String authToken;

  const SeeLenderRequests({
    super.key,
    required this.lenderId,
    required this.authToken,
  });

  @override
  State<SeeLenderRequests> createState() => _SeeLenderRequestsState();
}

class _SeeLenderRequestsState extends State<SeeLenderRequests> {
  bool isLoading = true;
  List<dynamic> pendingRequests = [];
  final baseUrl = 'http://10.0.2.2:3000';

  // Header สำหรับ API ที่ต้องการ Token
  Map<String, String> get _authHeaders => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${widget.authToken}',
      };

  @override
  void initState() {
    super.initState();
    fetchPendingRequests();
  }

  // ==============================
  // ดึงข้อมูลคำขอจาก API
  // ==============================
  Future<void> fetchPendingRequests() async {
    setState(() => isLoading = true);
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/lender/requests'),
        headers: _authHeaders,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          pendingRequests = data['requests'] ?? [];
          isLoading = false;
        });
        debugPrint('✅ Loaded ${pendingRequests.length} pending requests.');
      } else {
        debugPrint('❌ Failed to load requests: ${response.statusCode}. Body: ${response.body}');
        setState(() => isLoading = false);
      }
    } catch (e) {
      debugPrint('⚠️ Error fetching requests: $e');
      setState(() => isLoading = false);
    }
  }

  // ==============================
  // ส่งผลการอนุมัติ / ปฏิเสธ
  // ==============================
  Future<void> updateApproval(int borrowId, String action, {String? reason}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/borrow/approval/$borrowId'),
        headers: _authHeaders,
        body: json.encode({
          'lender_id': widget.lenderId,
          'action': action,
          if (reason != null) 'reason': reason,
        }),
      );

      if (response.statusCode == 200) {
        _showConfirmationDialog(
          title: action == 'approve' ? 'Approved' : 'Disapproved',
          icon: action == 'approve'
              ? Icons.assignment_turned_in_outlined
              : Icons.block,
          color: action == 'approve' ? colour_available : colour_disable,
        );
        fetchPendingRequests();
      } else {
        debugPrint('❌ Failed approval: ${response.statusCode}. Body: ${response.body}');
      }
    } catch (e) {
      debugPrint('⚠️ Approval Error: $e');
    }
  }

  // ==============================
  // Dialog แสดงผลอนุมัติ/ปฏิเสธ
  // ==============================
  void _showConfirmationDialog({
    required String title,
    required IconData icon,
    required Color color,
  }) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 100),
              const SizedBox(height: 20),
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==============================
  // Dialog ปฏิเสธ + เหตุผล
  // ==============================
  void _showDisapprovalDialog({required int borrowId}) {
    final _formKey = GlobalKey<FormState>();
    final _reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setStateDialog) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Reason for Disapproval',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: colour_disable),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _reasonController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Enter reason...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: colour_disable),
                      ),
                    ),
                    validator: (value) => (value == null || value.isEmpty)
                        ? 'Please enter a reason'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colour_disable,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        Navigator.pop(context);
                        updateApproval(
                          borrowId,
                          'reject',
                          reason: _reasonController.text,
                        );
                      }
                    },
                    child: const Text('Submit'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ==============================
  // UI
  // ==============================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : pendingRequests.isEmpty
                ? Center(
                    child: Text(
                      "No pending requests",
                      style: TextStyle(color: Colors.grey[700], fontSize: 18),
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                    children: [
                      Text(
                        "Pending Approval Requests",
                        style: TextStyle(
                            color: colour_main,
                            fontSize: 28,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Requests (${pendingRequests.length})',
                        style: TextStyle(
                            color: colour_main,
                            fontSize: 22,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      ...pendingRequests.map((req) => _buildRequestCard(req)).toList(),
                    ],
                  ),
      ),
    );
  }

  Widget _buildRequestCard(dynamic request) {
    final borrowId = request['borrow_id'];
    final gameName = request['game_name'] ?? 'Unknown Game';
    final borrower = request['borrower_username'] ?? 'Anonymous';
    final fromDate = request['from_date']?.toString().split('T')[0] ?? '';
    final toDate = request['return_date']?.toString().split('T')[0] ?? '';

    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(gameName,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('From: $borrower', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
            Text('Duration: $fromDate → $toDate', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => _showDisapprovalDialog(borrowId: borrowId),
                  style: TextButton.styleFrom(
                      backgroundColor: colour_disable,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6)),
                  child: const Text('Disapprove', style: TextStyle(fontSize: 12)),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () => updateApproval(borrowId, 'approve'),
                  style: TextButton.styleFrom(
                      backgroundColor: colour_available,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6)),
                  child: const Text('Approve', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
