// lib/Staff_screens/EditGame.dart
import 'package:flutter/material.dart';
import 'package:boardgame_app/Staff_screens/game_input_form.dart';
import 'package:boardgame_app/Staff_screens/staff_main.dart'
    show colour_available, colour_main, colour_available, colour_main;
// import 'staff_dashboard.dart';
import 'game_data.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class EditGame extends StatelessWidget {
  final GameItem game;
  final int groupCount;
  final Function(int newCount) onCountChanged;

  const EditGame({
    super.key,
    required this.game,
    required this.groupCount,
    required this.onCountChanged,
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

                final updated = GameItem(
                  gameId: game.gameId,
                  gameName: data['game_name']?.toString() ?? game.gameName,
                  gameGroup: data['game_name'],
                  gameStyle: data['game_style']?.toString() ?? game.gameStyle,
                  gTime:
                      int.tryParse(data['game_time']?.toString() ?? '0') ?? 0,
                  minP: int.tryParse(data['min_P']?.toString() ?? '0') ?? 0,
                  maxP: int.tryParse(data['max_P']?.toString() ?? '0') ?? 0,
                  picPath: game.picPath,
                  g_link: data['game_how2']?.toString() ?? game.g_link,
                  status: game.status,
                );

                // Show Success Alert Dialog
                await showDialog(
                  context: context,
                  barrierDismissible: false, // Must tap OK to close
                  builder: (context) => AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    icon: Icon(
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
                      'Game "${updated.gameName}" has been updated.',
                      style: const TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    actions: [
                      Center(
                        child: TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(); // Close dialog
                            Navigator.pop(
                              context,
                              updated,
                            ); // Return updated game
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
