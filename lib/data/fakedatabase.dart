import '../models/user_model.dart';
import '../models/post_model.dart';
import 'package:uuid/uuid.dart';

class FakeDatabase {
  static final List<UserModel> users = [];
  static final List<PostModel> posts = [];
  static UserModel? currentUser;

  // helper to create unique ids for posts
  static final _uuid = Uuid();

  static String newPostId() => _uuid.v4();

  // find user by email
  static UserModel? findUser(String email) {
    try {
      return users.firstWhere((u) => u.email == email);
    } catch (_) {
      return null;
    }
  }

  static List<PostModel> postsByCourse(String course) {
    return posts.where((p) => p.courseTag == course).toList();
  }

  static List<UserModel> searchUsers(String term) {
    final q = term.toLowerCase();
    return users.where((u) {
      return u.name.toLowerCase().contains(q) ||
          u.university.toLowerCase().contains(q) ||
          u.course.toLowerCase().contains(q);
    }).toList();
  }
}
