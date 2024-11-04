import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:usc_tree_hole/data/profile_provider.dart';
import 'package:usc_tree_hole/model/post.dart';
import 'package:usc_tree_hole/model/profile.dart';

class NewPostPage extends StatefulWidget {
  const NewPostPage({super.key, this.initialCategory});

  final PostCategory? initialCategory;

  @override
  State<NewPostPage> createState() => _NewPostPageState();
}

class _NewPostPageState extends State<NewPostPage> {
  final _profileProvider = FirebaseProfileProvider();

  bool _isLoading = true;
  PostCategory? _selectedCategory;

  late Profile author;

  @override
  void initState() {
    final user = FirebaseAuth.instance.currentUser;
    _selectedCategory = widget.initialCategory;
    if (user == null) {
      Navigator.pop(context);
    }
    _profileProvider.getProfileById(user!.uid).then((author) {
      this.author = author;
      setState(() {
        _isLoading = false;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('New Post'), actions: [
          TextButton(
            child: const Text('Post'),
            onPressed: () {},
          )
        ]),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 18.0),
                child: Column(children: [
                  Card.filled(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Posting as ',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                )),
                            const Icon(Icons.person),
                            Text(author.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                )),
                          ]),
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  DropdownMenu(
                    dropdownMenuEntries: postCategories
                        .map((category) => DropdownMenuEntry(
                              value: category,
                              label: category.label,
                            ))
                        .toList(),
                    label: const Text('Category'),
                    initialSelection: _selectedCategory,
                    inputDecorationTheme: const InputDecorationTheme(),
                    width: double.infinity,
                    onSelected: (value) =>
                        setState(() => _selectedCategory = value),
                  ),
                ]),
              ));
  }
}
