import 'package:flutter/material.dart';
import '../data/fakedatabase.dart';
import '../models/post_model.dart';
import 'profile_screen.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  _FeedScreenState createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final postController = TextEditingController();

  void createPost() {
    if (postController.text.trim().isEmpty) return;
    FakeDatabase.posts.insert(
      0,
      PostModel(
        authorEmail: FakeDatabase.currentUser!.email,
        content: postController.text.trim(),
        date: DateTime.now(),
        comments: [],
      ),
    );
    postController.clear();
    setState(() {});
  }

  void deletePost(PostModel post) {
    FakeDatabase.posts.remove(post);
    setState(() {});
  }

  void editPost(PostModel post) {
    final controller = TextEditingController(text: post.content);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Editar publicação"),
        content: TextField(controller: controller),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
          ElevatedButton(
            onPressed: () {
              post.content = controller.text;
              setState(() {});
              Navigator.pop(context);
            },
            child: const Text("Salvar"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final posts = FakeDatabase.posts;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Feed Acadêmico"),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Navigator.push(
              context, MaterialPageRoute(builder: (_) => ProfileScreen())),
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(child: TextField(controller: postController, decoration: const InputDecoration(labelText: "O que você quer compartilhar?"))),
                IconButton(onPressed: createPost, icon: const Icon(Icons.send))
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: posts.length,
              itemBuilder: (_, i) {
                final p = posts[i];
                final user = FakeDatabase.users.firstWhere((u) => u.email == p.authorEmail);
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    title: Text("${user.name} (${user.course})"),
                    subtitle: Text(p.content),
                    trailing: PopupMenuButton(
                      itemBuilder: (_) => [
                        const PopupMenuItem(value: "edit", child: Text("Editar")),
                        const PopupMenuItem(value: "delete", child: Text("Excluir")),
                      ],
                      onSelected: (v) {
                        if (v == "edit") editPost(p);
                        if (v == "delete") deletePost(p);
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
