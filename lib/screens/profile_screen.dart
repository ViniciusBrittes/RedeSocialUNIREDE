// lib/screens/profile_screen.dart
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
        body: Center(child: Text("ID de usuário inválido.")),
      );
    }

    final userDocRef = FirebaseFirestore.instance.collection('users').doc(uid);

    return FutureBuilder<DocumentSnapshot>(
      future: userDocRef.get(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        // CORREÇÃO: Tratamento para usuários sem documento no banco
        Map<String, dynamic>? data;
        if (snap.hasData && snap.data!.exists) {
          data = snap.data!.data() as Map<String, dynamic>;
        }

        // Tenta pegar dados do Firestore, senão tenta do Auth, senão usa padrão
        final authUser = FirebaseAuth.instance.currentUser;
        
        // Se estamos vendo nosso próprio perfil e não tem dados no banco, usa os dados do Auth
        final isMe = authUser?.uid == uid;
        
        final name = data?['name'] ?? (isMe ? authUser?.displayName : null) ?? 'Nome não disponível';
        final email = data?['email'] ?? (isMe ? authUser?.email : null) ?? 'Email não disponível';
        final university = data?['university'] ?? 'Não informado';
        final course = data?['course'] ?? 'Não informado';

        return Scaffold(
          appBar: AppBar(
            title: const Text('Perfil'),
            actions: [
              // Só mostra botão de sair se for o próprio usuário vendo o perfil
              if (isMe)
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
                  },
                )
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (data == null) 
                  const Padding(
                    padding: EdgeInsets.only(bottom: 20),
                    child: Text(
                      "Aviso: Perfil incompleto no banco de dados.", 
                      style: TextStyle(color: Colors.orange),
                    ),
                  ),
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