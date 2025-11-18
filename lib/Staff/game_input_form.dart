// lib/Staff/game_input_form.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'staff_main.dart' show colour_available, colour_main;

class GameInputForm extends StatefulWidget {
  final bool isEditing;
  final Map<String, dynamic>? initialData;
  final int? gameId; // เพิ่ม
  final String? currentImageUrl; // เพิ่ม
  final String authToken; // เพิ่ม
  final Function(int)? onCountChanged;

  const GameInputForm({
    super.key,
    this.isEditing = false,
    this.initialData,
    this.gameId,
    this.currentImageUrl,
    required this.authToken, // required
    this.onCountChanged,
  });

  @override
  State<GameInputForm> createState() => GameInputFormState();
}

class GameInputFormState extends State<GameInputForm> {
  final _cname = TextEditingController();
  final _cstyle = TextEditingController();
  final _ctime = TextEditingController();
  final _cminP = TextEditingController();
  final _cmaxP = TextEditingController();
  final _clink = TextEditingController();
  int _gameCount = 1;

  File? _selectedImage;
  String? _currentImageUrl;

  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _currentImageUrl = widget.currentImageUrl;

    if (widget.isEditing && widget.initialData != null) {
      final data = widget.initialData!;
      _cname.text = data['game_name'] ?? '';
      _cstyle.text = data['game_style'] ?? '';
      _ctime.text = data['game_time'] ?? '';
      _cminP.text = data['min_P'] ?? '';
      _cmaxP.text = data['max_P'] ?? '';
      _clink.text = data['game_how2'] ?? '';
      _gameCount = int.tryParse(data['game_count']?.toString() ?? '1') ?? 1;
    }
  }

  @override
  void dispose() {
    _cname.dispose();
    _cstyle.dispose();
    _ctime.dispose();
    _cminP.dispose();
    _cmaxP.dispose();
    _clink.dispose();
    super.dispose();
  }

  // ฟังก์ชันเลือกภาพ
  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  // ดึงข้อมูลฟอร์ม (รวมรูปใหม่ถ้ามี)
  Map<String, String> getFormData() {
    return {
      'game_name': _cname.text,
      'game_style': _cstyle.text,
      'game_time': _ctime.text,
      'min_P': _cminP.text,
      'max_P': _cmaxP.text,
      'game_how2': _clink.text,
      'game_count': _gameCount.toString(),
      if (_selectedImage != null) 'new_image_path': _selectedImage!.path,
    };
  }

  // ฟังก์ชันส่งข้อมูลไป backend (เรียกจาก EditGame หรือ AddNewGame)
  Future<Map<String, dynamic>?> submitForm() async {
    if (_cname.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('กรุณากรอกชื่อเกม')));
      return null;
    }

    final url = widget.isEditing && widget.gameId != null
        ? Uri.parse('http://10.0.2.2:3000/staff/game/${widget.gameId}')
        : Uri.parse('http://10.0.2.2:3000/staff/game');

    var request = http.MultipartRequest(widget.isEditing ? 'PUT' : 'POST', url)
      ..headers['Authorization'] = 'Bearer ${widget.authToken}'
      ..fields['game_name'] = _cname.text
      ..fields['game_style'] = _cstyle.text
      ..fields['game_time'] = _ctime.text
      ..fields['min_P'] = _cminP.text
      ..fields['max_P'] = _cmaxP.text
      ..fields['game_how2'] = _clink.text;
      // ..fields['game_count'] = _gameCount.toString();

    // ถ้ามีรูปใหม่
    if (_selectedImage != null) {
      request.files.add(
        await http.MultipartFile.fromPath('image', _selectedImage!.path),
      );
    }

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'data': response.body};
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${response.body}')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Network error: $e')));
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // แสดงรูปปัจจุบัน + ปุ่มเปลี่ยนรูป
        Center(
          child: Stack(
            children: [
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: colour_main, width: 3),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(17),
                  child: _selectedImage != null
                      ? Image.file(_selectedImage!, fit: BoxFit.cover)
                      : (_currentImageUrl != null
                            ? Image.network(
                                _currentImageUrl!,
                                fit: BoxFit.cover,
                              )
                            : Container(color: Colors.grey[300])),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: IconButton(
                  icon: const Icon(Icons.camera_alt, color: Colors.white),
                  style: IconButton.styleFrom(backgroundColor: colour_main),
                  onPressed: _pickImage,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        const Text('Name :', style: TextStyle(fontSize: 16)),
        const SizedBox(height: 10),
        TextField(
          controller: _cname,
          decoration: _inputDecoration('Name . . .'),
        ),
        const SizedBox(height: 16),

        const Row(
          children: [
            Expanded(
              child: Text('Game Style :', style: TextStyle(fontSize: 16)),
            ),
            Expanded(
              child: Text('Time (min) :', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _cstyle,
                decoration: _inputDecoration('Style'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _ctime,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: _inputDecoration('Time'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        const Text('Players :', style: TextStyle(fontSize: 16)),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _cminP,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: _inputDecoration('Minimum'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _cmaxP,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: _inputDecoration('Maximum'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        const Text('How to play (link) :', style: TextStyle(fontSize: 16)),
        const SizedBox(height: 10),
        TextField(
          controller: _clink,
          keyboardType: TextInputType.url,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              vertical: 10,
              horizontal: 10,
            ),
            prefixIcon: const Icon(Icons.link, color: Colors.grey),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: colour_main),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: colour_main),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: colour_main, width: 2),
            ),
            hintText: 'Paste URL here...',
            hintStyle: const TextStyle(color: Colors.grey),
          ),
        ),
        const SizedBox(height: 20),

        // จำนวนชุด
        // Row(
        //   mainAxisAlignment: MainAxisAlignment.center,
        //   children: [
        //     IconButton(
        //       onPressed: _gameCount > 1
        //           ? () {
        //               setState(() => _gameCount--);
        //               widget.onCountChanged?.call(_gameCount);
        //             }
        //           : null,
        //       icon: const Icon(
        //         FontAwesomeIcons.circleMinus,
        //         color: colour_main,
        //         size: 30,
        //       ),
        //     ),
        //     Padding(
        //       padding: const EdgeInsets.symmetric(horizontal: 10),
        //       child: Text('$_gameCount', style: const TextStyle(fontSize: 36)),
        //     ),
        //     IconButton(
        //       onPressed: () {
        //         setState(() => _gameCount++);
        //         widget.onCountChanged?.call(_gameCount);
        //       },
        //       icon: const Icon(
        //         FontAwesomeIcons.circlePlus,
        //         color: colour_main,
        //         size: 30,
        //       ),
        //     ),
        //   ],
        // ),
      ],
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: colour_main),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: colour_main),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: colour_main, width: 2),
      ),
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.grey),
    );
  }
}
