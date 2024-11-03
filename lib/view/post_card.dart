import 'package:flutter/material.dart';
import 'package:usc_tree_hole/data/user_provider.dart';
import 'package:usc_tree_hole/model/post.dart';
import 'package:usc_tree_hole/model/user.dart';

class PostCard extends StatelessWidget {
  PostCard({
    super.key,
    required this.post,
  });

  final Post post;

  final UserProvider _userProvider = FirebaseUserProvider();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.person_rounded, size: 18.0),
                const SizedBox(width: 4.0),
                FutureBuilder(
                    future: _userProvider.getUserById(post.authorId),
                    builder:
                        (BuildContext context, AsyncSnapshot<User> snapshot) {
                      return Text(snapshot.data?.name ?? 'User');
                    }),
              ],
            ),
            const SizedBox(height: 6.0),
            Text(
              post.title,
              style: theme.textTheme.titleLarge!.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.start,
            ),
            Text(
              post.content,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }
}
