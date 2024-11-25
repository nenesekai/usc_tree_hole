import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:usc_tree_hole/data/post_provider.dart';
import 'package:usc_tree_hole/model/post.dart';
import 'package:usc_tree_hole/view/component/post_card.dart';

class PostsListView extends StatelessWidget {
  const PostsListView({
    super.key,
    this.category,
    required FirebasePostProvider postProvider,
    required this.storage,
    required this.firestore,
    required this.auth,
  }) : _postProvider = postProvider;

  final PostCategory? category;
  final FirebasePostProvider _postProvider;
  final FirebaseStorage storage;
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: _postProvider.getPostsStream(category),
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
                        child: PostCard(
                            post: post,
                            firestore: firestore,
                            storage: storage,
                            auth: auth)))
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
