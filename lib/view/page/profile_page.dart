import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:usc_tree_hole/data/profile_provider.dart';
import 'package:usc_tree_hole/model/profile.dart';
import 'package:usc_tree_hole/view/component/avatar.dart';

class ProfilePage extends StatefulWidget {
  static const route = '/profile';

  final String userId;

  const ProfilePage({super.key, required this.userId});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _profileProvider = FirebaseProfileProvider();
  final _storageRef = FirebaseStorage.instance.ref();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Profile>(
        stream: _profileProvider.getProfileStreamById(widget.userId),
        builder: (context, snapshot) {
          Profile? profile = snapshot.data;
          return Scaffold(
            appBar: AppBar(title: const Text('Profile')),
            body: profile == null
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    children: [
                      Avatar(userId: widget.userId),
                      Text(profile.name),
                    ],
                  ),
          );
        });
  }
}
