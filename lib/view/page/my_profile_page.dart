import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:usc_tree_hole/data/profile_provider.dart';
import 'package:usc_tree_hole/model/profile.dart';
import 'package:usc_tree_hole/view/page/not_signed_in_page.dart';
import 'package:usc_tree_hole/view/page/profile_page.dart';

class MyProfilePage extends StatefulWidget {
  const MyProfilePage({
    super.key,
  });

  @override
  State<MyProfilePage> createState() => _MyProfilePageState();
}

class _MyProfilePageState extends State<MyProfilePage> {
  bool _isLoading = true;

  final ProfileProvider _profileProvider = FirebaseProfileProvider();
  late StreamSubscription<User?> _authStateListener;
  late User? _user;

  Future<Profile> get _profile => _profileProvider.getProfileById(_user!.uid);

  @override
  void initState() {
    _user = FirebaseAuth.instance.currentUser;
    _authStateListener =
        FirebaseAuth.instance.authStateChanges().listen((user) {
      if (mounted) {
        setState(() => _user = FirebaseAuth.instance.currentUser);
      }
    });
    _isLoading = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
          actions: [
            PopupMenuButton(
              onSelected: (value) {
                if (value == 'signout') {
                  FirebaseAuth.instance.signOut();
                  setState(() {});
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(
                    value: 'signout',
                    child:
                        Text('Sign Out', style: TextStyle(color: Colors.red)))
              ],
              enabled: _user != null,
            ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _user == null
                ? const NotSignedInPage()
                : FutureBuilder(
                    future: _profile,
                    initialData: null,
                    builder: (context, snapshot) => snapshot.hasData
                        ? ProfilePage(profile: snapshot.data!)
                        : const Center(child: CircularProgressIndicator()),
                  ));
  }
}
