import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:usc_tree_hole/model/post.dart';

class PostCard extends StatelessWidget {
  const PostCard({
    super.key,
    required this.post,
    required PostPressedCallback onPostPressed,
  }) : _onPressed = onPostPressed;

  final Post post;
  final PostPressedCallback _onPressed;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [Text(post.title ?? "")],
      ),
    );
  }
}

class PostCard extends StatelessWidget {
  const PostCard({
    super.key,
    required this.theme,
  });

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.person_rounded, size: 18.0),
                SizedBox(width: 4.0),
                Text('Author'),
              ],
            ),
            SizedBox(height: 6.0),
            Text(
              'This is the title of the post',
              style: theme.textTheme.titleLarge!.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.start,
            ),
            Text('This is the content of the post'),
          ],
        ),
      ),
    );
  }
}
