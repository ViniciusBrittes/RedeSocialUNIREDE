class PostModel {
  String id; // unique id
  String authorEmail;
  String authorName;
  String authorCourse;
  String content;
  String? imagePath; // local path to image (if any)
  String? filePath; // local path to PDF (if any)
  List<String> hashtags;
  String courseTag; // course of the author (for filtering)
  int likes;
  List<Comment> comments;
  DateTime createdAt;

  PostModel({
    required this.id,
    required this.authorEmail,
    required this.authorName,
    required this.authorCourse,
    required this.content,
    this.imagePath,
    this.filePath,
    required this.hashtags,
    required this.courseTag,
    this.likes = 0,
    List<Comment>? comments,
    DateTime? createdAt,
  })  : comments = comments ?? [],
        createdAt = createdAt ?? DateTime.now();
}

class Comment {
  final String authorName;
  final String text;
  final DateTime createdAt;

  Comment({
    required this.authorName,
    required this.text,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}
