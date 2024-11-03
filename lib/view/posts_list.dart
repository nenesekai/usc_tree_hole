import 'package:flutter/material.dart';
import 'package:usc_tree_hole/view/post_card.dart';

class PostsListView extends StatelessWidget {
  const PostsListView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      children: [
        Padding(
          padding: EdgeInsets.all(6.0),
          child: PostCard(theme: theme),
        )
      ],
    );
  }
}
