import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:usc_tree_hole/data/notification_provider.dart';
import 'package:usc_tree_hole/data/post_provider.dart';
import 'package:usc_tree_hole/data/profile_provider.dart';
import 'package:usc_tree_hole/data/reply_provider.dart';
import 'package:usc_tree_hole/model/notification.dart';
import 'package:usc_tree_hole/model/post.dart';
import 'package:usc_tree_hole/model/profile.dart';
import 'package:usc_tree_hole/model/reply.dart';

void main() {
  late FirebaseFirestore firebaseFirestore;
  late FirebaseStorage firebaseStorage;
  late PostProvider postProvider;
  late ProfileProvider profileProvider;
  late NotificationProvider notificationProvider;
  late ReplyProvider replyProvider;

  var testProfile = Profile(
      id: "test_profile",
      name: "Test Profile",
      role: "Undergraduate",
      uscId: "114514");
  var testPost = Post(
      id: "",
      title: "test post title",
      content: "test post content",
      category: "Academic",
      authorId: testProfile.id);
  var testNotification = Notification(
      id: "",
      content: "test notification",
      senderId: testProfile.id,
      createTime: Timestamp.now());

  setUpAll(() {
    firebaseFirestore = FakeFirebaseFirestore();
    firebaseStorage = MockFirebaseStorage();
    profileProvider =
        FirebaseProfileProvider(firebaseFirestore, firebaseStorage);
    postProvider = FirebasePostProvider(firebaseFirestore);
    notificationProvider =
        FirebaseNotificationProvider(testProfile.id, firebaseFirestore);
  });

  group("Test ProfileProvider", () {
    test("should be able to create account", () async {
      expectLater(profileProvider.addProfile(testProfile), completes);
    });

    test("should be able to find account by id", () async {
      profileProvider
          .getProfileById(testProfile.id)
          .then(expectAsync1((profile) => expect(profile?.id, testProfile.id)));
    });

    test("should be able to get profile stream by id", () async {
      profileProvider
          .getProfileStreamById(testProfile.id)
          .first
          .then(expectAsync1((profile) => expect(profile.id, testProfile.id)));
    });

    test("should be able to modify profile", () async {
      final String newName = "New Name";
      final newProfile = testProfile.copyWith(name: newName);
      expectLater(profileProvider.addProfile(newProfile), completes);
      profileProvider
          .getProfileById(testProfile.id)
          .then(expectAsync1((profile) {
        expect(profile?.name, newName);
      }));
    });

    test("should be able to delete a profile", () async {
      expectLater(profileProvider.deleteProfile(testProfile.id), completes);
      expect(await profileProvider.getProfileById(testProfile.id), null);
    });
  });

  group("Test PostProvider", () {
    setUp(() async {
      await profileProvider.addProfile(testProfile);
    });

    tearDown(() async {
      await profileProvider.deleteProfile(testProfile.id);
    });

    test('should be able to create a post', () async {
      expectLater(() async {
        String postId = await postProvider.addPost(testPost);
        testPost = testPost.copyWith(id: postId);
      }(), completes);
    });

    test("should be able to find the post by id", () async {
      final post = await postProvider.getPostById(testPost.id);
      expect(post, isNotNull);
      expect(post?.id, testPost.id);
    });

    test('should be able to find this post in post list', () async {
      final posts = await postProvider.getPostsStream(null).first;
      expect(posts.firstWhere((post) => testPost.id == post.id), isNotNull);
    });

    test('should be able to find this post in posts stream by author id',
        () async {
      final posts =
          await postProvider.getPostsStreamByAuthorId(testPost.authorId).first;
      expect(posts.firstWhere((post) => testPost.id == post.id), isNotNull);
    });

    test("should be able to get post stream", () async {
      final postStream = postProvider.getPostStream(testPost.id);
      final post = await postStream.first;
      expect(post.id, testPost.id);
      expect(post.title, testPost.title);
      expect(post.content, testPost.content);
    });

    test('should be able to modify a post', () async {
      final updatedContent = "modified content";
      await postProvider.updatePostContent(testPost.id, updatedContent);
      final post = await postProvider.getPostById(testPost.id);
      expect(post != null, true);
      expect(post!.content == updatedContent, true);
    });

    test('should be able to delete a post', () async {
      await postProvider.deletePost(testPost.id);
      final post = await postProvider.getPostById(testPost.id);
      expect(post == null, true);
    });
  });

  group("Test NotificationProvider", () {
    setUpAll(() async {
      await profileProvider.addProfile(testProfile);
    });
    tearDownAll(() async {
      await profileProvider.deleteProfile(testProfile.id);
    });
    var notificationId = "";
    test("should be able to create a new notification", () async {
      notificationId = await notificationProvider.pushNotification(
          testProfile.id, testNotification);
    });
    test('should be able to find the notification in the notification stream',
        () async {
      final notificationStream = notificationProvider.notificationStream();
      final notifications = await notificationStream.first;
      expect(
          notifications.firstWhere((notification) =>
              notification.id == notificationId &&
              notification.content == testNotification.content),
          isNotNull);
    });
    test('should be able to clear notifications', () async {
      await notificationProvider.clearNotifications();
      expect((await notificationProvider.notificationStream().first), isEmpty);
    });
  });
}
