import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:usc_tree_hole/data/post_provider.dart';
import 'package:usc_tree_hole/data/profile_provider.dart';
import 'package:usc_tree_hole/model/post.dart';
import 'package:usc_tree_hole/model/profile.dart';
import 'package:usc_tree_hole/view/component/avatar.dart';

class PostPage extends StatefulWidget {
  const PostPage({super.key, required this.postId});
  final String postId;

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  final ProfileProvider _profileProvider = FirebaseProfileProvider();
  final PostProvider _postProvider = FirestorePostProvider();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: _postProvider.getPostStream(widget.postId),
        builder: (context, postSnapshot) {
          return StreamBuilder<Profile>(
              stream: postSnapshot.data != null
                  ? _profileProvider
                      .getProfileStreamById(postSnapshot.data!.authorId)
                  : const Stream.empty(),
              builder: (context, userSnapshot) {
                final post = postSnapshot.data;
                final author = userSnapshot.data;
                return Scaffold(
                  appBar: AppBar(title: Text(post?.title ?? '')),
                  body: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: post == null || author == null
                          ? const Center(child: CircularProgressIndicator())
                          : Column(children: [
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 6.0),
                                child: Row(
                                  children: [
                                    Avatar(userId: author.id, size: 24.0),
                                    SizedBox(width: 8.0),
                                    Text(author.name,
                                        style: const TextStyle(
                                            fontSize: 18.0,
                                            fontWeight: FontWeight.w600)),
                                    const Spacer(),
                                    Text(post.category),
                                  ],
                                ),
                              ),
                              const Divider(),
                              const SizedBox(height: 16.0),
                              Text(
                                post.content,
                                textAlign: TextAlign.start,
                              ),
                            ])),
                );
              });
        });
  }
}
