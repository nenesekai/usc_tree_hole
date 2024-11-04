import 'package:flutter/material.dart';
import 'package:usc_tree_hole/data/profile_provider.dart';
import 'package:usc_tree_hole/model/post.dart';
import 'package:usc_tree_hole/model/profile.dart';

class PostPage extends StatefulWidget {
  const PostPage({super.key, required this.post});

  final Post post;

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  final ProfileProvider _userProvider = FirebaseProfileProvider();
  bool _isLoading = true;
  Profile? author;

  @override
  void initState() {
    _userProvider.getProfileById(widget.post.authorId).then((author) {
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
      appBar: AppBar(title: Text(widget.post.title)),
      body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6.0),
                    child: Row(
                      children: [
                        const Icon(Icons.person),
                        Text(author?.name ?? 'Loading'),
                        const Spacer(),
                        Text(widget.post.category),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Text(widget.post.content),
                ])),
    );
  }
}
