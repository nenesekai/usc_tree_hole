import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
// import 'package:image_picker/image_picker.dart';
import 'package:usc_tree_hole/data/profile_provider.dart';
import 'package:usc_tree_hole/model/profile.dart';
import 'package:usc_tree_hole/view/component/avatar.dart';

class EditProfilePage extends StatefulWidget {
  static const route = '/editprofile';
  const EditProfilePage(
      {super.key,
      required this.profileId,
      required this.firestore,
      required this.storage,
      required this.auth});
  final String profileId;
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;
  final FirebaseAuth auth;

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  bool _isLoading = true;
  late final FirebaseProfileProvider _profileProvider;
  final _nameController = TextEditingController();
  final _uscIdController = TextEditingController();
  final _roleController = TextEditingController();

  String? _nameError;
  String? _uscIdError;

  @override
  void initState() {
    _profileProvider =
        FirebaseProfileProvider(widget.firestore, widget.storage);
    _profileProvider.getProfileById(widget.profileId).then((Profile? profile) {
      if (mounted) {
        if (profile == null) {
          Navigator.pop(context);
          return;
        }
        setState(() {
          _nameController.text = profile.name;
          _uscIdController.text = profile.uscId;
          _roleController.text = profile.role;
          _isLoading = false;
        });
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          TextButton(
            onPressed: () {
              final profile = Profile(
                id: widget.profileId,
                name: _nameController.text,
                role: _roleController.text,
                uscId: _uscIdController.text,
              );
              _profileProvider.addProfile(profile).then(
                (value) {
                  if (mounted) {
                    Navigator.pop(context);
                  }
                },
              );
            },
            child: const Text('Save'),
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 18.0),
              child: ListView(children: [
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    filled: true,
                    label: const Text('Name'),
                    errorText: _nameError,
                  ),
                ),
                SizedBox(height: 12.0),
                TextField(
                  controller: _uscIdController,
                  decoration: InputDecoration(
                    filled: true,
                    label: const Text('USC ID'),
                    errorText: _uscIdError,
                  ),
                ),
                SizedBox(height: 12.0),
                DropdownMenu(
                  controller: _roleController,
                  dropdownMenuEntries: roles
                      .map((String role) =>
                          DropdownMenuEntry(value: role, label: role))
                      .toList(),
                  inputDecorationTheme:
                      const InputDecorationTheme(filled: true),
                  label: const Text('Role'),
                ),
              ]),
            ),
    );
  }
}
