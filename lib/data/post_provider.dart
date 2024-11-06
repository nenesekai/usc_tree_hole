import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:usc_tree_hole/model/post.dart';

abstract class PostProvider {
  Future<void> addPost(Post post);
  Future<Post> getPostById(String postId);
  Future<void> updatePostContent(String postId, String newContent);
  Stream<Post> getPostStream(String postId);
  Stream<List<Post>> getPostsStream(PostCategory? category);
}

class FirestorePostProvider implements PostProvider {

  final CollectionReference _postsCollection = FirebaseFirestore.instance.collection('posts');

  static PostCategory getCategoryByName(String name) {
    return postCategories.where((category) => category.label == name).first;
  }

  @override
  Future<void> addPost(Post post) {
    final posts = FirebaseFirestore.instance.collection('posts');
    return posts.add({
      'title': post.title,
      'content': post.content,
      'category': post.category,
      'author':
          FirebaseFirestore.instance.collection('users').doc(post.authorId),
    });
  }

  @override
  Stream<Post> getPostStream(String postId) {
    return FirebaseFirestore.instance
        .doc('posts/$postId')
        .snapshots()
        .asyncMap((snapshot) => Post.fromSnapshot(snapshot));
  }

  @override
  Stream<List<Post>> getPostsStream(PostCategory? category) {
    Query collectionRef = FirebaseFirestore.instance.collection('posts');
    if (category != null) {
      collectionRef =
          collectionRef.where('category', isEqualTo: category.label);
    }
    return collectionRef.snapshots().asyncMap((QuerySnapshot snapshot) {
      return snapshot.docs
          .map((QueryDocumentSnapshot docSnapshot) =>
              Post.fromSnapshot(docSnapshot))
          .toList();
    });
  }

  @override
  Future<Post> getPostById(String postId) {
    return FirebaseFirestore.instance
        .collection('posts')
        .doc(postId)
        .get()
        .then((DocumentSnapshot doc) => Post.fromSnapshot(doc));
  }

  Future<void> updatePostContent(String postId, String newContent) async {
    await _postsCollection.doc(postId).update({
      'content': newContent,
    });
  }
}
