import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:usc_tree_hole/data/profile_provider.dart';
import 'package:usc_tree_hole/model/profile.dart';
import 'package:usc_tree_hole/view/page/not_signed_in_page.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final _profileProvider = FirebaseProfileProvider();
  late StreamSubscription<User?> _userSubscription;
  late User? _user;

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
    _userSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (mounted) {
        setState(() {
          _user = FirebaseAuth.instance.currentUser;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return _user == null
        ? const NotSignedInPage()
        : FutureBuilder(
            future: _profileProvider.getProfileById(_user!.uid),
            builder: (BuildContext bc, AsyncSnapshot<Profile> snapshot) =>
                Text('Signed In As ${snapshot.data?.name ?? 'Loading'}'));
  }
}
