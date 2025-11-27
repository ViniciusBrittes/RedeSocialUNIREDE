import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _pass = TextEditingController();
  String _error = '';

  Future<void> _loginEmail() async {
    final email = _email.text.trim();
    final pass = _pass.text.trim();

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: pass,
      );
      Navigator.pushReplacementNamed(context, '/feed');
    } on FirebaseAuthException catch (e) {
      setState(() => _error = e.message ?? 'Erro ao entrar.');
    }
  }

  Future<void> _loginWithGoogle() async {
  try {
    if (kIsWeb) {
      // 🔥 Login Google para WEB
      final provider = GoogleAuthProvider();
      await FirebaseAuth.instance.signInWithPopup(provider);
    } else {
      // 🔥 Login Google para ANDROID / iOS
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
    }

    Navigator.pushReplacementNamed(context, '/feed');
  } catch (e) {
    setState(() => _error = "Erro ao entrar com Google: $e");
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              children: [
                TextField(
                    controller: _email,
                    decoration: const InputDecoration(labelText: 'E-mail')),
                const SizedBox(height: 8),
                TextField(
                    controller: _pass,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Senha')),
                const SizedBox(height: 12),
                if (_error.isNotEmpty)
                  Text(_error, style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 12),

                /// Botão Login normal
                ElevatedButton(
                  onPressed: _loginEmail,
                  child: const Text('Entrar'),
                ),

                const SizedBox(height: 20),

                /// Botão Login com Google
                ElevatedButton(
                  onPressed: _loginWithGoogle,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      
                      const SizedBox(width: 12),
                      const Text("Entrar com Google"),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/register'),
                  child: const Text("Criar conta"),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}