import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '/login/login.dart';
import 'lender_browse_list.dart';
import 'HistoryLenderPage.dart' hide colour_main, colour_disable, colour_borrow;
import '/Lender/lender_main.dart' as lenderMain; // ใช้ prefix

class SeeLenderRequests extends StatefulWidget {
  final int lenderId;

  const SeeLenderRequests({super.key, required this.lenderId});

  @override
  State<SeeLenderRequests> createState() => _SeeLenderRequestsState();
}

class _SeeLenderRequestsState extends State<SeeLenderRequests> {
  final String url = '10.0.2.2:3000';
  final int borrowedCount = 12;
  final int availableCount = 38;
  final int disabledCount = 3;

  List<Map<String, String>> pendingRequests = [];

  @override
  void initState() {
    super.initState();
    fetchPendingRequests();
  }

  // --- Fetch Pending Requests ---
 Future<void> fetchPendingRequests() async {
  try {
    print('Fetching pending requests... URL: http://$url/lender/pending'); // Log URL เพื่อเช็คว่าถูกไหม

    final response = await http.get(Uri.parse('http://$url/lender/pending'));

    print('Response status: ${response.statusCode}'); // Log status
    print('Response body: ${response.body}'); // Log raw JSON เพื่อเช็คข้อมูลจริงๆ

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('Decoded data length: ${data.length}'); // เช็คว่ามีข้อมูลกี่ตัว

      setState(() {
        pendingRequests = List<Map<String, String>>.from(
          data.map((item) {
            print('Processing item: $item'); // Log แต่ละ item

            // Handle date parsing อย่างปลอดภัย
            String month = '';
            if (item['from_date'] != null && item['from_date'].toString().isNotEmpty) {
              try {
                final parsedDate = DateTime.parse(item['from_date'].toString());
                month = parsedDate.month.toString();
              } catch (e) {
                print('Date parse error for ${item['from_date']}: $e');
                month = ''; // ถ้า parse ไม่ได้ ให้เป็น empty
              }
            }

            return {
              'id': item['id']?.toString() ?? '',
              'title': item['game_name']?.toString() ?? '',
              'user': item['borrower_name']?.toString() ?? '',
              'Fdate': item['from_date']?.toString() ?? '',
              'Tdate': item['return_date']?.toString() ?? '',
              'image': '',
              'month': month,
            };
          }),
        );
      });
      print('Set pendingRequests with ${pendingRequests.length} items'); // Log หลัง setState
    } else {
      print('HTTP Error: ${response.statusCode} - ${response.body}');
      // Optional: แสดง snackbar หรือ dialog ให้ user รู้
      // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to fetch: ${response.statusCode}')));
    }
  } catch (e) {
    print('Fetch error: $e'); // Catch ทุก exception เช่น network, JSON decode
    // Optional: Handle UI error
  }
}

  // --- Approve Request ---
  Future<void> approveRequest(String borrowId) async {
    try {
      final response = await http.post(
        Uri.parse('http://$url/lender/approve/$borrowId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'lenderId': widget.lenderId}),
      );
      if (response.statusCode == 200) {
        _showConfirmationDialog(
          context: context,
          title: 'Approved',
          icon: Icons.assignment_turned_in_outlined,
          color: lenderMain.colour_available,
        );
        setState(() {
          pendingRequests.removeWhere((item) => item['id'] == borrowId);
        });
      } else {
        print("Approve Error: ${response.body}");
      }
    } catch (e) {
      print("Approve Exception: $e");
    }
  }

  // --- Disapprove Request ---
  Future<void> disapproveRequest(String borrowId, String reason) async {
    try {
      final response = await http.post(
        Uri.parse('http://$url/lender/disapprove/$borrowId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'reason': reason,
          'lenderId': widget.lenderId,
        }),
      );
      if (response.statusCode == 200) {
        _showConfirmationDialog(
          context: context,
          title: 'Disapproved',
          icon: Icons.block,
          color: lenderMain.colour_disable,
        );
        setState(() {
          pendingRequests.removeWhere((item) => item['id'] == borrowId);
        });
      } else {
        print("Disapprove Error: ${response.body}");
      }
    } catch (e) {
      print("Disapprove Exception: $e");
    }
  }

  // --- Dialogs ---
  void _showConfirmationDialog({
    required BuildContext context,
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

  void _showDisapprovalDialog(int index) {
    final _formKey = GlobalKey<FormState>();
    final _reasonController = TextEditingController();
    final borrowId = pendingRequests[index]['id']!;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Reason for Disapproval',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: lenderMain.colour_disable,
                    ),
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
                        borderSide: BorderSide(color: lenderMain.colour_disable),
                      ),
                    ),
                    validator: (value) => (value == null || value.isEmpty)
                        ? 'Please enter a reason'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: lenderMain.colour_disable,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        Navigator.pop(context);
                        disapproveRequest(borrowId, _reasonController.text);
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

  // --- Build Widgets ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 40, 16, 16),
        children: [
          Text(
            "Today's Status",
            style: TextStyle(
              color: lenderMain.colour_main,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildStatusCardItem(
                  count: borrowedCount, label: 'Borrowed', color: lenderMain.colour_borrow),
              const SizedBox(width: 12),
              _buildStatusCardItem(
                  count: availableCount, label: 'Available', color: lenderMain.colour_available),
              const SizedBox(width: 12),
              _buildStatusCardItem(
                  count: disabledCount, label: 'Disabled', color: lenderMain.colour_disable),
            ],
          ),
          const SizedBox(height: 30),
          Text(
            'Pending Requests (${pendingRequests.length})',
            style: TextStyle(
              color: lenderMain.colour_main,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: pendingRequests.length,
            itemBuilder: (context, index) {
              final request = pendingRequests[index];
              return _buildRequestCard(
                index: index,
                title: request['title']!,
                imagePath: request['image']!,
                user: request['user']!,
                fDate: request['Fdate']!,
                tDate: request['Tdate']!,
                month: request['month']!,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCardItem({
    required int count,
    required String label,
    required Color color,
  }) =>
      Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                count.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );

  Widget _buildRequestCard({
    required int index,
    required String title,
    required String imagePath,
    required String user,
    required String fDate,
    required String tDate,
    required String month,
  }) =>
      Card(
        elevation: 2,
        margin: const EdgeInsets.only(bottom: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  imagePath,
                  width: 125,
                  height: 125,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 60,
                    height: 80,
                    color: Colors.grey[200],
                    child: const Icon(Icons.broken_image, color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'From : $user',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    Text(
                      'Duration : $fDate - $tDate $month',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => _showDisapprovalDialog(index),
                          style: TextButton.styleFrom(
                            backgroundColor: lenderMain.colour_disable,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            'Disapprove',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                        const SizedBox(width: 8),
                        TextButton(
                          onPressed: () =>
                              approveRequest(pendingRequests[index]['id']!),
                          style: TextButton.styleFrom(
                            backgroundColor: lenderMain.colour_available,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            'Approve',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
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
