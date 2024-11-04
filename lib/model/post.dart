import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

typedef PostPressedCallback = void Function(Post post);
typedef ClosePostPressedCallback = void Function();

class PostCategory {
  const PostCategory(this.label, this.icon, this.selectedIcon);

  final String label;
  final Widget icon;
  final Widget selectedIcon;
}

const List<PostCategory> postCategories = <PostCategory>[
  PostCategory('Academic', Icon(Icons.school_outlined), Icon(Icons.school)),
  PostCategory('Life', Icon(Icons.people_outlined), Icon(Icons.people)),
  PostCategory(
      'Event', Icon(Icons.calendar_month_outlined), Icon(Icons.calendar_month)),
];

class Post {
  final String? id;
  final String title;
  final String content;
  final String category;
  final String authorId;

  Post({
    this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.authorId,
  });

  factory Post.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return Post(
      id: snapshot.id,
      title: data['title'],
      content: data['content'],
      category: data['category'],
      authorId: data['author'].id,
    );
  }
}
