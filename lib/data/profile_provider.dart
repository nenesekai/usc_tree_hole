import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:usc_tree_hole/model/profile.dart';

abstract class ProfileProvider {
  Future<Profile> getProfileById(String profileId);
  Stream<Profile> getProfileStreamById(String profileId);
  Future<void> addProfile(Profile profile);
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

  @override
  Stream<Profile> getProfileStreamById(String profileId) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(profileId)
        .snapshots()
        .asyncMap((snapshot) => Profile.fromSnapshot(snapshot));
  }

  @override
  Future<void> addProfile(Profile profile) {
    return FirebaseFirestore.instance.collection('users').doc(profile.id).set({
      'name': profile.name,
      'role': profile.role,
      'uscId': profile.uscId,
    });
  }
}
