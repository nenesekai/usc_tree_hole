import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:usc_tree_hole/data/profile_provider.dart';
import 'package:usc_tree_hole/model/profile.dart';
import 'package:usc_tree_hole/view/component/avatar.dart';
import 'package:usc_tree_hole/view/page/not_signed_in_page.dart';

class ProfilePage extends StatefulWidget {
  static const route = '/profile';

  final String? userId;

  const ProfilePage({super.key, this.userId});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _profileProvider = FirebaseProfileProvider();
  final _firebaseAuth = FirebaseAuth.instance;

  late Stream<User?> _currentUser;

  @override
  void initState() {
    _currentUser = _firebaseAuth.authStateChanges();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Profile?>(
        stream: widget.userId != null
            ? _profileProvider.getProfileStreamById(widget.userId!)
            : _currentUser.asyncMap((user) {
                if (user == null) {
                  return null;
                } else {
                  return _profileProvider.getProfileById(user.uid);
                }
              }),
        builder: (context, snapshot) {
          Profile? profile = snapshot.data;
          return Scaffold(
            appBar: AppBar(
                title: const Text('Profile'),
                actions: profile != null &&
                        profile.id == _firebaseAuth.currentUser?.uid
                    ? [
                        IconButton(
                          icon: const Icon(Icons.logout),
                          onPressed: () {
                            _firebaseAuth.signOut();
                          },
                        )
                      ]
                    : []),
            body: !snapshot.hasData
                ? const Center(child: CircularProgressIndicator())
                : profile == null
                    ? widget.userId == null
                        ? const NotSignedInPage()
                        : const Text('User Not Found')
                    : Column(
                        children: [
                          Avatar(userId: profile.id),
                          Text(profile.name),
                        ],
                      ),
          );
        });
  }
}
