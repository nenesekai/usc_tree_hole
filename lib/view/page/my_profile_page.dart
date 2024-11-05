import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:usc_tree_hole/data/profile_provider.dart';
import 'package:usc_tree_hole/model/profile.dart';
import 'package:usc_tree_hole/view/page/edit_profile_page.dart';
import 'package:usc_tree_hole/view/page/profile_page.dart';
import 'package:usc_tree_hole/view/page/welcome_page.dart';

class MyProfilePage extends StatefulWidget {
  static const route = '/myprofile';

  const MyProfilePage({super.key, required this.user});

  final User user;

  @override
  State<MyProfilePage> createState() => _MyProfilePageState();
}

class _MyProfilePageState extends State<MyProfilePage> {
  final _profileProvider = FirebaseProfileProvider();

  void onSignOut(BuildContext context) {
    FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, WelcomePage.route);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Profile>(
        stream: _profileProvider.getProfileStreamById(widget.user.uid),
        builder: (context, snapshot) {
          final profile = snapshot.data;
          return Scaffold(
              appBar: AppBar(
                title: const Text('My Profile'),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.logout),
                    onPressed: () => onSignOut(context),
                  ),
                ],
              ),
              body: profile == null
                  ? const Center(child: CircularProgressIndicator())
                  : Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListView(children: [
                        ProfileCard(profile: profile),
                        const Divider(),
                        ElevatedButton(
                          child: const Text('Edit Profile'),
                          onPressed: () {
                            Navigator.pushNamed(context, EditProfilePage.route,
                                arguments: profile.id);
                          },
                        ),
                      ])));
        });
  }
}
