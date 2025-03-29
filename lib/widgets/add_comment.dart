// import 'package:flutter/material.dart';
// import '../models/comment.dart';
// import '../services/comment_service.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// class AddCommentWidget extends StatefulWidget {
//   final String companyId;
//   final Function(Comment) onCommentAdded;

//   const AddCommentWidget({
//     Key? key,
//     required this.companyId,
//     required this.onCommentAdded,
//   }) : super(key: key);

//   @override
//   _AddCommentWidgetState createState() => _AddCommentWidgetState();
// }

// class _AddCommentWidgetState extends State<AddCommentWidget> {
//   final TextEditingController _commentController = TextEditingController();
//   final CommentService _commentService = CommentService();
//   bool _isSubmitting = false;
//   bool _isPositive = true; // Default sentiment

//   @override
//   void dispose() {
//     _commentController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(16.0),
//       decoration: BoxDecoration(
//         color: Theme.of(context).cardColor,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             blurRadius: 4.0,
//             offset: const Offset(0, -2),
//           ),
//         ],
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: [
//           TextField(
//             controller: _commentController,
//             maxLines: 3,
//             decoration: const InputDecoration(
//               hintText: 'Write a comment...',
//               border: OutlineInputBorder(),
//             ),
//           ),
//           const SizedBox(height: 8.0),
//           // Add sentiment toggle
//           Row(
//             children: [
//               Text('Comment sentiment:', style: TextStyle(fontSize: 14)),
//               const SizedBox(width: 8.0),
//               ChoiceChip(
//                 label: Text('Positive'),
//                 selected: _isPositive,
//                 onSelected: (selected) {
//                   setState(() {
//                     _isPositive = selected;
//                   });
//                 },
//               ),
//               const SizedBox(width: 8.0),
//               ChoiceChip(
//                 label: Text('Negative'),
//                 selected: !_isPositive,
//                 onSelected: (selected) {
//                   setState(() {
//                     _isPositive = !selected;
//                   });
//                 },
//               ),
//             ],
//           ),
//           const SizedBox(height: 12.0),
//           ElevatedButton(
//             onPressed: _isSubmitting ? null : _submitComment,
//             child: _isSubmitting
//                 ? const SizedBox(
//                     height: 20,
//                     width: 20,
//                     child: CircularProgressIndicator(
//                       strokeWidth: 2.0,
//                     ),
//                   )
//                 : const Text('POST COMMENT'),
//           ),
//         ],
//       ),
//     );
//   }

//   Future<void> _submitComment() async {
//     final commentText = _commentController.text.trim();
//     if (commentText.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Comment cannot be empty')),
//       );
//       return;
//     }

//     setState(() {
//       _isSubmitting = true;
//     });

//     try {
//       // Get current user details from Firebase Auth
//       final currentUser = FirebaseAuth.instance.currentUser;
//       if (currentUser == null) {
//         throw Exception('User must be logged in to post a comment');
//       }

//       // Create a new Comment object
//       final comment = Comment(
//         id: '', // This will be set by Firestore
//         userId: currentUser.uid,
//         userName: currentUser.displayName ?? 'Anonymous',
//         content: commentText,
//         companyId: widget.companyId,
//         userProfileUrl: currentUser.photoURL ?? '',
//         isPositive: _isPositive,
//         createdAt: DateTime.now(),
//       );

//       // Add the comment to Firestore
//       final newComment = await _commentService.addComment(comment);

//       _commentController.clear();
//       widget.onCommentAdded(newComment);

//       // Show success message
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Comment posted successfully')),
//       );
//     } catch (e) {
//       // Show error message
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to post comment: ${e.toString()}')),
//       );
//     } finally {
//       setState(() {
//         _isSubmitting = false;
//       });
//     }
//   }
// }