import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'staff_main.dart' show colour_main, colour_available;
import '/login/login.dart'; // ✅ Import เพื่อใช้ baseUrl

class StaffReturnAsset extends StatefulWidget {
  final String authToken; // ★ 1. เพิ่มตัวแปรรับ Token

  // ★ 2. รับค่าผ่าน Constructor
  const StaffReturnAsset({super.key, required this.authToken});

  @override
  State<StaffReturnAsset> createState() => _StaffReturnAssetState();
}

class _StaffReturnAssetState extends State<StaffReturnAsset> {
  List<dynamic> returningList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => fetchReturningList());
  }

  Future<void> _handleError(String message) async {
    if (mounted) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  // ----------------------------
  // GET returning list
  // ----------------------------
  Future<void> fetchReturningList() async {
    // ❌ ไม่ต้องโหลด Token เองแล้ว
    // ✅ ใช้ baseUrl จาก login.dart
    final urlString = "$baseUrl/api/staff/returning-list";
    print("Fetching Returning List from: $urlString");

    try {
      final response = await http.get(
        Uri.parse(urlString),
        // ✅ ใช้ widget.authToken
        headers: {"Authorization": "Bearer ${widget.authToken}"},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            returningList = data["data"] ?? [];
            isLoading = false;
          });
        }
      } else {
        print("API Error: ${response.statusCode} - ${response.body}");
        _handleError(
          "Failed to load list. Server responded with ${response.statusCode}",
        );
      }
    } catch (e) {
      print("Network Error Catch: $e");
      _handleError("Network connection failed. Check API URL.");
    }
  }

  // ----------------------------
  // PUT confirm return
  // ----------------------------
  Future<void> confirmReturn(int borrowId, String gameName) async {
    // ✅ ใช้ baseUrl จาก login.dart
    final urlString = "$baseUrl/api/staff/confirm-return/$borrowId";

    try {
      final response = await http.put(
        Uri.parse(urlString),
        headers: {
          // ✅ ใช้ widget.authToken
          "Authorization": "Bearer ${widget.authToken}",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        showReturnPopup(gameName);
        if (mounted) {
          setState(() {
            returningList.removeWhere((item) => item['borrow_id'] == borrowId);
          });
        }
      } else {
        _handleError(
          "Confirmation failed: Server status ${response.statusCode}",
        );
      }
    } catch (e) {
      print("Network Error (Confirm): $e");
      _handleError("Network error during confirmation.");
    }
  }

  // ----------------------------
  // POPUP
  // ----------------------------
  void showReturnPopup(String name) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(
        child: Container(
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Material(
            color: Colors.transparent,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.loop, size: 60, color: colour_available),
                const SizedBox(height: 10),
                Text(
                  name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  "Returned",
                  style: TextStyle(color: Colors.green, fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pop(context);
      }
    });
  }

  // ----------------------------
  // UI
  // ----------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Return Asset",
                style: TextStyle(
                  color: colour_main,
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "Assets waiting to return (${returningList.length})",
                style: const TextStyle(color: Colors.grey, fontSize: 16),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: fetchReturningList,
                  child: isLoading
                      ? const Center(
                          child: CircularProgressIndicator(color: colour_main),
                        )
                      : returningList.isEmpty
                      ? const Center(
                          child: Text(
                            "No items awaiting return.",
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                        )
                      : ListView.builder(
                          itemCount: returningList.length,
                          itemBuilder: (context, i) =>
                              buildGameCard(returningList[i]),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildGameCard(dynamic item) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                // ✅ ใช้ baseUrl
                "$baseUrl/${item['game_pic_path']}",
                width: 100,
                height: 100,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 100,
                    height: 100,
                    color: Colors.grey[200],
                    child: const Icon(Icons.broken_image, color: Colors.grey),
                  );
                },
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['game_name'],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text("By: ${item['borrower_name']}"),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colour_available,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () =>
                            confirmReturn(item['borrow_id'], item['game_name']),
                        child: const Text("Returned"),
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
}
