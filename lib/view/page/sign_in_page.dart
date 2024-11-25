import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:usc_tree_hole/main.dart';
import 'package:usc_tree_hole/view/page/sign_up_page.dart';

class SignInPage extends StatefulWidget {
  static const route = '/signin';

  const SignInPage({super.key, required this.auth});

  final FirebaseAuth auth;

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _hidePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Sign In'),
        ),
        body: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
          Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.email),
                  labelText: 'USC Email',
                  filled: true,
                ),
                keyboardType: TextInputType.emailAddress,
              )),
          Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.password),
                  suffixIcon: IconButton(
                    icon: Icon(_hidePassword
                        ? Icons.visibility_off
                        : Icons.visibility),
                    onPressed: () =>
                        setState(() => _hidePassword = !_hidePassword),
                  ),
                  labelText: 'Password',
                  filled: true,
                ),
                keyboardType: TextInputType.visiblePassword,
                obscureText: _hidePassword,
              )),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                        onPressed: () {
                          widget.auth
                              .signInWithEmailAndPassword(
                                  email: _emailController.text,
                                  password: _passwordController.text)
                              .then((UserCredential uc) {
                            if (mounted) {
                              Navigator.pushReplacementNamed(
                                  context, HomePage.route);
                            }
                          }).onError((FirebaseAuthException e, _) {
                            showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                      title: const Text('Sign In Failed'),
                                      content: Text(e.code),
                                      actions: [
                                        TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: const Text('OK'))
                                      ],
                                    ));
                          });
                        },
                        child: const Text('Sign In'))),
                const SizedBox(height: 8.0),
                SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                        onPressed: () {
                          Navigator.popAndPushNamed(context, SignUpPage.route);
                        },
                        child: const Text('Create an Account'))),
              ],
            ),
          )
        ]));
  }
}
