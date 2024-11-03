import 'package:usc_tree_hole/model/user.dart';

abstract class UserProvider {
  Future<User> getUserById(String userId);
  void dispose();
}
