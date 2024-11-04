import 'package:flutter/material.dart';
import 'package:usc_tree_hole/data/profile_provider.dart';
import 'package:usc_tree_hole/model/post.dart';
import 'package:usc_tree_hole/model/profile.dart';
import 'package:usc_tree_hole/view/page/post_page.dart';

class PostCard extends StatelessWidget {
  ProfileProvider _profileProvider = FirebaseProfileProvider();

  PostCard({
    super.key,
    required this.post,
  });

  final Post post;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => PostPage(post: post)));
      },
      child: Card(
        child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: FutureBuilder(
                future: _profileProvider.getProfileById(post.authorId),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final author = snapshot.data!;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.person_rounded, size: 18.0),
                            const SizedBox(width: 4.0),
                            Text(author.name),
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
                    );
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                })),
      ),
    );
  }
}
