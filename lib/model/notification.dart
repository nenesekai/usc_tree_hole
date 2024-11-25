import 'package:cloud_firestore/cloud_firestore.dart';

class Notification {
  final String id;
  final String content;
  final String senderId;
  final Timestamp createTime;

  const Notification({
    required this.id,
    required this.content,
    required this.senderId,
    required this.createTime,
  });

  factory Notification.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return Notification(
      id: snapshot.id,
      content: data['content'],
      senderId: data['sender'].id,
      createTime: data['createTime'],
    );
  }
}
