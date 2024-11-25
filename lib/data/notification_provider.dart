import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:usc_tree_hole/model/notification.dart';

abstract class NotificationProvider {
  Stream<List<Notification>> notificationStream();
  Future<String> pushNotification(String targetId, Notification notification);
  Future clearNotifications();
}

class FirebaseNotificationProvider implements NotificationProvider {
  late final FirebaseFirestore _firestore;
  final String _userId;

  FirebaseNotificationProvider(String userId,
      [FirebaseFirestore? firebaseFirestore])
      : _userId = userId,
        _firestore = firebaseFirestore ?? FirebaseFirestore.instance;

  @override
  Stream<List<Notification>> notificationStream() => _firestore
      .collection('users/$_userId/notifications')
      .orderBy('createTime', descending: true)
      .snapshots()
      .asyncMap((QuerySnapshot querySnapshot) => querySnapshot.docs
          .map((QueryDocumentSnapshot snapshot) =>
              Notification.fromSnapshot(snapshot))
          .toList());

  @override
  Future<String> pushNotification(String targetId, Notification notification) {
    Map<String, dynamic> map = {
      'content': notification.content,
      'sender': _firestore.doc('/users/${notification.senderId}'),
      'createTime': notification.createTime,
    };
    return _firestore
        .collection('users/$targetId/notifications')
        .add(map)
        .then((ref) => ref.id);
  }

  @override
  Future clearNotifications() async {
    final collectionRef = _firestore.collection('users/$_userId/notifications');
    final query = await collectionRef.get();
    for (final doc in query.docs) {
      doc.reference.delete();
    }
  }
}
