import 'package:flutter/material.dart';
import 'package:usc_tree_hole/model/user.dart';

class ProfilePage extends StatefulWidget {
  static const route = '/profile';

  final User user;

  const ProfilePage({super.key, required this.user});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Text('Hello ${widget.user.name}');
  }
}
