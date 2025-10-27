import 'package:flutter/material.dart';
import 'staff_main.dart'
    show colour_available, colour_borrow, colour_disable, colour_main;
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AddNewGame extends StatefulWidget {
  const AddNewGame({super.key});

  @override
  State<AddNewGame> createState() => _AddNewGameState();
}

class _AddNewGameState extends State<AddNewGame> {
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;
  String? _fileName;

  // Function to pick image from gallery
  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        _fileName = pickedFile.name; // ✅ store file name
      });
      print('✅ Image selected: ${pickedFile.path}');
    } else {
      print('❌ No image selected.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: colour_main, size: 30),
        title: const Text(
          'Add new game',
          style: TextStyle(
            color: colour_main,
            fontWeight: FontWeight.w400,
            fontSize: 30,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // =====================
            // 📸 Image Preview Box
            // =====================
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: 190,
                  height: 190,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colour_main, width: 2),
                  ),
                  child: _imageFile == null
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.folder_open,
                                color: colour_main,
                                size: 40,
                              ),
                              SizedBox(height: 8),
                              Text(
                                "Select Picture",
                                style: TextStyle(color: colour_main),
                              ),
                            ],
                          ),
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(_imageFile!, fit: BoxFit.cover),
                        ),
                ),
              ),
            ),

            const SizedBox(height: 40),

            // =====================
            // 🏷️ Label
            // =====================
            const Text('Picture :', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 12),

            // =====================
            // 🖼️ Choose Button
            // =====================
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.folder, color: colour_main),
                label: Text(
                  _fileName != null
                      ? _fileName! // show selected file name
                      : "Choose from gallery . . .",
                  style: const TextStyle(color: Colors.grey, fontSize: 16),
                  overflow: TextOverflow.ellipsis, // ✅ prevent overflow
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: Colors.white,
                  elevation: 0,
                  side: const BorderSide(color: colour_main, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
