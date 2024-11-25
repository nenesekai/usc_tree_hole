import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:usc_tree_hole/data/post_provider.dart';
import 'package:usc_tree_hole/data/profile_provider.dart';
import 'package:usc_tree_hole/model/post.dart';
import 'package:usc_tree_hole/model/profile.dart';

void main() {
  group("Testing Post Provider", () {
    late FirebaseFirestore firebaseFirestore;
    late FirebaseStorage firebaseStorage;
    late PostProvider postProvider;
    late ProfileProvider profileProvider;

    final testProfile = Profile(
        id: "test_user",
        name: "test user",
        role: "Undergraduate",
        uscId: "114514");
    var testPost = Post(
        id: "",
        title: "testing post",
        content: "testing post content",
        category: "Academic",
        authorId: testProfile.id);

    setUpAll(() async {
      firebaseFirestore = FakeFirebaseFirestore();
      firebaseStorage = MockFirebaseStorage();
      postProvider = FirebasePostProvider(firebaseFirestore);
      profileProvider =
          FirebaseProfileProvider(firebaseStorage, firebaseFirestore);

      // setting up test account
      await profileProvider.addProfile(testProfile);
    });

    test('test user should exist', () async {
      final user = await profileProvider.getProfileById(testProfile.id);
      expect(user == testProfile, true);
    });

    test('should be able to create a post', () async {
      final postId = await postProvider.addPost(testPost);
      testPost = testPost.copyWith(id: postId);
      final post = await postProvider.getPostById(postId);
      expect(post != null, true);
      expect(post!.id == testPost.id, true);
    });

    test('should be able to find this post in post list', () async {
      final posts = postProvider.getPostsStream(null);
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
}
