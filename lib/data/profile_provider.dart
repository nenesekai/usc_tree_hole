import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:usc_tree_hole/model/post.dart';
import 'package:usc_tree_hole/model/profile.dart';

abstract class ProfileProvider {
  Future<Profile> getProfileById(String profileId);
  Stream<Profile> getProfileStreamById(String profileId);
  Future<void> addProfile(Profile profile);
  Future<String?> getAvatarUrl(String profileId);
  Future<void> uploadAvatar(File avatar, String profileId);
  Future<void> updateProfile(String profileId, Map<String, dynamic> args);
  Future<void> subscribe(
      {required String profileId, required PostCategory category});
  Future<void> unsubscribe(
      {required String profileId, required PostCategory category});
}

class FirebaseProfileProvider implements ProfileProvider {
  final _firebaseStorage = FirebaseStorage.instance;

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
  Future<void> updateProfile(
      String profileId, Map<String, dynamic> args) async {
    return FirebaseFirestore.instance.doc('users/$profileId').update(args);
  }

  @override
  Future<void> addProfile(Profile profile) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(profile.id)
        .set(profile.toMap());
  }

  @override
  Future<String?> getAvatarUrl(String profileId) {
    try {
      final ref = _firebaseStorage.ref('avatar/$profileId.jpg');
      return ref.getDownloadURL();
    } on FirebaseException catch (_) {
      return Future.value(null);
    }
  }

  @override
  Future<void> uploadAvatar(File avatar, String profileId) async {
    try {
      final ref = _firebaseStorage.ref('avatar/$profileId.jpg');
      await ref.putFile(avatar);
    } on FirebaseException catch (e) {
      print(e.code);
    }
  }

  @override
  Future<void> subscribe(
      {required profileId, required PostCategory category}) async {
    // TODO
  }

  @override
  Future<void> unsubscribe(
      {required String profileId, required PostCategory category}) async {
    // TODO
  }
}
