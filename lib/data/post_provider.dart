import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:usc_tree_hole/model/post.dart';
import 'package:usc_tree_hole/model/profile.dart';

abstract class PostProvider {
  Future<String> addPost(Post post);
  Future<Post?> getPostById(String postId);
  Future<void> updatePostContent(String postId, String newContent);
  Stream<Post> getPostStream(String postId);
  Stream<List<Post>> getPostsStream(
      {required int sort, PostCategory? category});
  Stream<List<Post>> getPostsStreamByAuthorId(String authorId, [int sort]);
  Future<void> deletePost(String postId);
}

class FirebasePostProvider implements PostProvider {
  late final FirebaseFirestore _firestore;
  CollectionReference get _postsCollection => _firestore.collection('posts');

  FirebasePostProvider([FirebaseFirestore? firestore])
      : _firestore = firestore ?? FirebaseFirestore.instance;

  static PostCategory getCategoryByName(String name) {
    return postCategories.where((category) => category.label == name).first;
  }

  @override
  Future<String> addPost(Post post) async {
    final posts = _firestore.collection('posts');
    final authorRef = _firestore.collection('users').doc(post.authorId);
    final docRef = await posts.add({
      'title': post.title,
      'content': post.content,
      'category': post.category,
      'author': authorRef,
      'createdTime': Timestamp.now(),
    });
    final authorSnapshot = await authorRef.get();
    if (authorSnapshot.data() != null) {
      final author = Profile.fromSnapshot(authorSnapshot);
      final query = _firestore
          .collection('users')
          .where('subscribedCategories', arrayContains: post.category);
      final querySnapshot = await query.get();
      Map<String, dynamic> notificationMap = {
        'content':
            '${author.name} created a new post \'${post.title}\' under ${post.category} category you subscribed to!',
        'sender': _firestore.doc('/users/${author.id}'),
        'createTime': Timestamp.now(),
      };
      for (final doc in querySnapshot.docs) {
        _firestore
            .collection('users/${doc.id}/notifications')
            .add(notificationMap);
      }
    }
    return docRef.id;
  }

  @override
  Stream<Post> getPostStream(String postId) {
    return _firestore
        .doc('posts/$postId')
        .snapshots()
        .asyncMap((snapshot) => Post.fromSnapshot(snapshot));
  }

  @override
  Stream<List<Post>> getPostsStreamByAuthorId(String authorId, [int sort = 0]) {
    var query = _firestore
        .collection('posts')
        .where('author', isEqualTo: _firestore.doc('users/$authorId'));
    if (sort == 1) {
      query = query.orderBy('title', descending: true);
    } else {
      query = query.orderBy('createdTime', descending: true);
    }
    return query.snapshots().asyncMap((QuerySnapshot snapshot) {
      return snapshot.docs
          .map((QueryDocumentSnapshot docSnapshot) =>
              Post.fromSnapshot(docSnapshot))
          .toList();
    });
  }

  @override
  Stream<List<Post>> getPostsStream(
      {required int sort, PostCategory? category}) {
    Query collectionRef = _firestore.collection('posts');
    if (category != null) {
      collectionRef =
          collectionRef.where('category', isEqualTo: category.label);
    }
    if (sort == 1) {
      collectionRef = collectionRef.orderBy('title');
    } else {
      collectionRef = collectionRef.orderBy('createdTime', descending: true);
    }
    return collectionRef.snapshots().asyncMap((QuerySnapshot snapshot) {
      return snapshot.docs
          .map((QueryDocumentSnapshot docSnapshot) =>
              Post.fromSnapshot(docSnapshot))
          .toList();
    });
  }

  @override
  Future<Post?> getPostById(String postId) async {
    DocumentSnapshot doc =
        await _firestore.collection('posts').doc(postId).get();
    if (doc.data() != null) {
      return Post.fromSnapshot(doc);
    } else {
      return null;
    }
  }

  @override
  Future<void> updatePostContent(String postId, String newContent) async {
    await _postsCollection.doc(postId).update({
      'content': newContent,
    });
  }

  @override
  Future<void> deletePost(String postId) async {
    await _postsCollection.doc(postId).delete();
  }
}
