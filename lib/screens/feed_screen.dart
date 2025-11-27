// lib/screens/feed_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// Removemos import dart:io e open_file pois não estavam sendo usados na lógica principal
// Se precisar deles para outra coisa, pode manter.

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});
  
  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final _contentCtrl = TextEditingController();
  final _hashtagCtrl = TextEditingController();
  String _courseFilter = 'Todos';
  String _searchUser = '';

  final postsRef = FirebaseFirestore.instance.collection('posts');
  final usersRef = FirebaseFirestore.instance.collection('users');

  User? get _currentUser => FirebaseAuth.instance.currentUser;

  // Create post: text + hashtags
  Future<void> _createPost() async {
    final user = _currentUser;
    if (user == null) return;
    final content = _contentCtrl.text.trim();
    if (content.isEmpty) return;

    final hashtags = _hashtagCtrl.text.trim().isEmpty
        ? <String>[]
        : _hashtagCtrl.text.trim().split(' ').where((s) => s.startsWith('#')).toList();

    // try to fetch user's profile data (name, course)
    final userDoc = await usersRef.doc(user.uid).get();
    final userMap = userDoc.data() ?? {};
    final authorName = (userMap['name'] as String?) ?? user.email?.split('@').first ?? 'Anon';
    final authorCourse = (userMap['course'] as String?) ?? 'Desconhecido';

    final doc = postsRef.doc(); // auto id
    await doc.set({
      'id': doc.id,
      'authorId': user.uid,
      'authorEmail': user.email,
      'authorName': authorName,
      'authorCourse': authorCourse,
      'content': content,
      'hashtags': hashtags,
      'courseTag': authorCourse,
      'likes': <String>[],
      'comments': <Map<String, dynamic>>[],
      'createdAt': FieldValue.serverTimestamp(),
    });

    _contentCtrl.clear();
    _hashtagCtrl.clear();
    setState(() {}); // refresh UI
  }

  // Toggle like using a transaction (atomic). Prevent self-like.
  Future<void> _toggleLike(DocumentSnapshot postSnap) async {
    final uid = _currentUser?.uid;
    if (uid == null) return;

    final postData = postSnap.data() as Map<String, dynamic>;
    final authorId = postData['authorId'] as String?;
    if (authorId != null && authorId == uid) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Você não pode curtir sua própria postagem.')));
      return;
    }

    final docRef = postsRef.doc(postSnap.id);

    await FirebaseFirestore.instance.runTransaction((tx) async {
      final freshSnap = await tx.get(docRef);
      final fresh = freshSnap.data() ?? {};
      final List likes = List.from(fresh['likes'] ?? []);
      if (likes.contains(uid)) {
        likes.remove(uid);
      } else {
        likes.add(uid);
      }
      tx.update(docRef, {'likes': likes});
    });
  }

  // Add comment (push to comments array)
  Future<void> _addComment(DocumentSnapshot postSnap) async {
    final uid = _currentUser?.uid;
    if (uid == null) return;
    
    // Busca dados atualizados do usuário ou usa defaults
    final userDoc = await usersRef.doc(uid).get();
    final userData = userDoc.data();
    final name = (userData?['name'] as String?) ?? _currentUser!.email!.split('@').first;

    final ctrl = TextEditingController();
    
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Comentar'),
        content: TextField(controller: ctrl, decoration: const InputDecoration(hintText: 'Escreva seu comentário')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              final text = ctrl.text.trim();
              if (text.isNotEmpty) {
                final docRef = postsRef.doc(postSnap.id);
                final comment = {
                  'authorId': uid,
                  'authorName': name,
                  'text': text,
                  // CORREÇÃO AQUI: Timestamp.now() em vez de FieldValue.serverTimestamp()
                  'createdAt': Timestamp.now(),
                };
                await docRef.update({
                  'comments': FieldValue.arrayUnion([comment])
                });
              }
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Comentar'),
          )
        ],
      ),
    );
  }

  // Navigate to profile
  void _openProfile(String uid) {
    Navigator.pushNamed(context, '/profile', arguments: uid);
  }

  // Helper to format timestamp safely
  String _formatTimestamp(Timestamp? t) {
    if (t == null) return '';
    final dt = t.toDate();
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2,'0')}:${dt.minute.toString().padLeft(2,'0')}';
  }

  @override
  Widget build(BuildContext context) {
    final currentUid = _currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Feed Acadêmico'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              if (currentUid == null) {
                Navigator.pushReplacementNamed(context, '/login');
              } else {
                _openProfile(currentUid);
              }
            },
            tooltip: 'Perfil',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // Controls: filter + search
            Row(
              children: [
                DropdownButton<String>(
                  value: _courseFilter,
                  items: const ['Todos'].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
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

            // Create post area
            Card(
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
                        Expanded(
                          child: TextField(controller: _hashtagCtrl, decoration: const InputDecoration(hintText: '#tag1 #tag2 (separe por espaço)')),
                        ),
                        IconButton(onPressed: _createPost, icon: const Icon(Icons.send)),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Posts list - streaming
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: postsRef.orderBy('createdAt', descending: true).snapshots(),
                builder: (context, snap) {
                  if (snap.hasError) return Center(child: Text('Erro: ${snap.error}'));
                  if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                  final docs = snap.data!.docs;

                  final filtered = docs.where((d) {
                    final data = d.data() as Map<String, dynamic>;
                    final authorName = (data['authorName'] as String?) ?? '';
                    final authorEmail = (data['authorEmail'] as String?) ?? '';
                    final matchUser = _searchUser.isEmpty || authorName.toLowerCase().contains(_searchUser.toLowerCase()) || authorEmail.toLowerCase().contains(_searchUser.toLowerCase());
                    final matchCourse = (_courseFilter == 'Todos') || (data['courseTag'] == _courseFilter);
                    return matchUser && matchCourse;
                  }).toList();

                  if (filtered.isEmpty) return const Center(child: Text('Nenhuma publicação ainda.'));

                  return ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, i) {
                      final postSnap = filtered[i];
                      final data = postSnap.data() as Map<String, dynamic>;
                      final likes = List<String>.from(data['likes'] ?? []);
                      final comments = List<Map<String, dynamic>>.from(data['comments'] ?? []);
                      final createdAt = data['createdAt'] as Timestamp?;
                      final authorName = data['authorName'] ?? 'Anon';
                      final authorCourse = data['authorCourse'] ?? '';

                      final alreadyLiked = currentUid != null && likes.contains(currentUid);

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(child: GestureDetector(
                                    onTap: () {
                                      final authorId = data['authorId'] as String?;
                                      if (authorId != null) _openProfile(authorId);
                                    },
                                    child: Text('$authorName • $authorCourse', style: const TextStyle(fontWeight: FontWeight.bold)),
                                  )),
                                  Text(_formatTimestamp(createdAt), style: const TextStyle(fontSize: 11)),
                                  PopupMenuButton(
                                    onSelected: (v) async {
                                      final uid = _currentUser?.uid;
                                      if (v == 'edit' && uid != null && uid == data['authorId']) {
                                        final ctrl = TextEditingController(text: data['content'] ?? '');
                                        showDialog(context: context, builder: (_) => AlertDialog(
                                          title: const Text('Editar postagem'),
                                          content: TextField(controller: ctrl),
                                          actions: [
                                            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
                                            ElevatedButton(onPressed: () async {
                                              await postsRef.doc(postSnap.id).update({'content': ctrl.text});
                                              Navigator.pop(context);
                                            }, child: const Text('Salvar')),
                                          ],
                                        ));
                                      } else if (v == 'delete' && _currentUser?.uid == data['authorId']) {
                                        final ok = await showDialog<bool>(context: context, builder: (_) => AlertDialog(
                                          title: const Text('Confirmar'),
                                          content: const Text('Excluir esta postagem?'),
                                          actions: [
                                            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Não')),
                                            ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Sim')),
                                          ],
                                        ));
                                        if (ok ?? false) await postsRef.doc(postSnap.id).delete();
                                      }
                                    },
                                    itemBuilder: (_) => const [
                                      PopupMenuItem(value: 'edit', child: Text('Editar')),
                                      PopupMenuItem(value: 'delete', child: Text('Excluir')),
                                    ],
                                  )
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(data['content'] ?? ''),
                              const SizedBox(height: 8),
                              Wrap(spacing: 8, children: (data['hashtags'] as List<dynamic>? ?? []).map((h) => Chip(label: Text(h.toString()))).toList()),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: () => _toggleLike(postSnap),
                                    icon: Icon(alreadyLiked ? Icons.thumb_up : Icons.thumb_up_outlined),
                                  ),
                                  Text('${likes.length}'),
                                  const SizedBox(width: 12),
                                  IconButton(onPressed: () => _addComment(postSnap), icon: const Icon(Icons.comment)),
                                  Text('${comments.length}'),
                                ],
                              ),
                              if (comments.isNotEmpty) const Divider(),
                              for (final c in comments)
                                ListTile(
                                  dense: true,
                                  title: Text(c['authorName'] ?? 'Anon', style: const TextStyle(fontWeight: FontWeight.w600)),
                                  subtitle: Text(c['text'] ?? ''),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
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