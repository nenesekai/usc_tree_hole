import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:usc_tree_hole/data/post_provider.dart';
import 'package:usc_tree_hole/data/profile_provider.dart';
import 'package:usc_tree_hole/data/reply_provider.dart';
import 'package:usc_tree_hole/model/post.dart';
import 'package:usc_tree_hole/model/profile.dart';
import 'package:usc_tree_hole/model/reply.dart';
import 'package:usc_tree_hole/view/component/avatar.dart';
import 'package:usc_tree_hole/view/page/profile_page.dart';

class PostPage extends StatefulWidget {
  final String postId;

  const PostPage({super.key, required this.postId});

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  final PostProvider _postProvider = FirebasePostProvider();
  final ReplyProvider _replyProvider = FirestoreReplyProvider();
  final ProfileProvider _profileProvider = FirebaseProfileProvider();
  final TextEditingController _replyController = TextEditingController();

  Post? _post;
  Profile? _author;
  List<Reply> _replies = [];
  Map<String, Profile> _userProfiles = {};
  bool _isAnonymous = false;
  String _anonymousName = '';
  bool _hasRepliedBefore = false;
  bool _isLoading = true;

  Map<String, Reply> repliesById = {};
  Map<String, List<Reply>> replyChildren = {};
  List<Reply> orderedReplies = [];

  @override
  void initState() {
    super.initState();
    _loadPost();
    _loadReplies();
    _checkUserReplyStatus();
  }

  Future<void> _loadPost() async {
    final post = await _postProvider.getPostById(widget.postId);
    if (post == null) {
      if (context.mounted) Navigator.pop(context);
      return;
    }
    final author = await _profileProvider.getProfileById(post.authorId);
    setState(() {
      _post = post;
      _author = author;
      _isLoading = false;
    });
  }

  void _loadReplies() {
    _replyProvider.getRepliesStream(widget.postId).listen((replies) async {
      // Fetch profiles for non-anonymous replies
      for (var reply in replies) {
        if (!reply.isAnonymous && !_userProfiles.containsKey(reply.authorId)) {
          final profile = await _profileProvider.getProfileById(reply.authorId);
          _userProfiles[reply.authorId] = profile;
        }
      }

      setState(() {
        _replies = replies;

        // Build the repliesById map
        repliesById = {for (var reply in _replies) reply.id: reply};

        // Build the replyChildren map
        replyChildren = {};
        for (var reply in _replies) {
          replyChildren[reply.parentId] ??= [];
          replyChildren[reply.parentId]!.add(reply);
        }

        // Build the orderedReplies list
        orderedReplies = _buildReplyList(widget.postId);
      });
    });
  }

  List<Reply> _buildReplyList(String parentId) {
    List<Reply> orderedReplies = [];
    if (replyChildren[parentId] != null) {
      for (var reply in replyChildren[parentId]!) {
        orderedReplies.add(reply);
        orderedReplies.addAll(_buildReplyList(reply.id));
      }
    }
    return orderedReplies;
  }

