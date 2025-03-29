import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/comment.dart';

class CommentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'comments';

  // Add a new comment
  Future<void> addComment(Comment comment) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(comment.id)
          .set(comment.toFirestore());

      // Update company rating statistics
      await _updateCompanyRatings(comment.companyId);
    } catch (e) {
      throw Exception('Failed to add comment: $e');
    }
  }

  // Get all comments for a specific company
  Future<List<Comment>> getCommentsByCompany(String companyId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('companyId', isEqualTo: companyId)
          .where('isApproved', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) => Comment.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to get comments: $e');
    }
  }

  // Get all comments by a specific user
  Future<List<Comment>> getCommentsByUser(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) => Comment.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to get user comments: $e');
    }
  }

  // Report a comment
  Future<void> reportComment(String commentId) async {
    try {
      final docRef = _firestore.collection(_collection).doc(commentId);

      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);
        if (!snapshot.exists) {
          throw Exception('Comment does not exist');
        }

        final currentCount = snapshot.data()!['reportCount'] ?? 0;
        transaction.update(docRef, {'reportCount': currentCount + 1});

        // Auto-hide comments with high report counts
        if (currentCount + 1 >= 5) {
          transaction.update(docRef, {'isApproved': false});
        }
      });
    } catch (e) {
      throw Exception('Failed to report comment: $e');
    }
  }

  // Delete a comment
  Future<void> deleteComment(String commentId, String companyId) async {
    try {
      await _firestore.collection(_collection).doc(commentId).delete();

      // Update company rating statistics
      await _updateCompanyRatings(companyId);
    } catch (e) {
      throw Exception('Failed to delete comment: $e');
    }
  }

  // Update a comment
  Future<void> updateComment(Comment comment) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(comment.id)
          .update(comment.toFirestore());
    } catch (e) {
      throw Exception('Failed to update comment: $e');
    }
  }

  // Helper method to update company rating statistics
  Future<void> _updateCompanyRatings(String companyId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('companyId', isEqualTo: companyId)
          .where('isApproved', isEqualTo: true)
          .get();

      final comments =
          snapshot.docs.map((doc) => Comment.fromFirestore(doc)).toList();

      if (comments.isEmpty) {
        // If no comments, reset statistics
        await _firestore.collection('companies').doc(companyId).update({
          'positiveCount': 0,
          'negativeCount': 0,
          'totalComments': 0,
          'rating': 0.0,
        });
        return;
      }

      final positiveCount = comments.where((c) => c.isPositive).length;
      final totalComments = comments.length;
      final rating =
          totalComments > 0 ? (positiveCount / totalComments) * 5 : 0.0;

      await _firestore.collection('companies').doc(companyId).update({
        'positiveCount': positiveCount,
        'negativeCount': totalComments - positiveCount,
        'totalComments': totalComments,
        'rating': rating,
      });
    } catch (e) {
      throw Exception('Failed to update company ratings: $e');
    }
  }
}
