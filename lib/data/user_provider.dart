import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:usc_tree_hole/model/user.dart';

abstract class UserProvider {
  Future<User> getUserById(String userId);
}

class FirebaseUserProvider implements UserProvider {
  @override
  Future<User> getUserById(String userId) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get()
        .then((DocumentSnapshot doc) => User.fromSnapshot(doc));
  }
}
