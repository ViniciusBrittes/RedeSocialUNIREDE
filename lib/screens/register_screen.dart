import 'package:flutter/material.dart';
import '../data/fakedatabase.dart';
import '../models/user_model.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final formKey = GlobalKey<FormState>();
  final user = UserModel(
    email: '', password: '', name: '', age: 0, course: '', college: '', semester: 0,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Cadastrar")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: formKey,
          child: ListView(
            children: [
              TextFormField(decoration: const InputDecoration(labelText: "Nome"), onChanged: (v) => user.name = v),
              TextFormField(decoration: const InputDecoration(labelText: "Idade"), keyboardType: TextInputType.number, onChanged: (v) => user.age = int.tryParse(v) ?? 0),
              TextFormField(decoration: const InputDecoration(labelText: "Curso"), onChanged: (v) => user.course = v),
              TextFormField(decoration: const InputDecoration(labelText: "Faculdade"), onChanged: (v) => user.college = v),
              TextFormField(decoration: const InputDecoration(labelText: "Semestre"), keyboardType: TextInputType.number, onChanged: (v) => user.semester = int.tryParse(v) ?? 0),
              TextFormField(decoration: const InputDecoration(labelText: "E-mail"), onChanged: (v) => user.email = v),
              TextFormField(decoration: const InputDecoration(labelText: "Senha"), obscureText: true, onChanged: (v) => user.password = v),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  FakeDatabase.users.add(user);
                  Navigator.pop(context);
                },
                child: const Text("Cadastrar"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
