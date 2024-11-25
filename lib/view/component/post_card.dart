import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:usc_tree_hole/data/post_provider.dart';
import 'package:usc_tree_hole/data/profile_provider.dart';
import 'package:usc_tree_hole/model/post.dart';
import 'package:usc_tree_hole/model/profile.dart';
import 'package:usc_tree_hole/view/component/avatar.dart';
import 'package:usc_tree_hole/view/page/post_page.dart';

class PostCard extends StatelessWidget {
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;
  final FirebaseAuth auth;

  const PostCard({
    super.key,
    required this.post,
    required this.firestore,
    required this.storage,
    required this.auth,
  });

  final Post post;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final _profileProvider = FirebaseProfileProvider(firestore, storage);
    final _postProvider = FirebasePostProvider(firestore);
    return StreamBuilder<Profile>(
        stream: _profileProvider.getProfileStreamById(post.authorId),
        builder: (context, profileSnapshot) {
          return profileSnapshot.hasData
              ? InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => PostPage(
                                postId: post.id,
                                firestore: firestore,
                                storage: storage,
                                auth: auth)));
                  },
                  child: Card(
                    child: Padding(
                        padding: const EdgeInsets.all(14.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            InkWell(
                                onTap: () {
                                  Navigator.pushNamed(context, '/profile',
                                      arguments: profileSnapshot.data!.id);
                                },
                                child: Row(
                                  children: [
                                    Avatar(
                                      userId: post.authorId,
                                      size: 18.0,
                                      profileProvider: _profileProvider,
                                    ),
                                    const SizedBox(width: 8.0),
                                    Text(profileSnapshot.data!.name),
                                  ],
                                )),
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
