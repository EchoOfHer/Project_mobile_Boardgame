import 'package:flutter/material.dart';

class PictureInputField extends StatelessWidget {
  final String hintText;
  final VoidCallback onTap;
  final String? imagePath;

  const PictureInputField({
    Key? key,
    required this.hintText,
    required this.onTap,
    this.imagePath,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.folder_open, color: Colors.orange),
            const SizedBox(width: 12),
            Expanded(
              child: Text(hintText, style: const TextStyle(color: Colors.grey)),
            ),
            if (imagePath != null)
              const Icon(Icons.check_circle, color: Colors.green),
          ],
        ),
      ),
    );
  }
}
