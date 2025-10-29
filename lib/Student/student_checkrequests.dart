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
      child: Container(
        color: const Color.fromARGB(255, 255, 255, 255),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                const Text(
                  "Borrow status",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
                Divider(color: const Color.fromARGB(255, 255, 115, 0)),
                const SizedBox(height: 10),
                buildBorrowCard(),
                const SizedBox(height: 30),
                const Text(
                  "Request status",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
                Divider(color: const Color.fromARGB(255, 255, 115, 0)),
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Image.asset(
              "image/Castle_Panic.webp",
              width: 70,
              height: 90,
              fit: BoxFit.cover,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Exploding kittens",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  const Text("From: 27/10/2025\nTo: 28/10/2025"),
                  const SizedBox(height: 6),
                  Text(
                    isReturning ? "Returning in process" : "In use",
                    style: TextStyle(
                      color: isReturning ? Colors.grey : Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (!isReturning)
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.orange,
                        side: const BorderSide(color: Colors.orange),
                      ),
                      onPressed: () {
                        setState(() => isReturning = true);
                        showReturningDialog();
                      },
                      child: const Text("Return Assets"),
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Image.asset(
              "image/Champions_of_Hara.webp",
              width: 70,
              height: 90,
              fit: BoxFit.cover,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Exploding kittens",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  const Text("From: 29/10/2025\nTo: 30/10/2025"),
                  const SizedBox(height: 6),
                  const Text(
                    "Pending",
                    style: TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.orange,
                      side: const BorderSide(color: Colors.orange),
                    ),
                    onPressed: showCancelDialog,
                    child: const Text("Cancel request"),
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
      if (mounted) {
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
            const Icon(
              Icons.cancel_outlined,
              size: 60,
              color: Colors.redAccent,
            ),
            const SizedBox(height: 16),
            const Text(
              "Cancel",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.red,
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
                  child: const Text("No"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: () {
                    setState(() => hasRequest = false);
                    Navigator.pop(dialogContext);
                  },
                  child: const Text("Yes"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
