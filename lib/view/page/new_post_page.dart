import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:usc_tree_hole/data/post_provider.dart';
import 'package:usc_tree_hole/data/profile_provider.dart';
import 'package:usc_tree_hole/model/post.dart';
import 'package:usc_tree_hole/model/profile.dart';

class NewPostPage extends StatefulWidget {
  static const route = '/newpost';
  const NewPostPage({super.key, this.initialCategory});

  final PostCategory? initialCategory;

  @override
  State<NewPostPage> createState() => _NewPostPageState();
}

class _NewPostPageState extends State<NewPostPage> {
  final _profileProvider = FirebaseProfileProvider();
  final _postProvider = FirebasePostProvider();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  static const _formSpacing = SizedBox(height: 8.0);

  bool _isLoading = true;
  PostCategory? _selectedCategory;

  String? _categoryError;
  String? _titleError;

  late Profile author;

  @override
  void initState() {
    final user = FirebaseAuth.instance.currentUser;
    _selectedCategory = widget.initialCategory;
    if (user == null) {
      Navigator.pop(context);
    }
    _profileProvider.getProfileById(user!.uid).then((author) {
      this.author = author!;
      setState(() {
        _isLoading = false;
      });
    });
    super.initState();
  }

  bool validateCategory() {
    if (_selectedCategory == null) {
      setState(() {
        _categoryError = 'Category cannot be empty';
      });
      return false;
    } else {
      setState(() {
        _categoryError = null;
      });
      return true;
    }
  }

  bool validateTitle() {
    if (_titleController.text.isEmpty) {
      setState(() {
        _titleError = 'Title cannot be empty';
      });
      return false;
    } else {
      setState(() {
        _titleError = null;
      });
      return true;
    }
  }

  void onPost() {
    if (validateCategory() & validateTitle()) {
      final newPost = Post(
        id: '',
        authorId: author.id,
        category: _selectedCategory!.label,
        title: _titleController.text,
        content: _contentController.text,
      );
      _postProvider.addPost(newPost).then((_) {
        if (context.mounted) Navigator.pop(context);
      }).onError((FirebaseException e, stackTrace) {
        if (context.mounted) {
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                    title: const Text('An Error Has Occurred'),
                    content: Text(e.message ?? ''),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('OK'),
                      ),
                    ]);
              });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('New Post'), actions: [
          TextButton(
            onPressed: onPost,
            child: const Text('Post'),
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
                  const SizedBox(height: 12.0),
                  DropdownMenu(
                    dropdownMenuEntries: postCategories
                        .map((category) => DropdownMenuEntry(
                              value: category,
                              label: category.label,
                            ))
                        .toList(),
                    label: const Text('Category'),
                    initialSelection: _selectedCategory,
                    inputDecorationTheme: const InputDecorationTheme(
                      filled: true,
                    ),
                    width: double.infinity,
                    errorText: _categoryError,
                    onSelected: (value) =>
                        setState(() => _selectedCategory = value),
                  ),
                  _formSpacing,
                  TextField(
                    controller: _titleController,
                    maxLines: 1,
                    decoration: InputDecoration(
                      label: const Text('Title'),
                      filled: true,
                      errorText: _titleError,
                      errorBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red),
                      ),
                    ),
                    onSubmitted: (value) => validateTitle(),
                  ),
                  _formSpacing,
                  TextField(
                    controller: _contentController,
                    minLines: 6,
                    maxLines: 6,
                    autocorrect: true,
                    textAlignVertical: TextAlignVertical.top,
                    decoration: const InputDecoration(
                      label: Text('Content'),
                      filled: true,
                    ),
                  ),
                ]),
              ));
  }
}
