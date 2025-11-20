import 'package:flutter/material.dart';
import '../data/fakedatabase.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FakeDatabase.currentUser;
    if (user == null) {
      // safety: if no user, go back to login
      Future.microtask(() => Navigator.pushReplacementNamed(context, '/login'));
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        actions: [
          IconButton(
            tooltip: 'Sair',
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Sair'),
                  content: const Text('Deseja realmente sair da conta?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
                    ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Sair')),
                  ],
                ),
              );

              if (confirmed == true) {
                FakeDatabase.currentUser = null;
                Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nome: ${user.name}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text('E-mail: ${user.email}'),
            const SizedBox(height: 8),
            Text('Universidade: ${user.university}'),
            const SizedBox(height: 8),
            Text('Curso: ${user.course}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // opção para ver posts do usuário
                final userPosts = FakeDatabase.posts.where((p) => p.authorEmail == user.email).toList();
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Minhas publicações'),
                    content: SizedBox(
                      width: double.maxFinite,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: userPosts.length,
                        itemBuilder: (_, i) => ListTile(title: Text(userPosts[i].content)),
                      ),
                    ),
                    actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Fechar'))],
                  ),
                );
              },
              child: const Text('Ver minhas postagens'),
            ),
          ],
        ),
      ),
    );
  }
}
