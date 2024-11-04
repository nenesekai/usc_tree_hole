import 'package:flutter/material.dart';
import 'package:usc_tree_hole/model/profile.dart';

class ProfilePage extends StatefulWidget {
  static const route = '/profile';

  final Profile profile;

  const ProfilePage({super.key, required this.profile});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Text('Hello ${widget.profile.name}');
  }
}
