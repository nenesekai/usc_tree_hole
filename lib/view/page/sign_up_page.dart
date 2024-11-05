import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:usc_tree_hole/data/profile_provider.dart';
import 'package:usc_tree_hole/main.dart';
import 'package:usc_tree_hole/model/post.dart';
import 'package:usc_tree_hole/model/profile.dart';

class SignUpPage extends StatefulWidget {
  static const route = '/signup';

  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _userProvider = FirebaseProfileProvider();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _uscIdController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _roleController = TextEditingController();
  final _originalEmailDecoration = const InputDecoration(
    icon: Icon(Icons.email),
    label: Text('USC Email'),
  );
  final _originalNameDecoration = const InputDecoration(
    icon: Icon(Icons.person),
    label: Text('Name'),
  );
  final _originalUscIdDecoration = const InputDecoration(
    icon: Icon(Icons.credit_card),
    label: Text('USC ID'),
  );
  final _originalPasswordDecoration = const InputDecoration(
    icon: Icon(Icons.password),
    label: Text('Password'),
  );

  late InputDecoration _emailDecoration;
  late InputDecoration _nameDecoration;
  late InputDecoration _passwordDecoration;
  late InputDecoration _confirmPasswordDecoration;
  late InputDecoration _uscIdDecoration;

  bool validateEmail() {
    if (_emailController.text.isEmpty) {
      setState(() {
        _emailDecoration = _emailDecoration.copyWith(
            error: const Text('Email cannot be empty'));
      });
      return false;
    } else {
      setState(() {
        _emailDecoration = _originalEmailDecoration;
      });
      return true;
    }
  }

  bool validateName() {
    if (_nameController.text.isEmpty) {
      setState(() {
        _nameDecoration =
            _nameDecoration.copyWith(error: const Text('Name cannot be empty'));
      });
      return false;
    } else {
      setState(() {
        _nameDecoration = _originalNameDecoration;
      });
      return true;
    }
  }

  bool validateUscId() {
    if (_uscIdController.text.isEmpty) {
      setState(() {
        _uscIdDecoration = _uscIdDecoration.copyWith(
            error: const Text('USC ID cannot be empty'));
      });
      return false;
    } else {
      setState(() {
        _uscIdDecoration = _originalUscIdDecoration;
      });
      return true;
    }
  }

  bool validatePassword() {
    if (_passwordController.text.isEmpty) {
      setState(() {
        _passwordDecoration = _passwordDecoration.copyWith(
            error: const Text('Password cannot be empty'));
      });
      return false;
    } else {
      setState(() {
        _passwordDecoration = _originalPasswordDecoration;
      });
      return true;
    }
  }

  bool validateConfirmPassword() {
    if (_confirmPasswordController.text.isEmpty) {
      setState(() {
        _confirmPasswordDecoration = _confirmPasswordDecoration.copyWith(
            error: const Text('Password cannot be empty'));
      });
      return false;
    } else if (_confirmPasswordController.text != _passwordController.text) {
      setState(() {
        _confirmPasswordDecoration = _confirmPasswordDecoration.copyWith(
            error: const Text('Passwords do not match'));
      });
      return false;
    } else {
      setState(() {
        _confirmPasswordDecoration = _originalPasswordDecoration;
      });
      return true;
    }
  }

  bool validateRole() {
    if (_roleController.text.isEmpty) {
      showDialog(
          context: context,
          builder: (_) => AlertDialog(
                content: const Text('Role cannot be empty'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('OK'))
                ],
              ));
      return false;
    } else {
      return true;
    }
  }

  @override
  void initState() {
    _emailDecoration = _originalEmailDecoration;
    _nameDecoration = _originalNameDecoration;
    _passwordDecoration = _originalPasswordDecoration;
    _confirmPasswordDecoration = _originalPasswordDecoration;
    _uscIdDecoration = _originalUscIdDecoration;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
      ),
      body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
            TextField(
              controller: _emailController,
              decoration: _emailDecoration,
              keyboardType: TextInputType.emailAddress,
              onChanged: (value) {
                setState(() {
                  _emailDecoration = _originalEmailDecoration;
                });
              },
              onSubmitted: (value) => validateEmail(),
            ),
            TextField(
              controller: _nameController,
              decoration: _nameDecoration,
              onChanged: (value) {
                setState(() {
                  _nameDecoration = _originalNameDecoration;
                });
              },
              onSubmitted: (value) => validateName(),
            ),
            TextField(
              controller: _uscIdController,
              decoration: _uscIdDecoration,
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  _uscIdDecoration = _originalUscIdDecoration;
                });
              },
              onSubmitted: (value) => validateUscId(),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                const Icon(Icons.people),
                const SizedBox(width: 16.0),
                DropdownMenu(
                  controller: _roleController,
                  label: const Text('Role'),
                  dropdownMenuEntries: roles
                      .map(
                          (role) => DropdownMenuEntry(value: role, label: role))
                      .toList(),
                  inputDecorationTheme: const InputDecorationTheme(),
                )
              ],
            ),
            TextField(
              controller: _passwordController,
              decoration: _passwordDecoration,
              obscureText: true,
              onChanged: (value) {
                setState(() {
                  _passwordDecoration = _originalPasswordDecoration;
                });
              },
              onSubmitted: (value) => validatePassword(),
              keyboardType: TextInputType.visiblePassword,
            ),
            TextField(
              controller: _confirmPasswordController,
              decoration: _confirmPasswordDecoration,
              obscureText: true,
              onChanged: (value) {
                setState(() {
                  _confirmPasswordDecoration = _originalPasswordDecoration;
                });
              },
              onSubmitted: (value) => validateConfirmPassword(),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 60.0),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                      onPressed: () {
                        if (validateEmail() &&
                            validateName() &&
                            validateUscId() &&
                            validateRole() &&
                            validatePassword() &&
                            validateConfirmPassword()) {
                          FirebaseAuth.instance
                              .createUserWithEmailAndPassword(
                                  email: _emailController.text,
                                  password: _passwordController.text)
                              .then((userCredential) {
                            final profile = Profile(
                              id: userCredential.user!.uid,
                              name: _nameController.text,
                              role: _roleController.text,
                              uscId: _uscIdController.text,
                            );
                            _userProvider.addProfile(profile).then((_) {
                              if (mounted) {
                                Navigator.pushReplacementNamed(
                                    context, HomePage.route);
                              }
                            });
                          }).onError((FirebaseAuthException e, _) {
                            showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                        title: const Text('Register Failed'),
                                        content: Text(e.code),
                                        actions: [
                                          TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context),
                                              child: const Text('OK'))
                                        ]));
                          });
                        }
                      },
                      child: const Text('Sign Up'))),
            ),
          ])),
    );
  }
}
