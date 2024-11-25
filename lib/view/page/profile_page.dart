import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:usc_tree_hole/data/post_provider.dart';
import 'package:usc_tree_hole/data/profile_provider.dart';
import 'package:usc_tree_hole/model/post.dart';
import 'package:usc_tree_hole/model/profile.dart';
import 'package:usc_tree_hole/view/component/avatar.dart';
import 'package:usc_tree_hole/view/component/post_card.dart';

class ProfilePage extends StatefulWidget {
  static const route = '/profile';

  final String profileId;

  const ProfilePage(
      {super.key,
      required this.profileId,
      required this.firestore,
      required this.storage,
      required this.auth});
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;
  final FirebaseAuth auth;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final FirebaseProfileProvider _profileProvider;
  late final FirebasePostProvider _postProvider;

  @override
  void initState() {
    _profileProvider =
        FirebaseProfileProvider(widget.firestore, widget.storage);
    _postProvider = FirebasePostProvider(widget.firestore);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Profile?>(
      stream: _profileProvider.getProfileStreamById(widget.profileId),
      builder: (context, snapshot) {
        final Profile? profile = snapshot.data;
        return StreamBuilder<List<Post>>(
            stream: profile == null
                ? Stream.empty()
                : _postProvider.getPostsStreamByAuthorId(profile.id),
            builder: (context, snapshot) {
              final List<Post>? posts = snapshot.data;
              return Scaffold(
                appBar: AppBar(title: const Text('Profile')),
                body: snapshot.hasData == false
                    ? const Center(child: CircularProgressIndicator())
                    : profile == null || posts == null
                        ? const Center(child: Text('Profile Not Found'))
                        : Padding(
                            padding: EdgeInsets.all(8.0),
                            child: ListView(children: [
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: ProfileCard(profile: profile),
                              ),
                              Divider(),
                              ...posts.map((post) => PostCard(post: post))
                            ])),
              );
            });
      },
    );
  }
}

class ProfileCard extends StatelessWidget {
  const ProfileCard({
    super.key,
    required this.profile,
  });

  final Profile profile;

  @override
  Widget build(BuildContext context) {
    return Card(
        child: Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(children: [
        Avatar(userId: profile.id),
        SizedBox(width: 14.0),
        Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              profile.role.toUpperCase(),
              style: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
            Text(
              profile.name,
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 36.0,
              ),
            ),
            Text(
              profile.uscId,
              style: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ],
        )
      ]),
    ));
  }
}
