// lib/Staff_screens/EditGame.dart
import 'package:flutter/material.dart';
import 'package:boardgame_app/Staff/game_input_form.dart';
import 'package:boardgame_app/Staff/staff_main.dart'
    show colour_available, colour_main;
import 'game_data.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
            // ส่วนแสดงรูป + ข้อมูลเดิม
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
                      child: Image.network(
                        game.picPath,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[300],
                            child: const Icon(
                              Icons.broken_image,
                              size: 50,
                              color: Colors.grey,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
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
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Game Style : ',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          game.gameStyle,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Player : ',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          "${game.minP} - ${game.maxP} peoples",
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Time : ',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          "${game.gTime} min",
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // ฟอร์มแก้ไข
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
                'game_count': groupCount.toString(),
              },
              onCountChanged: onCountChanged,
            ),

            const SizedBox(height: 40),

            // ปุ่ม Confirm
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

                // ดึงค่าออกมาอย่างปลอดภัย (แก้ error String? → String)
                final String newName =
                    (data['game_name']?.trim().isNotEmpty == true)
                    ? data['game_name']!.trim()
                    : game.gameName;

                final String newStyle =
                    (data['game_style']?.trim().isNotEmpty == true)
                    ? data['game_style']!.trim()
                    : game.gameStyle;

                final String newLink = data['game_how2']?.trim() ?? game.g_link;

                final updated = GameItem(
                  gameId: game.gameId,
                  gameName: newName,
                  gameGroup: newName, // ใช้ชื่อเดียวกันเป็น group
                  gameStyle: newStyle,
                  gTime: int.tryParse(data['game_time'] ?? '0') ?? game.gTime,
                  minP: int.tryParse(data['min_P'] ?? '0') ?? game.minP,
                  maxP: int.tryParse(data['max_P'] ?? '0') ?? game.maxP,
                  picPath:
                      data['new_image_path'] ??
                      game.picPath, // ถ้ามีรูปใหม่จะได้ path
                  g_link: newLink,
                  status: game.status,
                );

                // แสดง Dialog สำเร็จ
                await showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    icon: const Icon(
                      FontAwesomeIcons.circleCheck,
                      color: colour_available,
                      size: 60,
                    ),
                    title: const Text(
                      'Edit Successful!',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    content: Text(
                      'Game "$newName" has been updated.',
                      style: const TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    actions: [
                      Center(
                        child: TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(); // ปิด dialog
                            Navigator.pop(
                              context,
                              updated,
                            ); // ส่งข้อมูลกลับไป Dashboard
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: colour_available,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 30,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'OK',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
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
}
