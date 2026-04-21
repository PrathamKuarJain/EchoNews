import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../core/providers.dart';
import '../../models/comment_model.dart';
import '../../core/constants.dart';

class CommentScreen extends ConsumerStatefulWidget {
  final String postId;
  const CommentScreen({super.key, required this.postId});

  @override
  ConsumerState<CommentScreen> createState() => _CommentScreenState();
}

class _CommentScreenState extends ConsumerState<CommentScreen> {
  final _commentController = TextEditingController();
  bool _isSending = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _submitComment() async {
    if (_commentController.text.trim().isEmpty) return;

    final user = ref.read(currentUserDataProvider).value;
    if (user == null) return;

    setState(() => _isSending = true);
    try {
      final comment = CommentModel(
        commentId: const Uuid().v4(),
        uid: user.uid,
        username: user.username,
        text: _commentController.text.trim(),
        createdAt: DateTime.now(),
      );

      await ref.read(firestoreServiceProvider).addComment(widget.postId, comment);
      _commentController.clear();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Comments')),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<CommentModel>>(
              stream: ref.watch(firestoreServiceProvider).getComments(widget.postId),
              builder: (context, snapshot) {
                final currentUser = ref.watch(currentUserDataProvider).value;
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No comments yet.'));
                }
                final comments = snapshot.data!;
                return ListView.builder(
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    final comment = comments[index];
                    final isOwner = currentUser?.uid == comment.uid;
                    return ListTile(
                      leading: CircleAvatar(
                        child: Text(comment.username[0].toUpperCase()),
                      ),
                      title: Text('@${comment.username}'),
                      subtitle: Text(comment.text),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            timeago.format(comment.createdAt, locale: 'en_short'),
                            style: const TextStyle(fontSize: 10),
                          ),
                          if (isOwner)
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.grey, size: 20),
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Delete Comment'),
                                    content: const Text('Are you sure you want to delete this comment?'),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, true), 
                                        child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                      ),
                                    ],
                                  ),
                                );
                                if (confirm == true) {
                                  await ref.read(firestoreServiceProvider).deleteComment(widget.postId, comment.commentId);
                                }
                              },
                            ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: const InputDecoration(
                      hintText: 'Write a comment...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _isSending ? null : _submitComment,
                  icon: _isSending
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.send, color: AppColors.primary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
