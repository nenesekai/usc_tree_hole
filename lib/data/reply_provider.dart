import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:usc_tree_hole/model/reply.dart';

abstract class ReplyProvider {
  Future<void> addReply(String postId, Reply reply);
  Stream<List<Reply>> getRepliesStream(String postId);
  Future<Map<String, dynamic>> getUserReplyStatus(String postId, String userId);
  Future<void> setUserReplyStatus(String postId, String userId, bool isAnonymous, String anonymousName);
}

class FirestoreReplyProvider implements ReplyProvider {
  @override
  Future<void> addReply(String postId, Reply reply) {
    final repliesCollection = FirebaseFirestore.instance
        .collection('posts')
        .doc(postId)
        .collection('replies');
    return repliesCollection.add(reply.toMap());
  }

  @override
  Stream<List<Reply>> getRepliesStream(String postId) {
    final repliesCollection = FirebaseFirestore.instance
        .collection('posts')
        .doc(postId)
        .collection('replies')
        .orderBy('timestamp');
    return repliesCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Reply.fromSnapshot(doc)).toList();
    });
  }

  @override
  Future<Map<String, dynamic>> getUserReplyStatus(String postId, String userId) async {
    final docRef = FirebaseFirestore.instance
        .collection('posts')
        .doc(postId)
        .collection('userReplyStatus')
        .doc(userId);
    final docSnapshot = await docRef.get();
    if (docSnapshot.exists) {
      return docSnapshot.data()!;
    } else {
      return {};
    }
  }

  @override
  Future<void> setUserReplyStatus(String postId, String userId, bool isAnonymous, String anonymousName) {
    final docRef = FirebaseFirestore.instance
        .collection('posts')
        .doc(postId)
        .collection('userReplyStatus')
        .doc(userId);
    return docRef.set({
      'isAnonymous': isAnonymous,
      'anonymousName': anonymousName,
    });
  }
}