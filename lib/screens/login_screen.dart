import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _pass = TextEditingController();
  String _error = '';

  Future<void> _login() async {
    final email = _email.text.trim();
    final pass = _pass.text.trim();

    if (email.isEmpty || pass.isEmpty) {
      setState(() => _error = 'Preencha e-mail e senha.');
      return;
    }

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: pass,
      );

      // Se funcionou, vai pro feed
      Navigator.pushReplacementNamed(context, '/feed');

    } on FirebaseAuthException catch (e) {
      setState(() {
        if (e.code == 'user-not-found') {
          _error = 'Usuário não encontrado.';
        } else if (e.code == 'wrong-password') {
          _error = 'Senha incorreta.';
        } else {
          _error = 'Erro: ${e.message}';
        }
      });
    }
  }

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              children: [
                const Text('RedeSocialPOO',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),

                TextField(
                  controller: _email,
                  decoration: const InputDecoration(labelText: 'E-mail'),
                ),
                const SizedBox(height: 12),

                TextField(
                  controller: _pass,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Senha'),
                ),

                const SizedBox(height: 12),
                if (_error.isNotEmpty)
                  Text(_error, style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 12),

                ElevatedButton(onPressed: _login, child: const Text('Entrar')),
                const SizedBox(height: 8),

                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/register'),
                  child: const Text('Criar conta'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
