import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  final _university = TextEditingController();
  final _course = TextEditingController();

  String _error = '';

  Future<void> _register() async {
    final name = _name.text.trim();
    final email = _email.text.trim();
    final pass = _pass.text.trim();
    final university = _university.text.trim();
    final course = _course.text.trim();

    if (name.isEmpty || email.isEmpty || pass.isEmpty) {
      setState(() => _error = 'Preencha nome, email e senha.');
      return;
    }

    try {
      // 1️⃣ Criar usuário no Firebase Auth
      final cred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: pass);

      final uid = cred.user!.uid;

      // 2️⃣ Criar documento do usuário no Firestore
      await FirebaseFirestore.instance.collection("users").doc(uid).set({
        "name": name,
        "email": email,
        "university": university,
        "course": course,
        "createdAt": DateTime.now(),
      });

      // 3️⃣ Redirecionar
      Navigator.pushReplacementNamed(context, '/feed');
    } on FirebaseAuthException catch (e) {
      setState(() => _error = e.message ?? "Erro ao registrar.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastrar')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              children: [
                TextField(controller: _name, decoration: const InputDecoration(labelText: 'Nome')),
                const SizedBox(height: 8),
                TextField(controller: _university, decoration: const InputDecoration(labelText: 'Universidade')),
                const SizedBox(height: 8),
                TextField(controller: _course, decoration: const InputDecoration(labelText: 'Curso')),
                const SizedBox(height: 8),
                TextField(controller: _email, decoration: const InputDecoration(labelText: 'E-mail')),
                const SizedBox(height: 8),
                TextField(controller: _pass, obscureText: true, decoration: const InputDecoration(labelText: 'Senha')),
                const SizedBox(height: 12),
                if (_error.isNotEmpty) Text(_error, style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _register,
                  child: const Text('Registrar e entrar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
