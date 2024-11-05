import 'package:flutter/material.dart';
import 'package:usc_tree_hole/data/post_provider.dart';
import 'package:usc_tree_hole/data/profile_provider.dart';
import 'package:usc_tree_hole/model/post.dart';
import 'package:usc_tree_hole/model/profile.dart';
import 'package:usc_tree_hole/view/component/avatar.dart';
import 'package:usc_tree_hole/view/page/post_page.dart';

class PostCard extends StatelessWidget {
  final ProfileProvider _profileProvider = FirebaseProfileProvider();
  final PostProvider _postProvider = FirestorePostProvider();

  PostCard({
    super.key,
    required this.post,
  });

  final Post post;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return StreamBuilder<Profile>(
        stream: _profileProvider.getProfileStreamById(post.authorId),
        builder: (context, profileSnapshot) {
          return profileSnapshot.hasData
              ? InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => PostPage(postId: post.id)));
                  },
                  child: Card(
                    child: Padding(
                        padding: const EdgeInsets.all(14.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Avatar(userId: post.authorId, size: 18.0),
                                const SizedBox(width: 8.0),
                                Text(profileSnapshot.data!.name),
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
                        )),
                  ),
                )
              : const Center(child: CircularProgressIndicator());
        });
  }
}
