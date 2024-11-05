import 'package:cloud_firestore/cloud_firestore.dart';

class Notification {
  final String id;
  final String content;
  final String userId;
  final DateTime createTime;

  Notification({
    required this.id,
    required this.content,
    required this.userId,
    required this.createTime,
  });

  factory Notification.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return Notification(
      id: snapshot.id,
      content: data['content'],
      userId: data['user'].id,
      createTime: data['createTime'],
    );
  }
}
