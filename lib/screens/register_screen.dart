import 'package:flutter/material.dart';
import '../data/fakedatabase.dart';
import '../models/user_model.dart';

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

  void _register() {
    final name = _name.text.trim();
    final email = _email.text.trim();
    final pass = _pass.text.trim();
    final university = _university.text.trim();
    final course = _course.text.trim();

    if (name.isEmpty || email.isEmpty || pass.isEmpty) {
      setState(() => _error = 'Preencha nome, email e senha.');
      return;
    }

    if (FakeDatabase.findUser(email) != null) {
      setState(() => _error = 'E-mail já cadastrado.');
      return;
    }

    final user = UserModel(
      email: email,
      password: pass,
      name: name,
      university: university,
      course: course,
    );

    FakeDatabase.users.add(user);
    // auto login
    FakeDatabase.currentUser = user;
    Navigator.pushReplacementNamed(context, '/feed');
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
                ElevatedButton(onPressed: _register, child: const Text('Registrar e entrar')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
