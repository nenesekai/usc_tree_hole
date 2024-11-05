import 'package:cloud_firestore/cloud_firestore.dart';

class Reply {
  final String id;
  final String content;
  final String authorId;
  final DateTime timestamp;
  final bool isAnonymous;
  final String anonymousName;
  final String parentId; // ID of the post or reply being replied to

  Reply({
    required this.id,
    required this.content,
    required this.authorId,
    required this.timestamp,
    required this.isAnonymous,
    required this.anonymousName,
    required this.parentId,
  });

  factory Reply.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return Reply(
      id: snapshot.id, // Ensure the id is assigned
      content: data['content'],
      authorId: data['authorId'],
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      isAnonymous: data['isAnonymous'] ?? false,
      anonymousName: data['anonymousName'] ?? '',
      parentId: data['parentId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'content': content,
      'authorId': authorId,
      'timestamp': timestamp,
      'isAnonymous': isAnonymous,
      'anonymousName': anonymousName,
      'parentId': parentId,
    };
  }
}