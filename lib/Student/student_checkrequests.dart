import 'package:boardgame_app/Student/student_main.dart';
import 'package:flutter/material.dart';

class StudentCheckrequests extends StatefulWidget {
  const StudentCheckrequests({super.key});

  @override
  State<StudentCheckrequests> createState() => _StudentCheckrequestsState();
}

class _StudentCheckrequestsState extends State<StudentCheckrequests> {
  bool hasRequest = true;
  bool isReturning = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Borrow status",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w600,
                    color: colour_main,
                  ),
                ),
                const Divider(color: colour_main),
                const SizedBox(height: 10),
                buildBorrowCard(),
                const SizedBox(height: 30),
                const Text(
                  "Request status",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w600,
                    color: colour_main,
                  ),
                ),
                const Divider(color: colour_main),
                const SizedBox(height: 10),
                hasRequest ? buildRequestCard() : buildNoRequestText(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildBorrowCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ Container with background color + rounded border + image
            Container(
              width: 125,
              height: 125,
              decoration: BoxDecoration(
                color: colour_available.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colour_available, width: 2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  "image/Castle_Panic.webp",
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 16),

            // ✅ Info Section
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Castle Panic",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  const Text("From: 27/10/2025\nTo: 28/10/2025"),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isReturning ? "Returning in process" : "In use",
                        style: TextStyle(
                          color: isReturning ? Colors.grey : colour_available,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      if (!isReturning)
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: colour_main,
                            side: const BorderSide(color: colour_main),
                          ),
                          onPressed: () {
                            setState(() => isReturning = true);
                            showReturningDialog();
                          },
                          child: const Text("Return"),
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

  Widget buildRequestCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 125,
              height: 125,
              decoration: BoxDecoration(
                color: colour_borrow.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colour_borrow, width: 2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  "image/Champions_of_Hara.webp",
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Champions of Hara",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  const Text("From: 29/10/2025\nTo: 30/10/2025"),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Pending",
                        style: TextStyle(
                          color: colour_borrow,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: colour_main,
                          side: const BorderSide(color: colour_main),
                        ),
                        onPressed: showCancelDialog,
                        child: const Text("Cancel"),
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

  Widget buildNoRequestText() {
    return const Center(
      child: Text("You have no request", style: TextStyle(color: Colors.grey)),
    );
  }

  void showReturningDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.loop, size: 60, color: Colors.green),
            SizedBox(height: 16),
            Text(
              "Returning",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
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
            const Text(
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
                    setState(() => hasRequest = false);
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
