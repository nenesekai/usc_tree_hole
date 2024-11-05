import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
// import 'package:image_picker/image_picker.dart';
import 'package:usc_tree_hole/data/profile_provider.dart';
import 'package:usc_tree_hole/model/profile.dart';
import 'package:usc_tree_hole/view/component/avatar.dart';

class EditProfilePage extends StatefulWidget {
  static const route = '/editprofile';
  const EditProfilePage({super.key, required this.profileId});
  final String profileId;

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  bool _isLoading = true;
  final _profileProvider = FirebaseProfileProvider();
  final _nameController = TextEditingController();
  final _uscIdController = TextEditingController();
  final _roleController = TextEditingController();

  String? _nameError;
  String? _uscIdError;

  late Avatar _avatar;

  @override
  void initState() {
    _avatar = Avatar(userId: widget.profileId);
    _profileProvider.getProfileById(widget.profileId).then((Profile profile) {
      if (mounted) {
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
              padding: EdgeInsets.all(12.0),
              child: ListView(children: [
                _avatar,
                ElevatedButton(
                  onPressed: () {
                    ImagePicker()
                        .pickImage(source: ImageSource.gallery)
                        .then((XFile? image) {
                      if (image == null) return;
                      _profileProvider
                          .uploadAvatar(
                        File(image.path),
                        widget.profileId,
                      )
                          .then(
                        (value) {
                          if (mounted) {
                            setState(() {
                              _avatar = Avatar(
                                userId: widget.profileId,
                              );
                            });
                          }
                        },
                      );
                    });
                  },
                  child: const Text('Change Profile Picture'),
                ),
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    filled: true,
                    label: const Text('Name'),
                    errorText: _nameError,
                  ),
                ),
                TextField(
                  controller: _uscIdController,
                  decoration: InputDecoration(
                    filled: true,
                    label: const Text('USC ID'),
                    errorText: _uscIdError,
                  ),
                ),
                DropdownMenu(
                  controller: _roleController,
                  dropdownMenuEntries: roles
                      .map((String role) =>
                          DropdownMenuEntry(value: role, label: role))
                      .toList(),
                  inputDecorationTheme:
                      const InputDecorationTheme(filled: true),
                  label: const Text('Role'),
                )
              ]),
            ),
    );
  }
}
