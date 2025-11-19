import 'dart:io'; // ✅ Import สำหรับ File
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart'; // ✅ Import ImagePicker
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'game_data.dart';
import 'staff_main.dart' show colour_main, colour_available;
import '/login/login.dart';

class EditGame extends StatefulWidget {
  final GameItem game;
  final String authToken;

  const EditGame({super.key, required this.game, required this.authToken});

  @override
  State<EditGame> createState() => _EditGameState();
}

class _EditGameState extends State<EditGame> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController nameCtrl;
  late TextEditingController timeCtrl;
  late TextEditingController minPCtrl;
  late TextEditingController maxPCtrl;
  late TextEditingController linkCtrl;

  // สำหรับ Dropdown Style
  List<dynamic> _styleList = [];
  String? _selectedStyleId;

  // สำหรับ Image Picker
  File? _newImageFile;
  final ImagePicker _picker = ImagePicker();

  bool _isSaving = false;
  bool _isLoadingStyles = true;

  @override
  void initState() {
    super.initState();
    nameCtrl = TextEditingController(text: widget.game.gameName);
    timeCtrl = TextEditingController(text: widget.game.gTime.toString());
    minPCtrl = TextEditingController(text: widget.game.minP.toString());
    maxPCtrl = TextEditingController(text: widget.game.maxP.toString());
    linkCtrl = TextEditingController(text: widget.game.g_link);

    _fetchStyles();
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    timeCtrl.dispose();
    minPCtrl.dispose();
    maxPCtrl.dispose();
    linkCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchStyles() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/game_styles'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _styleList = data;
          final matchingStyle = data.firstWhere(
            (s) => s['style_name'] == widget.game.gameStyle,
            orElse: () => null,
          );
          if (matchingStyle != null) {
            _selectedStyleId = matchingStyle['style_id'].toString();
          }
          _isLoadingStyles = false;
        });
      }
    } catch (e) {
      print('Error fetching styles: $e');
      setState(() => _isLoadingStyles = false);
    }
  }

  // ฟังก์ชันเลือกรูป
  Future<void> _pickImage() async {
    final XFile? picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _newImageFile = File(picked.path));
    }
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      // ✅ เปลี่ยนเป็น MultipartRequest
      var request = http.MultipartRequest(
        'PUT',
        Uri.parse('$baseUrl/api/staff/game/${widget.game.gameId}'),
      );

      // แนบ Header
      request.headers['Authorization'] = 'Bearer ${widget.authToken}';

      // แนบ Text Fields
      request.fields['game_name'] = nameCtrl.text;
      if (_selectedStyleId != null) {
        request.fields['style_id'] = _selectedStyleId!;
      }
      request.fields['game_time'] = timeCtrl.text;
      request.fields['game_min_player'] = minPCtrl.text;
      request.fields['game_max_player'] = maxPCtrl.text;
      request.fields['game_link_howto'] = linkCtrl.text;
      // ส่ง path เดิมไปด้วยเผื่อไม่ได้อัปรูปใหม่
      request.fields['game_pic_path'] = widget.game.picPath.replaceAll(
        '$baseUrl/',
        '',
      );

      // แนบไฟล์รูป (ถ้ามีการเลือกใหม่)
      if (_newImageFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath('game_image', _newImageFile!.path),
        );
      }

      // ส่ง Request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        // อ่าน path รูปใหม่ที่ Backend ส่งกลับมา (หรือใช้รูปเดิมถ้าไม่ได้แก้)
        final respData = jsonDecode(response.body);
        final newPicPath = respData['new_pic_path'] ?? widget.game.picPath;

        final selectedStyleObj = _styleList.firstWhere(
          (s) => s['style_id'].toString() == _selectedStyleId,
          orElse: () => {'style_name': widget.game.gameStyle},
        );

        final updatedGame = GameItem(
          gameId: widget.game.gameId,
          gameName: nameCtrl.text,
          gameGroup: nameCtrl.text,
          gameStyle: selectedStyleObj['style_name'],
          gTime: int.parse(timeCtrl.text),
          minP: int.parse(minPCtrl.text),
          maxP: int.parse(maxPCtrl.text),
          g_link: linkCtrl.text,
          picPath: newPicPath, // อัปเดต Path รูปใน object
          status: widget.game.status,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Game updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, updatedGame);
        }
      } else {
        final msg = jsonDecode(response.body)['message'] ?? 'Failed to update';
        if (mounted)
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(msg), backgroundColor: Colors.red),
          );
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    String imageUrl = widget.game.picPath;
    if (!imageUrl.startsWith('http')) {
      imageUrl = '$baseUrl/$imageUrl';
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Board Game'),
        backgroundColor: Colors.white,
        foregroundColor: colour_main,
        elevation: 0,
        iconTheme: const IconThemeData(color: colour_main),
        titleTextStyle: const TextStyle(
          color: colour_main,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // --- ส่วนแสดงผลและแก้ไขรูป ---
              Stack(
                children: [
                  // รูปภาพ (แสดงรูปเดิม หรือรูปใหม่ที่เลือก)
                  Container(
                    height: 200,
                    width: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.grey[200],
                      border: Border.all(color: colour_main, width: 2),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: _newImageFile != null
                          ? Image.file(_newImageFile!, fit: BoxFit.cover)
                          : Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.broken_image,
                                size: 50,
                                color: Colors.grey,
                              ),
                            ),
                    ),
                  ),
                  // ปุ่มกล้อง (Overlay)
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: colour_main,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(blurRadius: 5, color: Colors.black26),
                          ],
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // --- แบบฟอร์มแก้ไข ---
              _buildField(nameCtrl, 'Game Name'),

              // ★ Dropdown สำหรับเลือก Style
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Game Style',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _isLoadingStyles
                        ? const LinearProgressIndicator(color: colour_main)
                        : DropdownButtonFormField<String>(
                            value: _selectedStyleId,
                            items: _styleList.map<DropdownMenuItem<String>>((
                              style,
                            ) {
                              return DropdownMenuItem<String>(
                                value: style['style_id'].toString(),
                                child: Text(style['style_name']),
                              );
                            }).toList(),
                            onChanged: (val) =>
                                setState(() => _selectedStyleId = val),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.grey[50],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: colour_main,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: colour_main,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: colour_main,
                                  width: 2,
                                ),
                              ),
                            ),
                            validator: (v) =>
                                v == null ? 'Please select a style' : null,
                          ),
                  ],
                ),
              ),

              Row(
                children: [
                  Expanded(
                    child: _buildField(minPCtrl, 'Min Players', isNumber: true),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: _buildField(maxPCtrl, 'Max Players', isNumber: true),
                  ),
                ],
              ),
              _buildField(timeCtrl, 'Play Time (min)', isNumber: true),
              _buildField(linkCtrl, 'How to Play URL'),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colour_main,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _isSaving ? null : _saveChanges,
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Confirm',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(
    TextEditingController ctrl,
    String label, {
    bool isNumber = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: ctrl,
            keyboardType: isNumber ? TextInputType.number : TextInputType.text,
            inputFormatters: isNumber
                ? [FilteringTextInputFormatter.digitsOnly]
                : [],
            decoration: InputDecoration(
              hintText: 'Enter $label',
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
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
            ),
            validator: (v) =>
                v == null || v.trim().isEmpty ? '$label is required' : null,
          ),
        ],
      ),
    );
  }
}
