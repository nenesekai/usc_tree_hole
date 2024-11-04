import 'package:flutter/foundation.dart';
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
  bool _isLoading = true;
  int _selectedCategoryIndex = 0;
  PostCategory get _selectedCategory => postCategories[_selectedCategoryIndex];
  final FirestorePostProvider _firestorePostProvider = FirestorePostProvider();
  final snackBar =
      const SnackBar(content: Text('You Must Sign In Before You Can Post!'));

  @override
  void initState() {
    _firestorePostProvider.loadAllPosts(_selectedCategory);
    _isLoading = false;
    super.initState();
  }

  @override
  void dispose() {
    _firestorePostProvider.dispose();
    super.dispose();
  }

  Future<void> _onChangedCategory(int index) async {
    setState(() {
      _isLoading = true;
      _selectedCategoryIndex = index;
    });
    Navigator.pop(context);
    _firestorePostProvider.loadAllPosts(_selectedCategory);
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(_selectedCategory.label),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
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
              ScaffoldMessenger.of(context).removeCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
            }),
        body: Center(
            child: _isLoading
                ? const CircularProgressIndicator()
                : StreamBuilder<List<Post>>(
                    stream: _firestorePostProvider.allPosts,
                    initialData: const [],
                    builder: (BuildContext context,
                        AsyncSnapshot<List<Post>> snapshot) {
                      final posts = snapshot.data!;
                      return posts.isNotEmpty
                          ? PostsListView(posts: posts)
                          : const Text('No Posts Yet');
                    },
                  )));
  }
}
