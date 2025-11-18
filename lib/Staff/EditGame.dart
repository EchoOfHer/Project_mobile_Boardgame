// lib/Staff_screens/EditGame.dart
import 'package:flutter/material.dart';
import 'package:boardgame_app/Staff/game_input_form.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:boardgame_app/Staff/staff_main.dart'
    show colour_available, colour_main;
import 'game_data.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

final String url = '10.0.2.2:3000';

class EditGame extends StatelessWidget {
  final GameItem game;
  // final int groupCount;
  // final Function(int newCount) onCountChanged;
  final String authToken;

  const EditGame({
    super.key,
    required this.game,
    // required this.groupCount,
    // required this.onCountChanged,
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
            // UI เดิมทุกอย่าง
            // Container(
            //   height: 200,
            //   child: Row(
            //     crossAxisAlignment: CrossAxisAlignment.start,
            //     children: [
            //       Container(
            //         width: 175,
            //         height: 190,
            //         child: ClipRRect(
            //           borderRadius: BorderRadius.circular(20),
            //           child: Image.network(
            //             game.picPath,
            //             fit: BoxFit.cover,
            //             errorBuilder: (context, error, stackTrace) {
            //               return Container(
            //                 color: Colors.grey[300],
            //                 child: const Icon(Icons.broken_image, size: 50, color: Colors.grey),
            //               );
            //             },
            //           ),
            //         ),
            //       ),
            //       const SizedBox(width: 20),
            //       Expanded(
            //         child: Column(
            //           crossAxisAlignment: CrossAxisAlignment.start,
            //           children: [
            //             Text('Name : ', style: TextStyle(fontSize: 15, color: Colors.grey[600])),
            //             Text(game.gameName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            //             const SizedBox(height: 8),
            //             Text('Game Style : ', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
            //             Text(game.gameStyle, style: const TextStyle(fontSize: 16)),
            //             const SizedBox(height: 8),
            //             Text('Player : ', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
            //             Text("${game.minP} - ${game.maxP} peoples", style: const TextStyle(fontSize: 16)),
            //             const SizedBox(height: 8),
            //             Text('Time : ', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
            //             Text("${game.gTime} min", style: const TextStyle(fontSize: 16)),
            //           ],
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
            // const SizedBox(height: 30),

            GameInputForm(
              key: formKey,
              isEditing: true,
              authToken: authToken,
              gameId: game.gameId,
              currentImageUrl: game.picPath,
              initialData: {
                'game_name': game.gameName,
                'game_style': game.gameStyle,
                'game_time': game.gTime.toString(),
                'min_P': game.minP.toString(),
                'max_P': game.maxP.toString(),
                'game_how2': game.g_link,
                // 'game_count': groupCount.toString(),
              },
              // onCountChanged: onCountChanged,
            ),

            const SizedBox(height: 40),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: colour_main,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              onPressed: () async {
                final data = formKey.currentState?.getFormData();
                if (data == null) return;

                // แก้ error ทั้งหมดที่นี่ (บรรทัด 126-127)
                final String newName = data['game_name']?.toString().trim().isNotEmpty == true
                    ? data['game_name'].toString().trim()
                    : game.gameName;

                final String newLink = data['game_how2']?.toString().trim() ?? game.g_link;

                final updateData = {
                  'game_name': newName,
                  'style_id': 1,
                  'game_time': int.tryParse(data['game_time']?.toString() ?? '0') ?? game.gTime,
                  'game_min_player': int.tryParse(data['min_P']?.toString() ?? '0') ?? game.minP,
                  'game_max_player': int.tryParse(data['max_P']?.toString() ?? '0') ?? game.maxP,
                  'game_link_howto': newLink,
                  if (data['new_image_path'] != null) 'game_pic_path': data['new_image_path'],
                  // ไม่ส่ง total_copies อีกต่อไป
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

                  if (response.statusCode == 200 && jsonDecode(response.body)['success'] == true) {
                    await showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) => AlertDialog(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        icon: const Icon(FontAwesomeIcons.circleCheck, color: colour_available, size: 60),
                        title: const Text('Edit Successful!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20), textAlign: TextAlign.center),
                        content: Text('Game "$newName" has been updated.', style: const TextStyle(fontSize: 16), textAlign: TextAlign.center),
                        actions: [
                          Center(
                            child: TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                Navigator.pop(context, true); // รีเฟรช
                              },
                              style: TextButton.styleFrom(
                                backgroundColor: colour_available,
                                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: const Text('OK', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('เกิดข้อผิดพลาด: $e'), backgroundColor: Colors.red),
                  );
                }
              },
              child: const Text('Confirm', style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}