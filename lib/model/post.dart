import 'package:cloud_firestore/cloud_firestore.dart';

typedef PostPressedCallback = void Function(Post post);
typedef ClosePostPressedCallback = void Function();

class Post {
  static const postCategory = <String>['Academic', 'Life', 'Event'];

  final String id;
  final String title;
  final String content;
  final String category;

  Post._({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
  });

  factory Post.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return Post._(
      id: snapshot.id,
      title: data['title'],
      content: data['content'],
      category: data['category'],
    );
  }
}
