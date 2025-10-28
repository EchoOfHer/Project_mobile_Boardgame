import 'package:boardgame_app/login/login.dart';
// import 'package:boardgame_app/Student/Chaeckrequest.dart';
import 'package:flutter/material.dart';
<<<<<<< HEAD

void main() {
  runApp(MyApp());
}

// นี่คือ Class main ที่คุณต้องการ
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Login()
      // home: Checkrequest()
    );
  }
=======
// import 'HistoryStaffPage.dart';
// import 'HistoryStudentPage.dart';
import 'HistoryLanderPage.dart';

void main() {
  runApp(
    const MaterialApp(
      home: HistoryLanderPage(),
      debugShowCheckedModeBanner: false,
    ),
  );
>>>>>>> feature/borrow-history
}
