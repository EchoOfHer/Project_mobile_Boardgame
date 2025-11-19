import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'game_data.dart'; // Ensure this file exists and has GameItem class
import 'staff_main.dart' show colour_main; // Adjust imports if needed
import '/login/login.dart'; // Ensure this file exports 'baseUrl'

class EditGame extends StatefulWidget {
  final GameItem game;
  final String authToken;

  const EditGame({super.key, required this.game, required this.authToken});

  @override
  State<EditGame> createState() => _EditGameState();
}

class _EditGameState extends State<EditGame> {
  // Note: We don't need GlobalKey<FormState> anymore since we are doing manual validation
  // to show errors in SnackBar instead of under the fields.

  late TextEditingController nameCtrl;
  late TextEditingController timeCtrl;
  late TextEditingController minPCtrl;
  late TextEditingController maxPCtrl;
  late TextEditingController linkCtrl;

  // Dropdown Style
  List<dynamic> _styleList = [];
  String? _selectedStyleId;

  // Image Picker
  File? _newImageFile;
  final ImagePicker _picker = ImagePicker();

  bool _isSaving = false;
  bool _isLoadingStyles = true;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing data
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
      } else {
        setState(() => _isLoadingStyles = false);
      }
    } catch (e) {
      print('Error fetching styles: $e');
      setState(() => _isLoadingStyles = false);
    }
  }

  Future<void> _pickImage() async {
    final XFile? picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _newImageFile = File(picked.path));
    }
  }

  // ✅ Helper: Shows error at the very bottom (Full width, no floating)
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).clearSnackBars(); // Remove old alerts instantly
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.fixed, // Stiks to bottom
        shape: null, // Square corners
        margin: null, // No margin
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _saveChanges() async {
    // --- 1. Manual Validation (Result -> SnackBar) ---

    // Game Name
    if (nameCtrl.text.trim().isEmpty) {
      _showErrorSnackBar("Game Name is required");
      return;
    }

    // Style
    if (_selectedStyleId == null) {
      _showErrorSnackBar("Please select a Game Style");
      return;
    }

    // Min Players
    if (minPCtrl.text.trim().isEmpty) {
      _showErrorSnackBar("Min Players is required");
      return;
    }
    final int? minP = int.tryParse(minPCtrl.text);
    if (minP == null || minP <= 0) {
      _showErrorSnackBar("Min Players must be a number greater than 0");
      return;
    }

    // Max Players
    if (maxPCtrl.text.trim().isEmpty) {
      _showErrorSnackBar("Max Players is required");
      return;
    }
    final int? maxP = int.tryParse(maxPCtrl.text);
    if (maxP == null || maxP <= 0) {
      _showErrorSnackBar("Max Players must be a number greater than 0");
      return;
    }

    // Logic Check
    if (minP > maxP) {
      _showErrorSnackBar("Min Players cannot be greater than Max Players");
      return;
    }

    // Play Time
    if (timeCtrl.text.trim().isEmpty) {
      _showErrorSnackBar("Play Time is required");
      return;
    }
    final int? time = int.tryParse(timeCtrl.text);
    if (time == null || time <= 0) {
      _showErrorSnackBar("Play Time must be a number greater than 0");
      return;
    }

    // Link
    if (linkCtrl.text.trim().isEmpty) {
      _showErrorSnackBar("How to Play URL is required");
      return;
    }

    // --- 2. API Request ---
    setState(() => _isSaving = true);

    try {
      var request = http.MultipartRequest(
        'PUT',
        Uri.parse('$baseUrl/api/staff/game/${widget.game.gameId}'),
      );

      request.headers['Authorization'] = 'Bearer ${widget.authToken}';

      request.fields['game_name'] = nameCtrl.text;
      if (_selectedStyleId != null) {
        request.fields['style_id'] = _selectedStyleId!;
      }
      request.fields['game_time'] = timeCtrl.text;
      request.fields['game_min_player'] = minPCtrl.text;
      request.fields['game_max_player'] = maxPCtrl.text;
      request.fields['game_link_howto'] = linkCtrl.text;

      if (_newImageFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath('game_image', _newImageFile!.path),
        );
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
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
          picPath: newPicPath,
          status: widget.game.status,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Game updated successfully'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.fixed,
            ),
          );
          Navigator.pop(context, updatedGame);
        }
      } else {
        final msg = jsonDecode(response.body)['message'] ?? 'Failed to update';
        if (mounted) {
          _showErrorSnackBar(msg);
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Error: $e');
      }
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
        child: Column(
          children: [
            // --- Image Section ---
            Stack(
              children: [
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

            // --- Form Fields ---
            _buildField(nameCtrl, 'Game Name'),

            // Style Dropdown
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
                              borderSide: const BorderSide(color: colour_main),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: colour_main),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: colour_main,
                                width: 2,
                              ),
                            ),
                          ),
                          // Validator removed so no red text appears
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
            // Validator removed so no red text appears
          ),
        ],
      ),
    );
  }
}
