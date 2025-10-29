import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'staff_main.dart'
    show colour_available, colour_borrow, colour_disable, colour_main;

class GameInputForm extends StatefulWidget {
  final bool isEditing;
  final Map<String, dynamic>? initialData;
  final Function(int)? onCountChanged;

  const GameInputForm({
    super.key,
    this.isEditing = false,
    this.initialData,
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

  @override
  void initState() {
    super.initState();
    if (widget.isEditing && widget.initialData != null) {
      _cname.text = widget.initialData!['game_name'] ?? '';
      _cstyle.text = widget.initialData!['game_style'] ?? '';
      _ctime.text = widget.initialData!['game_time'] ?? '';
      _cminP.text = widget.initialData!['min_P'] ?? '';
      _cmaxP.text = widget.initialData!['max_P'] ?? '';
      _clink.text = widget.initialData!['game_how2'] ?? '';
      _gameCount = int.tryParse(widget.initialData!['game_count'] ?? '1') ?? 1;
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

  Map<String, dynamic> getFormData() {
    return {
      'game_name': _cname.text,
      'game_style': _cstyle.text,
      'game_time': _ctime.text,
      'min_P': _cminP.text,
      'max_P': _cmaxP.text,
      'game_how2': _clink.text,
      'game_count': _gameCount.toString(),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
              borderSide: const BorderSide(color: colour_main, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: colour_main, width: 1),
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
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: _gameCount > 1
                  ? () {
                      setState(() => _gameCount--);
                      widget.onCountChanged?.call(_gameCount);
                    }
                  : null,
              icon: const Icon(
                FontAwesomeIcons.circleMinus,
                color: colour_main,
                size: 30,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text('$_gameCount', style: const TextStyle(fontSize: 36)),
            ),
            IconButton(
              onPressed: () {
                setState(() => _gameCount++);
                widget.onCountChanged?.call(_gameCount);
              },
              icon: const Icon(
                FontAwesomeIcons.circlePlus,
                color: colour_main,
                size: 30,
              ),
            ),
          ],
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: colour_main, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: colour_main, width: 1),
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
