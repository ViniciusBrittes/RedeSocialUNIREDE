import '../models/user_model.dart';
import '../models/post_model.dart';

class FakeDatabase {
  static List<UserModel> users = [];
  static List<PostModel> posts = [];
  static UserModel? currentUser;
}
