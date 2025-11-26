import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final uid = ModalRoute.of(context)!.settings.arguments as String?;

    if (uid == null) {
      return const Scaffold(
        body: Center(child: Text("Usuário inválido.")),
      );
    }

    final userDocRef =
        FirebaseFirestore.instance.collection('users').doc(uid);

    return FutureBuilder<DocumentSnapshot>(
      future: userDocRef.get(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }

        if (!snap.hasData || !snap.data!.exists) {
          return const Scaffold(
              body: Center(child: Text("Usuário não encontrado.")));
        }

        final data = snap.data!.data() as Map<String, dynamic>;
        final name = data['name'] ?? 'Sem nome';
        final email = data['email'] ?? 'Sem email';
        final university = data['university'] ?? 'Não informado';
        final course = data['course'] ?? 'Não informado';

        return Scaffold(
          appBar: AppBar(
            title: const Text('Perfil'),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushNamedAndRemoveUntil(
                      context, '/login', (_) => false);
                },
              )
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Nome: $name', style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 8),
                Text('E-mail: $email'),
                const SizedBox(height: 8),
                Text('Universidade: $university'),
                const SizedBox(height: 8),
                Text('Curso: $course'),
              ],
            ),
          ),
        );
      },
    );
  }
}
