class PostModel {
  String authorEmail;
  String content;
  DateTime date;
  List<String> comments;

  PostModel({
    required this.authorEmail,
    required this.content,
    required this.date,
    required this.comments,
  });
}
