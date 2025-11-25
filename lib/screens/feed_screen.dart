import 'dart:io';
import 'package:flutter/material.dart';
//import 'package:file_picker/file_picker.dart';
import 'package:open_file/open_file.dart';
import 'package:rede_social_poo/data/fakedatabase.dart';
import '../models/post_model.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final _contentCtrl = TextEditingController();
  String? _selectedImagePath;
  String? _selectedFilePath;
  final _hashtagCtrl = TextEditingController();

  String _courseFilter = 'Todos';
  String _searchUser = '';
/*
  // helper: pick image or pdf
  Future<void> _pickImage() async {
    //final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedImagePath = result.files.single.path!;
      });
    }
  }

  Future<void> _pickPdf() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedFilePath = result.files.single.path!;
      });
    }
  }*/

  void _createPost() {
    final user = FakeDatabase.currentUser;
    if (user == null) return;
    final content = _contentCtrl.text.trim();
    if (content.isEmpty && _selectedImagePath == null && _selectedFilePath == null) return;

    final hashtags = _hashtagCtrl.text.trim().isEmpty
        ? <String>[]
        : _hashtagCtrl.text.trim().split(' ').where((s) => s.startsWith('#')).toList();

    final post = PostModel(
      id: FakeDatabase.newPostId(),
      authorEmail: user.email,
      authorName: user.name,
      authorCourse: user.course,
      content: content,
      imagePath: _selectedImagePath,
      filePath: _selectedFilePath,
      hashtags: hashtags,
      courseTag: user.course,
    );

    setState(() {
      FakeDatabase.posts.insert(0, post);
      // clear inputs
      _contentCtrl.clear();
      _hashtagCtrl.clear();
      _selectedImagePath = null;
      _selectedFilePath = null;
    });
  }

  void _deletePost(PostModel post) {
    setState(() => FakeDatabase.posts.removeWhere((p) => p.id == post.id));
  }

  void _editPost(PostModel post) {
    final ctrl = TextEditingController(text: post.content);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Editar postagem'),
        content: TextField(controller: ctrl),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              setState(() {
                post.content = ctrl.text;
              });
              Navigator.pop(context);
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  void _toggleLike(PostModel post) {
    setState(() {
      post.likes = post.likes + 1;
    });
  }

  void _addComment(PostModel post) {
    final commentCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Comentar'),
        content: TextField(controller: commentCtrl, decoration: const InputDecoration(hintText: 'Escreva seu comentário')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              final text = commentCtrl.text.trim();
              if (text.isNotEmpty) {
                setState(() {
                  post.comments.add(Comment(authorName: FakeDatabase.currentUser?.name ?? 'Anon', text: text));
                });
              }
              Navigator.pop(context);
            },
            child: const Text('Comentar'),
          )
        ],
      ),
    );
  }

  List<PostModel> get _filteredPosts {
    var list = FakeDatabase.posts;
    if (_courseFilter != 'Todos') {
      list = list.where((p) => p.courseTag == _courseFilter).toList();
    }
    if (_searchUser.isNotEmpty) {
      final q = _searchUser.toLowerCase();
      list = list.where((p) => p.authorName.toLowerCase().contains(q) || p.authorEmail.toLowerCase().contains(q)).toList();
    }
    return list;
  }

  List<String> get _allCourses {
    final courses = FakeDatabase.users.map((u) => u.course).toSet().toList();
    courses.sort();
    return ['Todos', ...courses];
  }

  @override
  Widget build(BuildContext context) {
    final current = FakeDatabase.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feed Acadêmico'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Navigator.pushNamed(context, '/profile'),
            tooltip: 'Perfil',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // controls: filter + search
            Row(
              children: [
                DropdownButton<String>(
                  value: _courseFilter,
                  items: _allCourses.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (v) => setState(() => _courseFilter = v ?? 'Todos'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Buscar por autor / e-mail'),
                    onChanged: (v) => setState(() => _searchUser = v),
                  ),
                )
              ],
            ),
            const SizedBox(height: 8),

            // create post area
            Card(
              color: Theme.of(context).cardColor,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    TextField(
                      controller: _contentCtrl,
                      maxLines: 3,
                      decoration: const InputDecoration(hintText: 'O que você quer compartilhar?'),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: null,
                          icon: const Icon(Icons.image),
                          label: const Text('Imagem'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: null,
                          icon: const Icon(Icons.picture_as_pdf),
                          label: const Text('PDF'),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(controller: _hashtagCtrl, decoration: const InputDecoration(hintText: '#tag1 #tag2 (separe por espaço)')),
                        ),
                        IconButton(onPressed: _createPost, icon: const Icon(Icons.send)),
                      ],
                    ),
                    if (_selectedImagePath != null) Padding(
                      padding: const EdgeInsets.only(top:8.0),
                      child: Row(
                        children: [
                          const Icon(Icons.image, size: 18),
                          const SizedBox(width: 8),
                          Expanded(child: Text(_selectedImagePath!)),
                        ],
                      ),
                    ),
                    if (_selectedFilePath != null) Padding(
                      padding: const EdgeInsets.only(top:8.0),
                      child: Row(
                        children: [
                          const Icon(Icons.attach_file, size: 18),
                          const SizedBox(width: 8),
                          Expanded(child: Text(_selectedFilePath!)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 8),

            // posts list
            Expanded(
              child: _filteredPosts.isEmpty
                  ? const Center(child: Text('Nenhuma publicação ainda.'))
                  : ListView.builder(
                      itemCount: _filteredPosts.length,
                      itemBuilder: (_, i) {
                        final post = _filteredPosts[i];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(child: Text('${post.authorName} • ${post.authorCourse}', style: const TextStyle(fontWeight: FontWeight.bold))),
                                    Text('${post.createdAt.toLocal()}'.split('.').first, style: const TextStyle(fontSize: 11)),
                                    PopupMenuButton(
                                      onSelected: (v) {
                                        if (v == 'edit' && FakeDatabase.currentUser?.email == post.authorEmail) {
                                          _editPost(post);
                                        } else if (v == 'delete' && FakeDatabase.currentUser?.email == post.authorEmail) {
                                          _deletePost(post);
                                        }
                                      },
                                      itemBuilder: (_) => [
                                        const PopupMenuItem(value: 'edit', child: Text('Editar')),
                                        const PopupMenuItem(value: 'delete', child: Text('Excluir')),
                                      ],
                                    )
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(post.content),
                                const SizedBox(height: 8),
                                if (post.imagePath != null)
                                  GestureDetector(
                                    onTap: () => OpenFile.open(post.imagePath),
                                    child: Image.file(File(post.imagePath!), height: 180, fit: BoxFit.cover),
                                  ),
                                if (post.filePath != null) Row(
                                  children: [
                                    ElevatedButton.icon(
                                      onPressed: () => OpenFile.open(post.filePath),
                                      icon: const Icon(Icons.picture_as_pdf),
                                      label: const Text('Abrir PDF'),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(child: Text(post.filePath!)),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 8,
                                  children: post.hashtags.map((h) => Chip(label: Text(h))).toList(),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    IconButton(onPressed: () => _toggleLike(post), icon: const Icon(Icons.thumb_up)),
                                    Text('${post.likes}'),
                                    const SizedBox(width: 12),
                                    IconButton(onPressed: () => _addComment(post), icon: const Icon(Icons.comment)),
                                    Text('${post.comments.length}'),
                                  ],
                                ),
                                if (post.comments.isNotEmpty) Divider(),
                                for (final c in post.comments)
                                  ListTile(
                                    dense: true,
                                    title: Text(c.authorName, style: const TextStyle(fontWeight: FontWeight.w600)),
                                    subtitle: Text(c.text),
                                    trailing: Text('${c.createdAt.hour}:${c.createdAt.minute.toString().padLeft(2,'0')}', style: const TextStyle(fontSize: 11)),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
