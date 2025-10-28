import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
  int _gameCount = 0;

  // Controllers (Defined in State class)
  final TextEditingController _cname = TextEditingController();
  final TextEditingController _cstyle = TextEditingController();
  final TextEditingController _ctime = TextEditingController();
  final TextEditingController _cminP = TextEditingController();
  final TextEditingController _cmaxP = TextEditingController();
  final TextEditingController _clink = TextEditingController();

  // State variable for visual validation feedback
  String _validationError = '';

  // Basic RegExp for URL format checking
  static final RegExp _urlRegExp = RegExp(
    r'^(http(s)?:\/\/)?([\w-]+\.)+[\w-]+(\/[\w-.\/?%&=]*)?$',
    caseSensitive: false,
  );

  // Function to pick image from gallery
  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        _fileName = pickedFile.name;
      });
      debugPrint('✅ Image selected: ${pickedFile.path}');
    } else {
      debugPrint('❌ No image selected.');
    }
  }

  // 🚨 ERROR ALERT FUNCTION
  void _showAlert(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Input Error', style: TextStyle(color: Colors.red)),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // 👥 PLAYER VALIDATION LOGIC (Updates visual error state)
  void _validatePlayers() {
    int min = int.tryParse(_cminP.text) ?? 0;
    int max = int.tryParse(_cmaxP.text) ?? 0;

    String error = '';

    if (_cminP.text.isEmpty && _cmaxP.text.isEmpty) {
      // Don't show error while both are empty
    } else if (min <= 0 ||
        max <= 0 ||
        _cminP.text.isEmpty ||
        _cmaxP.text.isEmpty) {
      error = 'Minimum and Maximum players must be valid numbers (> 0).';
    } else if (min > max) {
      error = 'Minimum players must be less than or equal to maximum.';
    }

    if (_validationError != error) {
      setState(() {
        _validationError = error;
      });
    }
  }

  // ✅ FINAL VALIDATION CHECK (STRICT LOGIC)
  bool _isValidForm() {
    int min = int.tryParse(_cminP.text) ?? 0;
    int max = int.tryParse(_cmaxP.text) ?? 0;
    int time = int.tryParse(_ctime.text) ?? 0;

    // 1. Image Check
    if (_imageFile == null) {
      _showAlert('Please select a picture for the game cover.');
      return false;
    }

    // 2. Name Check
    if (_cname.text.trim().isEmpty) {
      _showAlert('Game Name is required.');
      return false;
    }

    // 3. Time Check (Non-zero)
    if (time <= 0 || _ctime.text.trim().isEmpty) {
      _showAlert('Game Time must be a valid number greater than 0 minutes.');
      return false;
    }

    // 4. Player Count Check (Non-null/Non-zero/Order)
    if (min <= 0 ||
        max <= 0 ||
        _cminP.text.trim().isEmpty ||
        _cmaxP.text.trim().isEmpty) {
      _showAlert(
        'Both Minimum and Maximum players must be valid numbers greater than zero.',
      );
      return false;
    }
    if (min > max) {
      _showAlert(
        'Minimum players must be less than or equal to maximum players.',
      );
      return false;
    }

    // 5. Link Format Check (If provided, must look like a URL)
    if (_clink.text.trim().isNotEmpty &&
        !_urlRegExp.hasMatch(_clink.text.trim())) {
      _showAlert(
        'The "How to Play" link must be a valid URL format (e.g., www.website.com).',
      );
      return false;
    }

    // 🌟 NEW 6. Quantity Check (must be greater than 0)
    if (_gameCount <= 0) {
      _showAlert('The quantity of the game to add must be greater than zero.');
      return false;
    }

    // All checks passed
    return true;
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 📸 Image Preview Box
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

              // 🖼️ Choose Button
              const Text('Picture :', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.folder, color: colour_main),
                  label: Text(
                    _fileName != null
                        ? _fileName!
                        : "Choose from gallery . . .",
                    style: const TextStyle(color: Colors.grey, fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                    side: const BorderSide(color: colour_main, width: 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // 🏷️ Name Input
              const Text('Name :', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 12),
              SizedBox(
                height: 45,
                child: TextField(
                  controller: _cname,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 10,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: colour_main,
                        width: 1,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: colour_main,
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: colour_main,
                        width: 1,
                      ),
                    ),
                    hintText: 'Name . . . ',
                    hintStyle: const TextStyle(color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // 🏷️ Game Style & Time
              const Row(
                children: [
                  Expanded(
                    flex: 6,
                    child: Text('Game Style :', style: TextStyle(fontSize: 16)),
                  ),
                  Expanded(
                    flex: 6,
                    child: Text('Time(min) :', style: TextStyle(fontSize: 16)),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Flexible(
                    child: SizedBox(
                      height: 43,
                      child: TextField(
                        controller: _cstyle,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 10,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: colour_main,
                              width: 1,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: colour_main,
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: colour_main,
                              width: 1,
                            ),
                          ),
                          hintText: 'Style',
                          hintStyle: const TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    child: SizedBox(
                      height: 43,
                      child: TextField(
                        controller: _ctime,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        onChanged: (value) => setState(() {}),
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 10,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color:
                                  (int.tryParse(_ctime.text) ?? 0) <= 0 &&
                                      _ctime.text.isNotEmpty
                                  ? Colors.red
                                  : colour_main,
                              width: 1,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color:
                                  (int.tryParse(_ctime.text) ?? 0) <= 0 &&
                                      _ctime.text.isNotEmpty
                                  ? Colors.red
                                  : colour_main,
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color:
                                  (int.tryParse(_ctime.text) ?? 0) <= 0 &&
                                      _ctime.text.isNotEmpty
                                  ? Colors.red
                                  : colour_main,
                              width: 1,
                            ),
                          ),
                          hintText: 'Time',
                          hintStyle: const TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 🏷️ Min/Max Players
              const Text('Players :', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 10),
              Row(
                children: [
                  Flexible(
                    child: SizedBox(
                      height: 43,
                      child: TextField(
                        controller: _cminP,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        onChanged: (text) {
                          _validatePlayers();
                        },
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 10,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: _validationError.isNotEmpty
                                  ? Colors.red
                                  : colour_main,
                              width: 1,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: _validationError.isNotEmpty
                                  ? Colors.red
                                  : colour_main,
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: _validationError.isNotEmpty
                                  ? Colors.red
                                  : colour_main,
                              width: 1,
                            ),
                          ),
                          hintText: 'minimum',
                          hintStyle: const TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    child: SizedBox(
                      height: 43,
                      child: TextField(
                        controller: _cmaxP,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        onChanged: (text) {
                          _validatePlayers();
                        },
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 10,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: _validationError.isNotEmpty
                                  ? Colors.red
                                  : colour_main,
                              width: 1,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: _validationError.isNotEmpty
                                  ? Colors.red
                                  : colour_main,
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: _validationError.isNotEmpty
                                  ? Colors.red
                                  : colour_main,
                              width: 1,
                            ),
                          ),
                          hintText: 'maximum',
                          hintStyle: const TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Validation Error Message
              if (_validationError.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    _validationError,
                    style: const TextStyle(color: Colors.red, fontSize: 14),
                  ),
                ),

              const SizedBox(height: 12),

              // 🏷️ How to play (Link)
              const Text('How to play :', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 12),
              SizedBox(
                height: 43,
                child: TextField(
                  controller: _clink,
                  keyboardType: TextInputType.url,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.link, color: Colors.grey),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 10,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: colour_main,
                        width: 1,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: colour_main,
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: colour_main,
                        width: 1,
                      ),
                    ),
                    hintText: 'Paste the Link (URL) here . . .',
                    hintStyle: const TextStyle(color: Colors.grey),
                  ),
                ),
              ),

              // 🛒 Item Counter (Functional)
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 20, 10, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () {
                        setState(() {
                          if (_gameCount > 0) _gameCount--;
                        });
                      },
                      icon: const Icon(
                        FontAwesomeIcons.circleMinus,
                        color: colour_main,
                        size: 30,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        '$_gameCount',
                        style: const TextStyle(fontSize: 40),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _gameCount++;
                        });
                      },
                      icon: const Icon(
                        FontAwesomeIcons.circlePlus,
                        color: colour_main,
                        size: 30,
                      ),
                    ),
                  ],
                ),
              ),

              // ✅ Confirm Button (Validation applied here)
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    // 1. Check all validation rules
                    if (!_isValidForm()) {
                      return; // Stop form submission; alert was already shown
                    }

                    // 2. If validation passes, collect and send data
                    final Map Ngame = {
                      'game_imageP': _fileName ?? '',
                      'game_name': _cname.text,
                      'game_style': _cstyle.text,
                      'game_time': _ctime.text,
                      'game_minP': _cminP.text,
                      'game_maxP': _cmaxP.text,
                      'game_how2': _clink.text,
                      'game_count': _gameCount.toString(),
                    };

                    debugPrint('--- Validation Passed. Sending Data ---');
                    Navigator.pop(context, Ngame);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: colour_main),
                  child: const Text(
                    'Confirm',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
