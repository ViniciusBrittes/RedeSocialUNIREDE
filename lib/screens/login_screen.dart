import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../data/fakedatabase.dart';
import 'feed_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  String errorMessage = "";

  void login() {
    final email = emailController.text.trim();
    final pass = passwordController.text.trim();

    if (email.isEmpty || pass.isEmpty) {
      setState(() => errorMessage = "Preencha todos os campos.");
      return;
    }

    UserModel? user;

    try {
      user = FakeDatabase.users.firstWhere(
        (u) => u.email == email && u.password == pass,
      );
    } catch (e) {
      user = null;
    }

    if (user != null) {
      FakeDatabase.currentUser = user;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => FeedScreen()),
      );
    } else {
      setState(() => errorMessage = "Usuário ou senha incorretos.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "RedeSocialPOO",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 40),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: "E-mail",
                    labelStyle: TextStyle(color: Colors.white70),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white24),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: "Senha",
                    labelStyle: TextStyle(color: Colors.white70),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white24),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 16),
                if (errorMessage.isNotEmpty)
                  Text(
                    errorMessage,
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 60, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "Entrar",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => RegisterScreen()),
                    );
                  },
                  child: const Text(
                    "Criar conta",
                    style: TextStyle(color: Colors.blueAccent, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
