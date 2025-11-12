import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import '/login/login.dart';
import 'lender_browse_list.dart';
import 'HistoryLenderPage.dart';

// Constants
const colour_main = Color(0xFFFF8000);
const colour_available = Color(0xFF729382);
const colour_disable = Color(0xFFFF7C7C);
const colour_borrow = Color(0xFFEFA34B);

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
  final String url = '10.0.2.2:3000';

  int borrowedCount = 0;
  int availableCount = 0;
  int disabledCount = 0;
  bool _isLoadingStatus = true;
  List<Map<String, String>> pendingRequests = [];

  @override
  void initState() {
    super.initState();
    fetchStatusSummary();
    fetchPendingRequests();
  }

  // --- Format date to DD/MM ---
  String formatDateRange(String fDateStr, String tDateStr) {
    try {
      final fromDate = DateTime.parse(fDateStr);
      final toDate = DateTime.parse(tDateStr);

      // รูปแบบ: DD - DD/MMM
      final fromDay = DateFormat('dd').format(fromDate);
      final toDay = DateFormat('dd').format(toDate);
      final monthAbbr = DateFormat(
        'MMM',
      ).format(toDate); // ใช้เดือนจากวันสุดท้าย

      return '$fromDay - $toDay $monthAbbr';
    } catch (e) {
      print('Date range parse error: $e');
      return '$fDateStr - $tDateStr';
    }
  }

  // Fetch Status Summary API (/api/status-summary)
  Future<void> fetchStatusSummary() async {
    setState(() {
      _isLoadingStatus = true;
    });
    try {
      final response = await http.get(
        Uri.parse('http://$url/api/status-summary'),
        headers: {
          'Authorization': 'Bearer ${widget.authToken}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          setState(() {
            borrowedCount =
                int.tryParse(data['data']['borrowed'].toString()) ?? 0;
            availableCount =
                int.tryParse(data['data']['available'].toString()) ?? 0;
            disabledCount =
                int.tryParse(data['data']['disabled'].toString()) ?? 0;
          });
        }
      } else {
        print(
          'HTTP Status Error fetching status: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('Fetch Status Summary Error: $e');
    } finally {
      setState(() {
        _isLoadingStatus = false;
      });
    }
  }

  // Fetch Pending Requests
  Future<void> fetchPendingRequests() async {
    try {
      final response = await http.get(
        Uri.parse('http://$url/lender/pending'),
        headers: {'Authorization': 'Bearer ${widget.authToken}'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          if (data is List) {
            pendingRequests = List<Map<String, String>>.from(
              data.map((item) {
                String month = '';
                if (item['from_date'] != null &&
                    item['from_date'].toString().isNotEmpty) {
                  try {
                    final parsedDate = DateTime.parse(item['from_date']);
                    month = parsedDate.month.toString();
                  } catch (e) {
                    print('Date parse error for ${item['from_date']}: $e');
                  }
                }
                return {
                  'id': item['id']?.toString() ?? '',
                  'title': item['game_name']?.toString() ?? '',
                  'user': item['borrower_name']?.toString() ?? '',
                  'Fdate': item['from_date']?.toString() ?? '',
                  'Tdate': item['return_date']?.toString() ?? '',
                  'image':
                      item['game_pic_path'] != null &&
                          item['game_pic_path'].toString().isNotEmpty
                      ? 'http://$url/${item['game_pic_path']}'
                      : '',
                  'month': month,
                };
              }),
            );
          } else {
            print('Error: API response is not a List.');
          }
        });
      } else {
        print('HTTP Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Fetch error: $e');
    }
  }

  Future<void> approveRequest(String borrowId) async {
    try {
      final response = await http.post(
        Uri.parse('http://$url/api/borrow/approval/$borrowId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.authToken}',
        },
        body: jsonEncode({'status': 'approved', 'lender_id': widget.lenderId}),
      );

      if (response.statusCode == 200) {
        _showConfirmationDialog(
          context: context,
          title: 'Approved',
          icon: Icons.assignment_turned_in_outlined,
          color: colour_available,
        );
        setState(() {
          pendingRequests.removeWhere((item) => item['id'] == borrowId);
        });
        fetchStatusSummary();
        fetchPendingRequests();
      } else {
        final responseBody = jsonDecode(response.body);
        final errorMessage =
            responseBody['message'] ?? 'Failed to approve request.';
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: colour_disable,
            ),
          );
        }
      }
    } catch (e) {
      print("Approve Exception: $e");
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Connection Error: $e')));
      }
    }
  }

  Future<void> disapproveRequest(String borrowId, String reason) async {
    try {
      final response = await http.post(
        Uri.parse('http://$url/api/borrow/approval/$borrowId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.authToken}',
        },
        body: jsonEncode({
          'status': 'disapproved',
          'lender_id': widget.lenderId,
          'reason': reason,
        }),
      );

      if (response.statusCode == 200) {
        _showConfirmationDialog(
          context: context,
          title: 'Disapproved',
          icon: Icons.block,
          color: colour_disable,
        );
        setState(() {
          pendingRequests.removeWhere((item) => item['id'] == borrowId);
        });
        fetchStatusSummary();
        fetchPendingRequests();
      } else {
        final responseBody = jsonDecode(response.body);
        final errorMessage =
            responseBody['message'] ?? 'Failed to disapprove request.';
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: colour_disable,
            ),
          );
        }
      }
    } catch (e) {
      print("Disapprove Exception: $e");
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Connection Error: $e')));
      }
    }
  }

  void _showConfirmationDialog({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color color,
  }) {
    Future.delayed(const Duration(seconds: 2), () {
      if (Navigator.of(context).canPop()) Navigator.of(context).pop();
    });

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
                      color: colour_disable,
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
                        borderSide: BorderSide(color: colour_disable),
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

  Widget _buildStatusCardItem({
    required int count,
    required String label,
    required Color color,
  }) => Expanded(
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
  }) => Card(
    elevation: 2,
    margin: const EdgeInsets.only(bottom: 12),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: imagePath.isNotEmpty && imagePath.startsWith('http')
                ? Image.network(
                    imagePath,
                    width: 125,
                    height: 125,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        width: 125,
                        height: 125,
                        color: Colors.grey[200],
                        child: const Center(child: CircularProgressIndicator()),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      print('Image load error for $imagePath: $error');
                      return Container(
                        width: 125,
                        height: 125,
                        color: Colors.grey[200],
                        child: const Icon(
                          Icons.broken_image,
                          color: Colors.grey,
                          size: 50,
                        ),
                      );
                    },
                  )
                : Container(
                    width: 125,
                    height: 125,
                    color: Colors.grey[200],
                    child: const Icon(
                      Icons.image_not_supported,
                      color: Colors.grey,
                      size: 50,
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
                SizedBox(height: 10),
                Text(
                  'Duration : ${formatDateRange(fDate, tDate)}',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),

                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => _showDisapprovalDialog(index),
                      style: TextButton.styleFrom(
                        backgroundColor: colour_disable,
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
                    const SizedBox(width: 10),
                    TextButton(
                      onPressed: () =>
                          approveRequest(pendingRequests[index]['id']!),
                      style: TextButton.styleFrom(
                        backgroundColor: colour_available,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        
        onRefresh: () async {
          await fetchStatusSummary();
          await fetchPendingRequests();
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 60, 16, 16),
          children: [
            Text(
              "Today's Status",
              style: TextStyle(
                color: colour_main,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _isLoadingStatus
                ? const Center(child: CircularProgressIndicator())
                : Row(
                    children: [
                      _buildStatusCardItem(
                        count: borrowedCount,
                        label: 'Borrowed',
                        color: colour_borrow,
                      ),
                      const SizedBox(width: 12),
                      _buildStatusCardItem(
                        count: availableCount,
                        label: 'Available',
                        color: colour_available,
                      ),
                      const SizedBox(width: 12),
                      _buildStatusCardItem(
                        count: disabledCount,
                        label: 'Disabled',
                        color: colour_disable,
                      ),
                    ],
                  ),
            const SizedBox(height: 20),
            
            
            Text(
              'Pending Requests (${pendingRequests.length})',
              style: TextStyle(
                color: colour_main,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15), 

            pendingRequests.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: Text(
                        'No pending requests found.',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.zero, // ลบ padding ด้านบน
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
      ),
    );
  }
}
