import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'staff_main.dart' show colour_main, colour_available;

// ----------------------------
// CORRECT BASE URL
// ----------------------------
// NOTE: Both iOS and Android MUST use the network IP
// to connect to your computer's server.
// '127.0.0.1' only works for the iOS Simulator.
const String _networkIP = '127.0.0.1';  //IP

const String _iosBaseUrl = _networkIP;
const String _androidBaseUrl = _networkIP;

final String baseUrl = Platform.isIOS ? _iosBaseUrl : _androidBaseUrl;
const int serverPort = 3000;

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
    fetchReturningList();
  }

  // ----------------------------
  // GET returning list
  // ----------------------------
  Future<void> fetchReturningList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("auth_token");

    if (token == null) {
      setState(() => isLoading = false);
      // Handle missing token, e.g., navigate to login
      return;
    }
    
    final url = Uri.http("$baseUrl:$serverPort", "/api/staff/returning-list");

    try {
      final response = await http.get(
        url,
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        setState(() {
          returningList = jsonDecode(response.body)["data"];
          isLoading = false;
        });
      } else {
        // Handle error (e.g., show a snackbar)
        setState(() => isLoading = false);
      }
    } catch (e) {
      // Handle network error
      setState(() => isLoading = false);
      print("Network Error: $e");
    }
  }

  // ----------------------------
  // PUT confirm return
  // ----------------------------
  Future<void> confirmReturn(int borrowId, String gameName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("auth_token");

    if (token == null) return; // Should not happen if page loaded

    final url = Uri.http(
      "$baseUrl:$serverPort",
      "/api/staff/confirm-return/$borrowId",
    );

    try {
      final response = await http.put(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        showReturnPopup(gameName);
        setState(() {
          returningList.removeWhere((item) => item['borrow_id'] == borrowId);
        });
      } else {
        // Handle error (e.g., show snackbar)
      }
    } catch (e) {
      // Handle network error
      print("Network Error: $e");
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
          // Use Material widget for default text styles
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
                child: isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: colour_main))
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
            ],
          ),
        ),
      ),
    );
  }

  // ----------------------------
  // Card UI
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
              child: Image.network(
                "http://$baseUrl:$serverPort/${item['game_pic_path']}",
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