import 'package:boardgame_app/Student/student_main.dart';
import 'package:flutter/material.dart';
final url = '10.0.0.2:3000';
// 🌟 FIXED: New Color Definitions
const Color colour_main = Color(0xFFFF8000); // Main Orange
const Color colour_available = Color(0xFF729382); // Available Green
const Color colour_borrow = Color(0xFFEFA34B); // Borrow/Pending Orange
const Color colour_disable = Color(0xFFFF7C7C); // Disable/Cancel Red

class StudentCheckrequests extends StatefulWidget {
  const StudentCheckrequests({super.key});

  @override
  State<StudentCheckrequests> createState() => _StudentCheckrequestsState();
}

class _StudentCheckrequestsState extends State<StudentCheckrequests> {
  // 🌟 FIXED: Set default state back to 'In use'
  bool itemInUse = true; // Game currently checked out (In use / Returning)
  bool itemPending = false; // No request pending
  bool isReturning = false; // Not yet in the return process

  @override
  Widget build(BuildContext context) {
    // Determine if any item needs to be displayed
    bool hasActiveItem = itemInUse || itemPending;

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Combined Borrow Status and Request Status into one section
                const Text(
                  "Current Status",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w600,
                    color: colour_main,
                  ),
                ),
                const Divider(color: colour_main),
                const SizedBox(height: 10),

                // Display the active status card or the "No item" message
                hasActiveItem ? buildStatusCard() : buildNoActiveItemText(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Created a single function to build the status card
  Widget buildStatusCard() {
    // Determine displayed content based on status flags
    final String cardTitle = itemInUse ? "Castle Panic" : "Champions of Hara";
    final String imagePath = itemInUse
        ? "image/Castle_Panic.webp"
        : "image/Champions_of_Hara.webp";
    // Colors updated to use the new definitions
    // final Color borderColor = itemInUse ? colour_available : colour_borrow;

    final String currentStatusText;
    final Color statusTextColor;

    if (itemInUse) {
      currentStatusText = isReturning ? "Returning in process" : "In use";
      statusTextColor = isReturning ? Colors.grey : colour_available;
    } else {
      currentStatusText = "Pending";
      statusTextColor = colour_borrow;
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            Container(
              width: 125,
              height: 125,

              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(imagePath, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(width: 16),

            // Info and Button Section
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cardTitle,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text("From: 27/10/2025\nTo: 28/10/2025"),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        currentStatusText,
                        style: TextStyle(
                          color: statusTextColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),

                      // Conditional button display
                      itemInUse && !isReturning
                          ? OutlinedButton(
                              // Button for "In use" -> Return
                              style: OutlinedButton.styleFrom(
                                foregroundColor: colour_main,
                                side: const BorderSide(color: colour_main),
                              ),
                              onPressed: showReturningDialog,
                              child: const Text("Return"),
                            )
                          : itemPending
                          ? OutlinedButton(
                              // Button for "Pending" -> Cancel
                              style: OutlinedButton.styleFrom(
                                foregroundColor: colour_disable,
                                side: const BorderSide(color: colour_disable),
                              ),
                              onPressed: showCancelDialog,
                              child: const Text("Cancel"),
                            )
                          : const SizedBox.shrink(), // No button needed
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

  // Combined No Request/No Borrowing Text
  Widget buildNoActiveItemText() {
    return const Center(
      child: Text(
        "You have no active item or pending request.",
        style: TextStyle(color: Colors.grey),
      ),
    );
  }

  void showReturningDialog() {
    setState(() => isReturning = true); // Set status to "Returning in process"
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.loop, size: 60, color: colour_available),
            const SizedBox(height: 16),
            const Text(
              "Returning",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Please contact staff to approve",
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    });
  }

  void showCancelDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cancel_outlined, size: 60, color: colour_disable),
            const SizedBox(height: 16),
            Text(
              "Cancel",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: colour_disable,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Are you sure you want to cancel your request?",
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                OutlinedButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text("No", style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colour_disable,
                  ),
                  onPressed: () {
                    // Set status to clear the pending item
                    setState(() => itemPending = false);
                    Navigator.pop(dialogContext);
                  },
                  child: const Text(
                    "Yes",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
