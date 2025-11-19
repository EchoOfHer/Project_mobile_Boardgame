import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import 'staff_main.dart' show colour_available, colour_main;
import '/login/login.dart'; // ✅ Import เพื่อใช้ baseUrl

class AddNewGame extends StatefulWidget {
  final String authToken;

  const AddNewGame({super.key, required this.authToken});

  @override
  State<AddNewGame> createState() => _AddNewGameState();
}

class _AddNewGameState extends State<AddNewGame> {
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;

  // Controllers
  final TextEditingController _cname = TextEditingController();
  // final TextEditingController _cstyle = TextEditingController(); // ไม่ใช้แล้วเพราะเปลี่ยนเป็น Dropdown
  final TextEditingController _ctime = TextEditingController();
  final TextEditingController _cminP = TextEditingController();
  final TextEditingController _cmaxP = TextEditingController();
  final TextEditingController _clink = TextEditingController();

  // State for Dropdown
  List<dynamic> _styleList = [];
  String? _selectedStyleName; // เก็บชื่อสไตล์ที่เลือกเพื่อส่งไป Backend
  bool _isLoadingStyles = true;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchStyles();
  }

  // ดึงรายชื่อ Style มาใส่ Dropdown
  Future<void> _fetchStyles() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/game_styles'));
      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            _styleList = jsonDecode(response.body);
            _isLoadingStyles = false;
          });
        }
      } else {
        debugPrint('Failed to fetch styles: ${response.statusCode}');
        if (mounted) setState(() => _isLoadingStyles = false);
      }
    } catch (e) {
      debugPrint('Error fetching styles: $e');
      if (mounted) setState(() => _isLoadingStyles = false);
    }
  }

  bool _validateForm() {
    // 1. Game Name
    if (_cname.text.trim().isEmpty) {
      _showSnackBar('Game name is required', Colors.red);
      return false;
    }

    // 2. Cover Image
    if (_imageFile == null) {
      _showSnackBar('Please select a cover image', Colors.red);
      return false;
    }

    // 3. Game Style (Check Dropdown)
    if (_selectedStyleName == null) {
      _showSnackBar('Please select a game style', Colors.red);
      return false;
    }

    // 4. Play Time
    final timeText = _ctime.text.trim();
    if (timeText.isEmpty) {
      _showSnackBar('Play time is required', Colors.red);
      return false;
    }
    final time = int.tryParse(timeText);
    if (time == null || time <= 0) {
      _showSnackBar('Play time must be greater than 0', Colors.red);
      return false;
    }

    // 5. Min Players
    final minText = _cminP.text.trim();
    if (minText.isEmpty) {
      _showSnackBar('Minimum players is required', Colors.red);
      return false;
    }
    final minP = int.tryParse(minText);
    if (minP == null || minP <= 0) {
      _showSnackBar('Minimum players must be at least 1', Colors.red);
      return false;
    }

    // 6. Max Players
    final maxText = _cmaxP.text.trim();
    if (maxText.isEmpty) {
      _showSnackBar('Maximum players is required', Colors.red);
      return false;
    }
    final maxP = int.tryParse(maxText);
    if (maxP == null || maxP <= 0) {
      _showSnackBar('Maximum players must be at least 1', Colors.red);
      return false;
    }
    if (maxP < minP) {
      _showSnackBar('Max players must be ≥ minimum players', Colors.red);
      return false;
    }

    // 7. How to Play URL
    if (_clink.text.trim().isEmpty) {
      _showSnackBar('How to play URL is required', Colors.red);
      return false;
    }

    return true;
  }

  Future<void> _saveNewGame() async {
    if (_isLoading) return;
    if (!_validateForm()) return;

    setState(() => _isLoading = true);

    // ✅ ใช้ baseUrl จาก login.dart
    final uri = Uri.parse('$baseUrl/api/add_game');
    final request = http.MultipartRequest('POST', uri);

    // ✅ แนบ Token
    request.headers['Authorization'] = 'Bearer ${widget.authToken}';

    request.fields.addAll({
      'game_name': _cname.text.trim(),
      'game_style': _selectedStyleName!, // ส่งชื่อสไตล์ที่เลือกไป
      'game_time': _ctime.text.trim(),
      'min_P': _cminP.text.trim(),
      'max_P': _cmaxP.text.trim(),
      'game_how2': _clink.text.trim(),
    });

    request.files.add(
      await http.MultipartFile.fromPath('game_image', _imageFile!.path),
    );

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      dynamic data;
      try {
        data = jsonDecode(response.body);
      } catch (e) {
        data = {};
      }

      if (response.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Game added successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          // ✅ ส่งค่า true กลับไป
          Navigator.pop(context, true);
        }
      } else {
        final msg = data['message'] ?? 'Failed to add game';
        _showSnackBar(msg, Colors.red);
      }
    } catch (e) {
      debugPrint('Error: $e');
      _showSnackBar('Cannot connect to server: $e', Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  Future<void> _pickImage() async {
    final XFile? picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _imageFile = File(picked.path));
    }
  }

  @override
  void dispose() {
    _cname.dispose();
    // _cstyle.dispose();
    _ctime.dispose();
    _cminP.dispose();
    _cmaxP.dispose();
    _clink.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: colour_main, size: 30),
        title: const Text(
          'Add New Game',
          style: TextStyle(color: colour_main, fontSize: 30),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cover Image
                Center(
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      width: 190,
                      height: 190,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: colour_main, width: 3),
                      ),
                      child: _imageFile == null
                          ? const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_photo_alternate,
                                  size: 50,
                                  color: colour_main,
                                ),
                                SizedBox(height: 10),
                                Text(
                                  'Tap to select image',
                                  style: TextStyle(color: colour_main),
                                ),
                              ],
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(13),
                              child: Image.file(_imageFile!, fit: BoxFit.cover),
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.photo_library, color: Colors.white),
                    label: Text(
                      _imageFile == null ? 'Select Cover' : 'Change Cover',
                      style: const TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colour_main,
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                const Text('Game Name *', style: TextStyle(fontSize: 18)),
                const SizedBox(height: 8),
                TextField(
                  controller: _cname,
                  decoration: _inputDecoration('Required'),
                ),

                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Game Style *',
                            style: TextStyle(fontSize: 18),
                          ),
                          const SizedBox(height: 8),
                          // ★ เปลี่ยน TextField เป็น DropdownButtonFormField
                          _isLoadingStyles
                              ? const LinearProgressIndicator(
                                  color: colour_main,
                                )
                              : DropdownButtonFormField<String>(
                                  value: _selectedStyleName,
                                  isExpanded: true,
                                  items: _styleList
                                      .map<DropdownMenuItem<String>>((style) {
                                        return DropdownMenuItem<String>(
                                          value: style['style_name']
                                              .toString(), // ส่งชื่อ
                                          child: Text(
                                            style['style_name'].toString(),
                                          ),
                                        );
                                      })
                                      .toList(),
                                  onChanged: (val) {
                                    setState(() {
                                      _selectedStyleName = val;
                                    });
                                  },
                                  decoration: _inputDecoration('Select Style'),
                                  validator: (v) =>
                                      v == null ? 'Required' : null,
                                ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Play Time (min) *',
                            style: TextStyle(fontSize: 18),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _ctime,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            decoration: _inputDecoration('Required'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                const Text('Players *', style: TextStyle(fontSize: 18)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _cminP,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: _inputDecoration('Min'),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text('-', style: TextStyle(fontSize: 24)),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _cmaxP,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: _inputDecoration('Max'),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                const Text('How to Play URL *', style: TextStyle(fontSize: 18)),
                const SizedBox(height: 8),
                TextField(
                  controller: _clink,
                  keyboardType: TextInputType.url,
                  decoration: _inputDecoration('Required – https://...'),
                ),

                const SizedBox(height: 50),

                Center(
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveNewGame,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colour_main,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Confirm Add Game',
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 50),
              ],
            ),
          ),

          // Loading overlay
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey[600]),
      filled: true,
      fillColor: Colors.grey[50],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: colour_main),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: colour_main),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: colour_main, width: 2),
      ),
    );
  }
}
