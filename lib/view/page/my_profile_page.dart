import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:usc_tree_hole/data/profile_provider.dart';
import 'package:usc_tree_hole/model/post.dart';
import 'package:usc_tree_hole/model/profile.dart';
import 'package:usc_tree_hole/view/component/avatar.dart';
import 'package:usc_tree_hole/view/page/edit_profile_page.dart';
import 'package:usc_tree_hole/view/page/profile_page.dart';
import 'package:usc_tree_hole/view/page/welcome_page.dart';

class MyProfilePage extends StatefulWidget {
  static const route = '/myprofile';

  const MyProfilePage(
      {super.key,
      required this.user,
      required this.firestore,
      required this.storage,
      required this.auth});

  final User user;
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;
  final FirebaseAuth auth;

  @override
  State<MyProfilePage> createState() => _MyProfilePageState();
}

class _MyProfilePageState extends State<MyProfilePage> {
  bool _isLoading = true;
  late final FirebaseProfileProvider _profileProvider;

  @override
  void initState() {
    _profileProvider =
        FirebaseProfileProvider(widget.firestore, widget.storage);
    setState(() {
      _isLoading = false;
    });
    super.initState();
  }

  void onSignOut(BuildContext context) {
    FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, WelcomePage.route);
  }

  void onPressChangeProfilePicture() {
    ImagePicker().pickImage(source: ImageSource.gallery).then((XFile? image) {
      if (image == null) return;
      _profileProvider
          .uploadAvatar(
        File(image.path),
        widget.user.uid,
      )
          .then(
        (value) {
          if (mounted) {
            setState(() {});
          }
        },
      );
    });
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
              body: profile == null || _isLoading == true
                  ? const Center(child: CircularProgressIndicator())
                  : Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListView(children: [
                        InkWell(
                            onTap: () => Navigator.pushNamed(
                                context, ProfilePage.route,
                                arguments: widget.user.uid),
                            child: ProfileCard(profile: profile)),
                        ElevatedButton(
                            onPressed: onPressChangeProfilePicture,
                            child: const Text('Change Profile Picture')),
                        ElevatedButton(
                          child: const Text('Edit Profile'),
                          onPressed: () {
                            Navigator.pushNamed(context, EditProfilePage.route,
                                arguments: profile.id);
                          },
                        ),
                        const Divider(),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Card(
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  const Text('Categories Subscribed'),
                                  ...postCategories.map((category) =>
                                      Row(children: [
                                        Text(category.label),
                                        Switch.adaptive(
                                            value: profile.subscribedCategories
                                                .contains(category.label),
                                            onChanged: (value) {
                                              List<dynamic> sub =
                                                  profile.subscribedCategories;
                                              if (value) {
                                                sub.add(category.label);
                                              } else {
                                                sub.remove(category.label);
                                              }
                                              _profileProvider
                                                  .updateProfile(profile.id, {
                                                'subscribedCategories': sub,
                                              });
                                            }),
                                      ])),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ])));
        });
  }
}
