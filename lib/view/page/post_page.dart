import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:usc_tree_hole/data/post_provider.dart';
import 'package:usc_tree_hole/data/profile_provider.dart';
import 'package:usc_tree_hole/model/post.dart';
import 'package:usc_tree_hole/model/profile.dart';

class PostPage extends StatefulWidget {
  const PostPage({super.key, required this.postId});
  final String postId;

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  final ProfileProvider _userProvider = FirebaseProfileProvider();
  final PostProvider _postProvider = FirestorePostProvider();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: _postProvider.getPostStream(widget.postId),
        builder: (context, snapshot) {
          return Scaffold(
            appBar: AppBar(title: Text(snapshot.data?.title ?? '')),
            body: Padding(
                padding: const EdgeInsets.all(8.0),
                child: !snapshot.hasData
                    ? const Center(child: CircularProgressIndicator())
                    : snapshot.data == null
                        ? const Center(child: Text('Post Not Found'))
                        : Column(children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 6.0),
                              child: Row(
                                children: [
                                  const Icon(Icons.person),
                                  Text('Loading'),
                                  const Spacer(),
                                  Text(snapshot.data!.category),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16.0),
                            Text(snapshot.data!.content),
                          ])),
          );
        });
  }
}
