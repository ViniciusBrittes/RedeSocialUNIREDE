import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/feed_screen.dart';
import 'screens/profile_screen.dart';

void main() {
  runApp(const RedeSocialApp());
}

class RedeSocialApp extends StatelessWidget {
  const RedeSocialApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RedeSocialPOO',
      theme: ThemeData.dark().copyWith(
        colorScheme: ColorScheme.dark(
          primary: Colors.indigoAccent,
          secondary: Colors.tealAccent,
        ),
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/feed': (context) => const FeedScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
