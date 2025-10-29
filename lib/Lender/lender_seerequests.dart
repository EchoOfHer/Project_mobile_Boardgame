// lender_seerequests.dart

import 'package:flutter/material.dart';

// ⭐️ 1. คลาสยังคงเป็น StatefulWidget เหมือนเดิม
class LenderSeerequests extends StatefulWidget {
  const LenderSeerequests({super.key});

  @override
  State<LenderSeerequests> createState() => _LenderSeerequestsState();
}

class _LenderSeerequestsState extends State<LenderSeerequests> {
  // --- ข้อมูลจำลองสำหรับแสดงผล ---
  final int borrowedCount = 12;
  final int availableCount = 38;
  final int disabledCount = 3;

  // ข้อมูลจำลองสำหรับ Pending Requests
  final List<Map<String, String>> pendingRequests = [
    {
      'title': 'Exploding kittens',
      'image': 'image/Exploding_Kitten.webp',
      'user': 'Anonymous',
    },
    {
      'title': 'Catan',
      'image': 'image/Catan.jpg',
      'user': 'Anonymous',
    },
  ];
  // --- จบส่วนข้อมูลจำลอง ---

  // --- ฟังก์ชันสำหรับแสดง Pop-up (Approve/Disapprove) ---
  void _showConfirmationDialog({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color color,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: color,
                  size: 100,
                ),
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
        );
      },
    );
  }

  // --- ฟังก์ชันสำหรับ Dialog "เหตุผล" ---
  void _showDisapprovalDialog({
    required BuildContext context,
    required int index,
  }) {
    final _formKey = GlobalKey<FormState>();
    final _reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
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
                          color: Colors.red.shade400,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _reasonController,
                        decoration: InputDecoration(
                          hintText: 'Enter reason...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.red.shade400),
                          ),
                        ),
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a reason';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade400,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            Navigator.of(context).pop();
                            
                            _showConfirmationDialog(
                              context: context,
                              title: 'Disapproved',
                              icon: Icons.block,
                              color: Colors.red.shade400,
                            );
                            
                            setState(() {
                              pendingRequests.removeAt(index);
                            });
                          }
                        },
                        child: const Text('Submit'),
                      )
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ⭐️ 2. ลบฟังก์ชัน _onNavItemTapped และ _buildBottomNav ออก

  @override
  Widget build(BuildContext context) {
    // ⭐️ 3. ลบ Scaffold และ BottomNavigationBar ออก
    // ⭐️ 4. คืนค่าเป็น SafeArea ตามที่โจทย์ต้องการ
    return SafeArea(
      child: Container(
        // ⭐️ 5. ใส่สีพื้นหลัง (จาก Scaffold เดิม)
        color: Colors.white,
        // ⭐️ 6. นำ ListView (จาก body เดิม) มาใส่
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16.0, 40.0, 16.0, 16.0),
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            _buildStatusCards(),
            const SizedBox(height: 30),
            _buildPendingTitle(),
            const SizedBox(height: 20),
            _buildRequestsList(),
          ],
        ),
      ),
    );
  }

  // --- (Widget helpers ที่เหลือย้ายมาทั้งหมด) ---

  Widget _buildHeader() {
    return const Text(
      'Today\'s Status',
      style: TextStyle(
        color: Colors.deepOrange,
        fontSize: 28,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildStatusCards() {
    return Row(
      children: [
        _buildStatusCardItem(
          count: borrowedCount,
          label: 'Borrowed',
          color: Colors.orange.shade400,
        ),
        const SizedBox(width: 12),
        _buildStatusCardItem(
          count: availableCount,
          label: 'Available',
          color: Colors.blueGrey.shade400,
        ),
        const SizedBox(width: 12),
        _buildStatusCardItem(
          count: disabledCount,
          label: 'Disabled',
          color: Colors.red.shade400,
        ),
      ],
    );
  }

  Widget _buildStatusCardItem({
    required int count,
    required String label,
    required Color color,
  }) {
    return Expanded(
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
            )
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
  }

  Widget _buildPendingTitle() {
    return Text(
      'Pending Requests (${pendingRequests.length})',
      style: TextStyle(
        color: Colors.deepOrange.shade400,
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildRequestsList() {
    return ListView.builder(
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
        );
      },
    );
  }

  Widget _buildRequestCard({
    required int index,
    required String title,
    required String imagePath,
    required String user,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                imagePath,
                width: 60,
                height: 80,
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
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          _showDisapprovalDialog(context: context, index: index);
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.red.shade300,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child:
                            const Text('Disapprove', style: TextStyle(fontSize: 12)),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: () {
                          _showConfirmationDialog(
                            context: context,
                            title: 'Approved',
                            icon: Icons.assignment_turned_in_outlined,
                            color: Colors.blueGrey.shade400,
                          );
                          setState(() {
                            pendingRequests.removeAt(index);
                          });
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.blueGrey.shade300,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 4),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text('Approve', style: TextStyle(fontSize: 12)),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}