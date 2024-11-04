import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:usc_tree_hole/model/profile.dart';

abstract class ProfileProvider {
  Future<Profile> getProfileById(String profileId);
}

class FirebaseProfileProvider implements ProfileProvider {
  @override
  Future<Profile> getProfileById(String profileId) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(profileId)
        .get()
        .then((DocumentSnapshot doc) => Profile.fromSnapshot(doc));
  }
}
