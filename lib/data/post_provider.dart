import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:usc_tree_hole/model/notification.dart';
import 'package:usc_tree_hole/model/post.dart';
import 'package:usc_tree_hole/model/profile.dart';

abstract class PostProvider {
  Future<void> addPost(Post post);
  Future<Post> getPostById(String postId);
  Future<void> updatePostContent(String postId, String newContent);
  Stream<Post> getPostStream(String postId);
  Stream<List<Post>> getPostsStream(PostCategory? category);
  Stream<List<Post>> getPostsStreamByAuthorId(String authorId);
}

class FirestorePostProvider implements PostProvider {
  final CollectionReference _postsCollection =
      FirebaseFirestore.instance.collection('posts');
  final _firestore = FirebaseFirestore.instance;

  static PostCategory getCategoryByName(String name) {
    return postCategories.where((category) => category.label == name).first;
  }

  @override
  Future<void> addPost(Post post) {
    final posts = FirebaseFirestore.instance.collection('posts');
    final authorRef =
        FirebaseFirestore.instance.collection('users').doc(post.authorId);
    return posts.add({
      'title': post.title,
      'content': post.content,
      'category': post.category,
      'author': authorRef,
      'createdTime': Timestamp.now(),
    }).then((value) {
      authorRef.get().then((authorSnapshot) {
        if (authorSnapshot.data() != null) {
          final author = Profile.fromSnapshot(authorSnapshot);
          final query = _firestore
              .collection('users')
              .where('subscribedCategories', arrayContains: post.category);
          query.get().then(
            (querySnapshot) {
              for (final doc in querySnapshot.docs) {
                _firestore
                    .collection('users/${doc.id}/notifications')
                    .add(Notification(
                      id: '',
                      content:
                          '${author.name} created a new post \'${post.title}\' under ${post.category} category you subscribed to!',
                      senderId: author.id,
                      createTime: Timestamp.now(),
                    ).toMap());
              }
            },
          );
        }
      });
    });
  }

  @override
  Stream<Post> getPostStream(String postId) {
    return _firestore
        .doc('posts/$postId')
        .snapshots()
        .asyncMap((snapshot) => Post.fromSnapshot(snapshot));
  }

  @override
  Stream<List<Post>> getPostsStreamByAuthorId(String authorId) {
    return _firestore
        .collection('posts')
        .where('author', isEqualTo: _firestore.doc('users/$authorId'))
        .orderBy('createdTime', descending: true)
        .snapshots()
        .asyncMap((QuerySnapshot snapshot) {
      return snapshot.docs
          .map((QueryDocumentSnapshot docSnapshot) =>
              Post.fromSnapshot(docSnapshot))
          .toList();
    });
  }

  @override
  Stream<List<Post>> getPostsStream(PostCategory? category) {
    Query collectionRef =
        _firestore.collection('posts').orderBy('createdTime', descending: true);
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
    return _firestore
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
