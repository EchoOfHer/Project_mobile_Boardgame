import 'package:boardgame_app/login/login.dart';
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
    );
  }
}
=======
import 'home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Boardgame App',
      theme: ThemeData(primarySwatch: Colors.orange),

      home: const HomePage(),
    );
  }
}
>>>>>>> feature/request-borrowing
