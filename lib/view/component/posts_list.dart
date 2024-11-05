import 'package:flutter/material.dart';
import 'package:usc_tree_hole/data/post_provider.dart';
import 'package:usc_tree_hole/model/post.dart';
import 'package:usc_tree_hole/view/component/post_card.dart';

class PostsListView extends StatelessWidget {
  const PostsListView({
    super.key,
    this.category,
  });

  final PostCategory? category;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirestorePostProvider().getPostsStream(category),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final List<Post> posts = snapshot.data!;
            if (posts.isEmpty) {
              return const Center(child: Text('No Posts Yet'));
            } else {
              return ListView(
                children: posts
                    .map((post) => Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: PostCard(post: post)))
                    .toList(),
              );
            }
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        });
    // ListView(
    //   children: posts
    //       .map((post) => Padding(
    //             padding: const EdgeInsets.all(6.0),
    //             child: PostCard(postId: post.id),
    //           ))
    //       .toList(),
    // );
  }
}
