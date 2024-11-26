import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:usc_tree_hole/data/post_provider.dart';
import 'package:usc_tree_hole/model/post.dart';
import 'package:usc_tree_hole/view/component/posts_list.dart';

class PostsPage extends StatefulWidget {
  const PostsPage({
    super.key,
  });

  @override
  State<PostsPage> createState() => _PostsPageState();
}

class _PostsPageState extends State<PostsPage> {
  int _selectedCategoryIndex = 0;
  int _sortMethod = 0;
  PostCategory get _selectedCategory => postCategories[_selectedCategoryIndex];
  final FirebasePostProvider _firestorePostProvider = FirebasePostProvider();
  final snackBar =
      const SnackBar(content: Text('You Must Sign In Before You Can Post!'));

  late StreamSubscription<User?> _userSubscription;
  late bool _isSignedIn;

  @override
  void initState() {
    _isSignedIn = FirebaseAuth.instance.currentUser != null;
    _userSubscription =
        FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (mounted) {
        setState(() {
          _isSignedIn = FirebaseAuth.instance.currentUser != null;
        });
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _userSubscription.cancel();
    super.dispose();
  }

  Future<void> _onChangedCategory(int index) async {
    setState(() {
      _selectedCategoryIndex = index;
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(_selectedCategory.label),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          actions: [
            PopupMenuButton(
                onSelected: (value) {
                  setState(() {
                    _sortMethod = value;
                  });
                },
                itemBuilder: (context) => [
                      PopupMenuItem(value: 0, child: Text('Create Time')),
                      PopupMenuItem(value: 1, child: Text('Title')),
                    ],
                icon: Icon(Icons.sort))
          ],
        ),
        drawer: NavigationDrawer(
            selectedIndex: _selectedCategoryIndex,
            onDestinationSelected: (value) => _onChangedCategory(value),
            children: [
              Padding(
                  padding: const EdgeInsets.fromLTRB(28, 16, 16, 10),
                  child: Text('Category',
                      style: Theme.of(context).textTheme.titleSmall)),
              ...postCategories.map((category) => NavigationDrawerDestination(
                    label: Text(category.label),
                    icon: category.icon,
                    selectedIcon: category.selectedIcon,
                  ))
            ]),
        floatingActionButton: FloatingActionButton.extended(
            icon: const Icon(Icons.add),
            label: const Text('New Post'),
            onPressed: () {
              if (_isSignedIn) {
                Navigator.pushNamed(context, '/newpost',
                    arguments: _selectedCategory);
              } else {
                ScaffoldMessenger.of(context).removeCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              }
            }),
        body: PostsListView(
          category: _selectedCategory,
          sort: _sortMethod,
        ));
  }
}
