// lib/Staff_screens/EditGame.dart
import 'package:flutter/material.dart';
import 'package:boardgame_app/Staff/game_input_form.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:boardgame_app/Staff/staff_main.dart'
    show colour_available, colour_main, colour_available, colour_main;
// import 'staff_dashboard.dart';
import 'game_data.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

final String url = '10.0.2.2:3000';

class EditGame extends StatelessWidget {
  final GameItem game;
  final int groupCount;
  final Function(int newCount) onCountChanged;
  final String authToken;

  const EditGame({
    super.key,
    required this.game,
    required this.groupCount,
    required this.onCountChanged,
    required this.authToken,
  });

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<GameInputFormState>();

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: colour_main, size: 30),
        title: const Text(
          'Edit Board Game',
          style: TextStyle(color: colour_main, fontSize: 30),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              height: 200,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 175,
                    height: 190,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(game.picPath, fit: BoxFit.cover),
                    ),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Name : ',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          game.gameName,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow:
                              TextOverflow.ellipsis, // <-- This will now work
                        ),
                        Text(
                          'Game Style : ',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(game.gameStyle, style: TextStyle(fontSize: 16)),
                        Text(
                          'Player : ',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          "${game.minP} - ${game.maxP} peoples",
                          style: TextStyle(fontSize: 16),
                        ),
                        Text(
                          'Time : ',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          "${game.gTime} min",
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            GameInputForm(
              key: formKey,
              isEditing: true,
              initialData: {
                'game_name': game.gameName,
                'game_style': game.gameStyle,
                'game_time': game.gTime.toString(),
                'min_P': game.minP.toString(),
                'max_P': game.maxP.toString(),
                'game_how2': game.g_link,
                'game_count': groupCount.toString(),
              },
              onCountChanged: onCountChanged,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: colour_main,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 15,
                ),
              ),
              onPressed: () async {
                final data = formKey.currentState?.getFormData();
                if (data == null) return;
                
                final updateData = {
                  'game_name':
                      (data['game_name'] as String?)?.trim() ?? game.gameName,
                  'style_id': 1, // เปลี่ยนตามจริงได้ในอนาคต
                  'game_time':
                      data['game_time']?.toString() ?? game.gTime.toString(),
                  'game_min_player':
                      data['min_P']?.toString() ?? game.minP.toString(),
                  'game_max_player':
                      data['max_P']?.toString() ?? game.maxP.toString(),
                  'game_link_howto':
                      data['game_how2']?.toString() ?? game.g_link,
                  'total_copies':
                      data['game_count']?.toString() ?? groupCount.toString(),
                };

                try {
                  final response = await http.put(
                    Uri.http(url, '/api/staff/game/${game.gameId}'),
                    headers: {
                      'Content-Type': 'application/json',
                      'Authorization': 'Bearer $authToken',
                    },
                    body: jsonEncode(updateData),
                  );

                  if (response.statusCode == 200) {
                    final json = jsonDecode(response.body);
                    if (json['success'] == true) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('แก้ไขข้อมูลเกมสำเร็จ!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                      Navigator.pop(context, true); // ส่ง flag กลับไปรีเฟรช
                    }
                  } else {
                    throw Exception('Server error: ${response.body}');
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('ไม่สามารถแก้ไขได้: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text(
                'Confirm',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoLine(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
