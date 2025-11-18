// lib/Staff/StaffReturnAsset.dart (FIXED for Network Connection)

import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'staff_main.dart' show colour_main, colour_available;

// ----------------------------
// ✅ FIXED BASE URL CONFIGURATION
// ----------------------------
// We define the FULL URL prefix to avoid issues with Uri.http/Uri.parse.
const String _hostIP = '10.0.2.2';
const int serverPort = 3000;

// FINAL BASE URL with protocol and port included
// e.g., 'http://10.0.2.2:3000'
final String apiBaseUrl = 'http://$_hostIP:$serverPort';

class StaffReturnAsset extends StatefulWidget {
  const StaffReturnAsset({super.key});

  @override
  State<StaffReturnAsset> createState() => _StaffReturnAssetState();
}

class _StaffReturnAssetState extends State<StaffReturnAsset> {
  List<dynamic> returningList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // Use Future.microtask to delay fetch and ensure context/mounted is ready
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
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("auth_token");

    if (token == null) {
      return _handleError("Authentication failed. Please log in.");
    }

    // ✅ Use Uri.parse with the full, final URL
    final urlString = "$apiBaseUrl/api/staff/returning-list";
    print("Fetching Returning List from: $urlString");

    try {
      final response = await http.get(
        Uri.parse(urlString),
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            // Ensure data is accessed safely
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
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("auth_token");

    if (token == null) return;

    final urlString = "$apiBaseUrl/api/staff/confirm-return/$borrowId";

    try {
      final response = await http.put(
        Uri.parse(urlString),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        showReturnPopup(gameName);
        if (mounted) {
          // Remove the item immediately for quick UI feedback
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
  // POPUP (Remains the same)
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
                Icon(Icons.loop, size: 60, color: colour_available),
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
  // UI (Remains the same, added RefreshIndicator)
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

  // ----------------------------
  // Card UI (Fixed Image URL construction)
  // ----------------------------
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
              // ✅ Fixed Image URL: uses the full apiBaseUrl
              child: Image.network(
                "$apiBaseUrl/${item['game_pic_path']}",
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
