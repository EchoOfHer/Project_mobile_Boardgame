import 'package:boardgame_app/login/login.dart';
// import 'package:boardgame_app/Student/Chaeckrequest.dart';
import 'package:flutter/material.dart';
import 'Staff_screens/staff_main.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Login(), // start directly in dashboard
    );
  }
}
