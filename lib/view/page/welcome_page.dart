import 'package:flutter/material.dart';
import 'package:usc_tree_hole/view/page/sign_in_page.dart';
import 'package:usc_tree_hole/view/page/sign_up_page.dart';

class WelcomePage extends StatelessWidget {
  static const route = '/welcome';

  const WelcomePage({super.key});

  void onSignInPressed(BuildContext context) {
    Navigator.of(context).pushNamed(SignInPage.route);
  }

  void onSignUpPressed(BuildContext context) {
    Navigator.of(context).pushNamed(SignUpPage.route);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text('Welcome to USC Tree Hole'),
            ElevatedButton(
              onPressed: () => onSignInPressed(context),
              child: const Text('Sign In'),
            ),
            FilledButton(
              onPressed: () => onSignUpPressed(context),
              child: const Text('Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
}
