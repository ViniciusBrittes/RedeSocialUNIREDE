import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(ForumApp());
}

class ForumApp extends StatelessWidget {
  const ForumApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RedeSocialPOO',
      theme: ThemeData.dark(), // Tema escuro conforme solicitado
      home: const LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
