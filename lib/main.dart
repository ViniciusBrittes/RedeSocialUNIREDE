import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/feed_screen.dart';
import 'screens/profile_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const RedeSocialApp());
}




class RedeSocialApp extends StatelessWidget {
  const RedeSocialApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RedeSocialPOO',
      theme: ThemeData.dark().copyWith(
        colorScheme: const ColorScheme.dark(
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
