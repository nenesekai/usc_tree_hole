import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:usc_tree_hole/model/notification.dart';

abstract class NotificationProvider {
  Stream<List<Notification>> notificationStream();
  Future pushNotification(String targetId, Notification notification);
  Future clearNotifications();
}

class FirebaseNotificationProvider implements NotificationProvider {
  final _firestore = FirebaseFirestore.instance;
  final String _userId;

  FirebaseNotificationProvider({required userId}) : _userId = userId;

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
  Future pushNotification(String targetId, Notification notification) {
    return _firestore
        .collection('users/$targetId/notifications')
        .add(notification.toMap());
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
