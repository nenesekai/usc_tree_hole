import 'package:flutter/material.dart';
import 'package:usc_tree_hole/data/post_provider.dart';
import 'package:usc_tree_hole/model/post.dart';
import 'package:usc_tree_hole/view/post_card.dart';
import 'package:usc_tree_hole/view/posts_list.dart';

class PostsPage extends StatefulWidget {
  const PostsPage({
    super.key,
  });

  @override
  State<PostsPage> createState() => _PostsPageState();
}

class _PostsPageState extends State<PostsPage> {
  bool _isLoading = true;
  String _selectedCategory = Post.postCategory.first;
  final FirestorePostProvider _firestorePostProvider = FirestorePostProvider();

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

  Future<void> _onChangedCategory(String category) async {
    setState(() {
      _isLoading = true;
      _selectedCategory = category;
    });
    Navigator.pop(context);
    _firestorePostProvider.loadAllPosts(_selectedCategory);
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Post>>(
      stream: _firestorePostProvider.allPosts,
      initialData: const [],
      builder: (BuildContext context, AsyncSnapshot<List<Post>> snapshot) {
        final posts = snapshot.data!;
        return Scaffold(
            appBar: AppBar(
              title: Text(_selectedCategory),
              backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            ),
            drawer: Drawer(
              child: SafeArea(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: Post.postCategory.map<ListTile>((category) {
                    return ListTile(
                      title: Text(category),
                      onTap: () => _onChangedCategory(category),
                      selected: _selectedCategory == category,
                      selectedTileColor: Theme.of(context).focusColor,
                    );
                  }).toList(),
                ),
              ),
            ),
            floatingActionButton: FloatingActionButton.extended(
                icon: const Icon(Icons.add),
                label: const Text('New Post'),
                onPressed: () {}),
            body: Center(
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : posts.isNotEmpty
                      ? PostsListView()
                      : const Text('No Posts Yet'),
            ));
      },
    );
  }
}