  Future<void> _checkUserReplyStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final status =
          await _replyProvider.getUserReplyStatus(widget.postId, user.uid);
      if (status.isNotEmpty) {
        setState(() {
          _isAnonymous = status['isAnonymous'];
          _anonymousName = status['anonymousName'];
          _hasRepliedBefore = true;
        });
      }
    }
  }

  Future<void> _onReply() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You need to sign in to reply')));
      return;
    }

    final content = _replyController.text.trim();
    if (content.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Reply cannot be empty')));
      return;
    }

    if (!_hasRepliedBefore) {
      bool choiceMade = await _chooseAnonymousOption();
      if (!choiceMade) {
        // User cancelled choosing anonymous option, so we should not proceed.
        return;
      }
    }

    // Create and add the reply
    final reply = Reply(
      id: '',
      content: content, // Store content without prefix
      authorId: user.uid,
      timestamp: DateTime.now(),
      isAnonymous: _isAnonymous,
      anonymousName: _anonymousName,
      parentId: widget.postId,
    );

    await _replyProvider.addReply(widget.postId, reply);

    // Clear the input field
    _replyController.clear();
  }

  Future<bool> _chooseAnonymousOption() async {
    final user = FirebaseAuth.instance.currentUser!;
    bool? isAnonymous = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        bool tempIsAnonymous = false;
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Anonymous Reply'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Do you want to reply anonymously?'),
                  SwitchListTile(
                    title: const Text('Anonymous'),
                    value: tempIsAnonymous,
                    onChanged: (value) {
                      setState(() {
                        tempIsAnonymous = value;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, null),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, tempIsAnonymous),
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      },
    );

    if (isAnonymous == null) {
      return false; // User cancelled the dialog
    }

    _isAnonymous = isAnonymous;

    if (_isAnonymous) {
      _anonymousName = await _generateAnonymousName();
    }

    // Save the user's anonymous status for this post
    await _replyProvider.setUserReplyStatus(
        widget.postId, user.uid, _isAnonymous, _anonymousName);

    setState(() {
      _hasRepliedBefore = true;
    });

    return true; // Choice made successfully
  }

  Future<String> _generateAnonymousName() async {
    // Generate a unique anonymous name
    final existingNames = _replies
        .where((reply) => reply.isAnonymous)
        .map((reply) => reply.anonymousName)
        .toSet();

    String anonymousName;
    int counter = existingNames.length + 1;
    do {
      anonymousName = 'Anonymous$counter';
      counter++;
    } while (existingNames.contains(anonymousName));

    return anonymousName;
  }

  String _getDisplayName(Reply reply) {
    if (reply.isAnonymous) {
      return reply.anonymousName;
    } else {
      return _userProfiles[reply.authorId]?.name ?? 'User';
    }
  }

  String _getParentAuthorName(Reply reply) {
    if (reply.parentId == widget.postId) {
      return ''; // Root reply, no parent author
    }

    Reply? parentReply = repliesById[reply.parentId];
    if (parentReply != null) {
      return _getDisplayName(parentReply);
    } else {
      return 'Unknown';
    }
  }

  int _calculateIndentLevel(Reply reply) {
    int level = 0;
    String? currentParentId = reply.parentId;
    while (currentParentId != null && currentParentId != widget.postId) {
      level++;
      Reply? parentReply = repliesById[currentParentId];
      if (parentReply != null) {
        currentParentId = parentReply.parentId;
      } else {
        break; // Parent not found
      }
    }
    return level;
  }

  void _showReplyToReplyDialog(Reply parentReply) {
    final TextEditingController _replyToReplyController =
        TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Reply to ${_getDisplayName(parentReply)}'),
          content: TextField(
            controller: _replyToReplyController,
            decoration: const InputDecoration(hintText: 'Enter your reply...'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await _addReplyToReply(
                    parentReply, _replyToReplyController.text.trim());
              },
              child: const Text('Reply'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _addReplyToReply(Reply parentReply, String content) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You need to sign in to reply')));
      return;
    }

    if (content.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Reply cannot be empty')));
      return;
    }

    if (!_hasRepliedBefore) {
      bool choiceMade = await _chooseAnonymousOption();
      if (!choiceMade) {
        // User cancelled choosing anonymous option, so we should not proceed.
        return;
      }
    }

    final reply = Reply(
      id: '',
      content: content, // Store content without 'reply to XXX: '
      authorId: user.uid,
      timestamp: DateTime.now(),
      isAnonymous: _isAnonymous,
      anonymousName: _anonymousName,
      parentId: parentReply.id, // Set parentId to the reply being replied to
    );

    await _replyProvider.addReply(widget.postId, reply);
  }

  Future<void> _deletePost() async {
    await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              title: const Text("Do you really want to delete this post"),
              actions: [
                TextButton(
                  onPressed: () {
                    _postProvider.deletePost(widget.postId);
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  child: const Text("Yes"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("No"),
                ),
              ]);
        });
  }

  Future<void> _editPost() async {
    final TextEditingController _editController =
        TextEditingController(text: _post!.content);

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Post'),
          content: TextField(
            controller: _editController,
            maxLines: 5,
            decoration: const InputDecoration(
              hintText: 'Edit your post content...',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(context), // Close dialog without saving
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await _updatePost(_editController.text.trim());
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updatePost(String newContent) async {
    if (newContent.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post content cannot be empty')),
      );
      return;
    }

    await _postProvider.updatePostContent(
        _post!.id, newContent); // Update post content in Firestore

    setState(() {
      _post = _post!.copyWith(content: newContent); // Update local state
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Post updated successfully')),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _post == null || _author == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: Text(_post!.title),
        actions: (user != null && user.uid == _post!.authorId)
            ? // Check if the current user is the author
            [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed:
                      _editPost, // Call _editPost function on button press
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed:
                      _deletePost, // Call _editPost function on button press
                ),
              ]
            : [],
      ),
      body: Column(
        children: [
          InkWell(
            onTap: () {
              Navigator.pushNamed(context, ProfilePage.route,
                  arguments: _author!.id);
            },
            child: ListTile(
              leading: Avatar(userId: _author!.id, size: 40.0),
              title: Text(_author!.name),
              subtitle: Text(_post!.category),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(_post!.content),
          ),
          const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: orderedReplies.length,
              itemBuilder: (context, index) {
                final reply = orderedReplies[index];
                int indentLevel = _calculateIndentLevel(reply);
                return Padding(
                  padding: EdgeInsets.only(left: indentLevel * 16.0),
                  child: ListTile(
                    leading: reply.isAnonymous
                        ? CircleAvatar(child: Text(reply.anonymousName[0]))
                        : InkWell(
                            onTap: () => Navigator.pushNamed(
                                context, ProfilePage.route,
                                arguments: reply.authorId),
                            child: Avatar(userId: reply.authorId, size: 40.0),
                          ),
                    title: Text(_getDisplayName(reply)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (reply.parentId != widget.postId)
                          Text(
                            'reply to ${_getParentAuthorName(reply)}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        Text(reply.content),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.reply),
                      onPressed: () {
                        _showReplyToReplyDialog(reply);
                      },
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _replyController,
                    decoration: const InputDecoration(
                      hintText: 'Enter your reply...',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _onReply,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
