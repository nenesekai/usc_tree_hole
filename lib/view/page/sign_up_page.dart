import 'package:flutter/material.dart';

class SignUpPage extends StatefulWidget {
  static const route = '/signup';

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Text('Register'),
    );
  }
}
