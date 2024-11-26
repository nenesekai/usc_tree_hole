import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:flutter/material.dart';
import 'package:usc_tree_hole/data/post_provider.dart';
import 'package:usc_tree_hole/model/post.dart';
import 'package:usc_tree_hole/view/component/post_card.dart';

class PostsListView extends StatelessWidget {
  const PostsListView({
    super.key,
    this.category,
    required this.sort,
  });

  final PostCategory? category;
  final int sort;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebasePostProvider()
            .getPostsStream(category: category, sort: sort),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            print(snapshot.error);
          }
          if (snapshot.data != null) {
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
