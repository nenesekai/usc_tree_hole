import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:usc_tree_hole/model/profile.dart';

abstract class ProfileProvider {
  Future<Profile?> getProfileById(String profileId);
  Stream<Profile> getProfileStreamById(String profileId);
  Future<void> addProfile(Profile profile);
  Future<String?> getAvatarUrl(String profileId);
  Future<void> uploadAvatar(File avatar, String profileId);
  Future<void> updateProfile(String profileId, Map<String, dynamic> args);
  Future<void> deleteProfile(String profileId);
}

class FirebaseProfileProvider implements ProfileProvider {
  late final FirebaseStorage _firebaseStorage;
  late final FirebaseFirestore _firebaseFirestore;

  FirebaseProfileProvider(
      [FirebaseFirestore? firebaseFirestore, FirebaseStorage? firebaseStorage])
      : _firebaseStorage = firebaseStorage ?? FirebaseStorage.instance,
        _firebaseFirestore = firebaseFirestore ?? FirebaseFirestore.instance;

  @override
  Future<void> deleteProfile(String profileId) {
    return _firebaseFirestore.collection('users').doc(profileId).delete();
  }

  @override
  Future<Profile?> getProfileById(String profileId) async {
    final doc =
        await _firebaseFirestore.collection('users').doc(profileId).get();
    if (doc.data() == null) return null;
    return Profile.fromSnapshot(doc);
  }

  @override
  Stream<Profile> getProfileStreamById(String profileId) {
    return _firebaseFirestore
        .collection('users')
        .doc(profileId)
        .snapshots()
        .asyncMap((snapshot) => Profile.fromSnapshot(snapshot));
  }

  @override
  Future<void> updateProfile(
      String profileId, Map<String, dynamic> args) async {
    return _firebaseFirestore.doc('users/$profileId').update(args);
  }

  @override
  Future<void> addProfile(Profile profile) {
    return _firebaseFirestore
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
      log(e.code);
    }
  }
}
