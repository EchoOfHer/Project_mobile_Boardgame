// lib/Staff/game_data.dart
class GameItem {
  String gameName;
  String gameGroup;
  String gameStyle;
  int gameId;
  int minP;
  int maxP;
  int gTime;
  String g_link;
  String status;
  String picPath;

  GameItem({
    required this.gameName,
    required this.gameGroup,
    required this.gameId,
    required this.status,
    required this.picPath,
    required this.gameStyle,
    required this.minP,
    required this.maxP,
    required this.gTime,
    required this.g_link,
  });

  Map<String, dynamic> toMap() => {
    'game_name': gameName,
    'game_group': gameGroup,
    'game_id': gameId,
    'game_style': gameStyle,
    'status': status,
    'pic_path': picPath,
    'min_P': minP,
    'max_P': maxP,
    'gamelink': g_link,
    'g_Time': gTime,
  };
}

// Global mutable list – **DO NOT** make it `const`
List<GameItem> gameList = [
  GameItem(
    gameName: 'Castle Panic',
    gameGroup: 'Castle Panic',
    gameStyle: 'Party',
    gameId: 1,
    minP: 2,
    maxP: 3,
    gTime: 5,
    status: 'Borrowing',
    picPath: 'image/Castle_Panic.webp',
    g_link: 'www.google.come',
  ),
  GameItem(
    gameName: 'Castle Panic',
    gameGroup: 'Castle Panic',
    gameStyle: 'Party',
    gameId: 2,
    minP: 2,
    maxP: 3,
    gTime: 5,
    status: 'Available',
    picPath: 'image/Castle_Panic.webp',
    g_link: 'www.game.come',
  ),
  GameItem(
    gameName: 'Champions of Hara',
    gameGroup: 'Champions of Hara',
    gameStyle: 'Buffing',
    gameId: 3,
    minP: 2,
    maxP: 3,
    gTime: 5,
    status: 'Borrowing',
    picPath: 'image/Champions_of_Hara.webp',
    g_link: 'www.game.come',
  ),
  GameItem(
    gameName: 'Defenders of the Wild',
    gameGroup: 'Defenders of the Wild',
    gameStyle: 'Buffing',
    gameId: 4,
    minP: 2,
    maxP: 3,
    gTime: 5,
    status: 'Disabled',
    picPath: 'image/Defenders_of_the_Wild.webp',
    g_link: 'www.game.come',
  ),
  GameItem(
    gameName: 'Roll Player Adventures',
    gameGroup: 'Roll Player Adventures',
    gameStyle: 'Party',
    gameId: 5,
    minP: 2,
    maxP: 3,
    gTime: 5,
    status: 'Available',
    picPath: 'image/Roll_Player_Adventures.webp',
    g_link: 'www.game.come',
  ),
  GameItem(
    gameName: 'The Captain is Dead',
    gameGroup: 'The Captain is Dead',
    gameStyle: 'Party',
    gameId: 6,
    minP: 2,
    maxP: 3,
    gTime: 5,
    status: 'Disabled',
    picPath: 'image/The_Captain_is_Dead.webp',
    g_link: 'www.game.come',
  ),
  GameItem(
    gameName: 'The Grizzled',
    gameGroup: 'The Grizzled',
    gameStyle: 'Family',
    gameId: 7,
    minP: 2,
    maxP: 3,
    gTime: 5,
    status: 'Available',
    picPath: 'image/The_Grizzled.webp',
    g_link: 'www.game.come',
  ),
]..sort((a, b) => a.gameGroup.compareTo(b.gameGroup));
