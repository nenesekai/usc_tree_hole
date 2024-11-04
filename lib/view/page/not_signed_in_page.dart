import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NotSignedInPage extends StatelessWidget {
  const NotSignedInPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text('You Have Not Signed In Yet!',
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 200.0),
        ElevatedButton(
            child: const Text('Sign In'),
            onPressed: () {
              Navigator.pushNamed(context, '/signin');
            }),
        const SizedBox(height: 18.0),
        ElevatedButton(
            child: const Text('Create Account'),
            onPressed: () {
              Navigator.pushNamed(context, '/signup');
            }),
      ]),
    );
  }
}
