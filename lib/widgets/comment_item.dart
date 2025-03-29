import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../models/comment.dart';
import '../services/comment_service.dart';

class CommentItem extends StatelessWidget {
  final Comment comment;
  final bool isCurrentUser;
  final Function()? onEdit;
  final Function()? onDelete;

  const CommentItem({
    Key? key,
    required this.comment,
    this.isCurrentUser = false,
    this.onEdit,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundImage: comment.userProfileUrl.isNotEmpty
                      ? NetworkImage(comment.userProfileUrl)
                      : null,
                  child: comment.userProfileUrl.isEmpty
                      ? Text(comment.userName.isNotEmpty
                          ? comment.userName[0].toUpperCase()
                          : '?')
                      : null,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        comment.userName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        timeago.format(comment.createdAt),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  comment.isPositive ? Icons.thumb_up : Icons.thumb_down,
                  color: comment.isPositive ? Colors.green : Colors.red,
                  size: 16,
                ),
                if (isCurrentUser) ...[
                  const SizedBox(width: 8),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, size: 18),
                    onSelected: (value) {
                      if (value == 'edit' && onEdit != null) {
                        onEdit!();
                      } else if (value == 'delete' && onDelete != null) {
                        onDelete!();
                      }
                    },
                    itemBuilder: (BuildContext context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 18),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 18),
                            SizedBox(width: 8),
                            Text('Delete'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  IconButton(
                    icon: const Icon(Icons.flag, size: 18),
                    onPressed: () => _reportComment(context),
                    tooltip: 'Report',
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            Text(comment.content),
          ],
        ),
      ),
    );
  }

  Future<void> _reportComment(BuildContext context) async {
    final commentService = CommentService();

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Report Comment'),
          content: const Text(
              'Are you sure you want to report this comment for inappropriate content?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  await commentService.reportComment(comment.id);
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text(
                            'Comment reported. Thank you for your feedback.')),
                  );
                } catch (e) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to report comment: $e')),
                  );
                }
              },
              child: const Text('Report'),
            ),
          ],
        );
      },
    );
  }
}

class CommentList extends StatelessWidget {
  final List<Comment> comments;
  final String currentUserId;
  final Function(Comment) onEditComment;
  final Function(Comment) onDeleteComment;

  const CommentList({
    Key? key,
    required this.comments,
    required this.currentUserId,
    required this.onEditComment,
    required this.onDeleteComment,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (comments.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'No comments yet. Be the first to leave feedback!',
            style: TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: comments.length,
      itemBuilder: (context, index) {
        final comment = comments[index];
        final isCurrentUser = comment.userId == currentUserId;

        return CommentItem(
          comment: comment,
          isCurrentUser: isCurrentUser,
          onEdit: isCurrentUser ? () => onEditComment(comment) : null,
          onDelete: isCurrentUser ? () => onDeleteComment(comment) : null,
        );
      },
    );
  }
}
