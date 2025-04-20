import 'package:flutter/material.dart';
import 'screens.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Сапер',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MainMenuScreen(), 
      debugShowCheckedModeBanner: false,
    );
  }
}