import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:usc_tree_hole/model/post.dart';

abstract class PostProvider {
  Stream<List<Post>> get allPosts;
  Future<void> addPost(Post post);
  Future<Post> getPostById(String postId);
  void loadAllPosts([PostCategory? category]);
  void dispose();
}

class FirestorePostProvider implements PostProvider {
  FirestorePostProvider() {
    allPosts = _allPostsController.stream;
  }

  final StreamController<List<Post>> _allPostsController = StreamController();

  static PostCategory getCategoryByName(String name) {
    return postCategories.where((category) => category.label == name).first;
  }

  @override
  late final Stream<List<Post>> allPosts;

  @override
  Future<void> addPost(Post post) {
    final posts = FirebaseFirestore.instance.collection('posts');
    return posts.add({
      'title': post.title,
      'content': post.content,
    });
  }

  @override
  void loadAllPosts([PostCategory? category]) {
    Query collection = FirebaseFirestore.instance.collection('posts');

    if (category != null) {
      collection = collection.where('category', isEqualTo: category.label);
    }

    final querySnapshot = collection.snapshots();

    querySnapshot.listen((event) {
      final posts = event.docs.map((DocumentSnapshot doc) {
        return Post.fromSnapshot(doc);
      }).toList();

      _allPostsController.add(posts);
    });
  }

  @override
  @override
  void dispose() {
    _allPostsController.close();
  }

  @override
  Future<Post> getPostById(String postId) {
    return FirebaseFirestore.instance
        .collection('posts')
        .doc(postId)
        .get()
        .then((DocumentSnapshot doc) => Post.fromSnapshot(doc));
  }
}
