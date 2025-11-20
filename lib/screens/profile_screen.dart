import 'package:flutter/material.dart';
import '../data/fakedatabase.dart';


class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FakeDatabase.currentUser!;
    return Scaffold(
      appBar: AppBar(title: const Text("Perfil")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Nome: ${user.name}", style: const TextStyle(fontSize: 18)),
            Text("Idade: ${user.age}"),
            Text("Curso: ${user.course}"),
            Text("Faculdade: ${user.college}"),
            Text("Semestre: ${user.semester}º"),
          ],
        ),
      ),
    );
  }
}
