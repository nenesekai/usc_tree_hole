import 'package:flutter/material.dart';
import 'package:usc_tree_hole/model/post.dart';
import 'package:usc_tree_hole/view/post_card.dart';

class PostsListView extends StatelessWidget {
  const PostsListView({
    super.key,
    required this.posts,
    required this.onPressedPost,
  });

  final List<Post> posts;
  final void Function(Post) onPressedPost;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: posts
          .map((post) => Padding(
                padding: const EdgeInsets.all(6.0),
                child: PostCard(post: post),
              ))
          .toList(),
    );
  }
}
