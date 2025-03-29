import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import '../models/user.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;

  // Collection references
  final CollectionReference _usersCollection =
      FirebaseFirestore.instance.collection('users');
  final CollectionReference _editsCollection =
      FirebaseFirestore.instance.collection('edits');

  // Get current user
  auth.User? get currentUser => _auth.currentUser;

  // Get user stream by ID
  Stream<User> getUserStream(String userId) {
    return _usersCollection.doc(userId).snapshots().map(
          (snapshot) => User.fromFirestore(snapshot),
        );
  }

  // Get user by ID
  Future<User?> getUserById(String userId) async {
    try {
      DocumentSnapshot doc = await _usersCollection.doc(userId).get();
      if (doc.exists) {
        return User.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error getting user: $e');
      return null;
    }
  }

  // Create new user profile after authentication
  Future<void> createUserProfile(User authUser, {String? displayName}) async {
    try {
      // Check if user document already exists
      DocumentSnapshot userDoc = await _usersCollection.doc(authUser.id).get();

      if (!userDoc.exists) {
        // Create new user document
        User newUser = User(
          id: authUser.id,
          email: authUser.email ?? '',
          name: displayName ?? authUser.name ?? 'User',
          photoUrl: authUser.photoUrl,
          createdAt: DateTime.now(),
          reputation: 0,
          contributions: [],
          // isVerified: false,
          savedCompanies: [],
          savedResumes: [],
        );

        await _usersCollection.doc(authUser.id).set(newUser.toFirestore());
      }
    } catch (e) {
      print('Error creating user profile: $e');
      throw e;
    }
  }

  // Update user profile
  Future<void> updateUserProfile(
      String userId, Map<String, dynamic> data) async {
    try {
      await _usersCollection.doc(userId).update(data);
    } catch (e) {
      print('Error updating user profile: $e');
      throw e;
    }
  }

  // Update user reputation based on contributions
  Future<void> updateUserReputation(String userId, int points) async {
    try {
      await _usersCollection.doc(userId).update({
        'reputation': FieldValue.increment(points),
        'contributionCount': FieldValue.increment(1),
      });
    } catch (e) {
      print('Error updating user reputation: $e');
      throw e;
    }
  }

  // Save a company to user's saved list
  Future<void> saveCompany(String userId, String companyId) async {
    try {
      await _usersCollection.doc(userId).update({
        'savedCompanies': FieldValue.arrayUnion([companyId]),
      });
    } catch (e) {
      print('Error saving company: $e');
      throw e;
    }
  }

  // Remove a company from user's saved list
  Future<void> removeSavedCompany(String userId, String companyId) async {
    try {
      await _usersCollection.doc(userId).update({
        'savedCompanies': FieldValue.arrayRemove([companyId]),
      });
    } catch (e) {
      print('Error removing saved company: $e');
      throw e;
    }
  }

  // Get user's saved companies
  Future<List<String>> getSavedCompanies(String userId) async {
    try {
      DocumentSnapshot doc = await _usersCollection.doc(userId).get();
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        List<dynamic> savedCompanies = data['savedCompanies'] ?? [];
        return savedCompanies.cast<String>();
      }
      return [];
    } catch (e) {
      print('Error getting saved companies: $e');
      return [];
    }
  }

  // Track user edit/contribution
  Future<void> trackUserContribution(
      String userId, String companyId, String actionType) async {
    try {
      await _editsCollection.add({
        'userId': userId,
        'companyId': companyId,
        'actionType': actionType, // 'edit', 'comment', 'report', etc.
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'pending', // pending, approved, rejected
      });
    } catch (e) {
      print('Error tracking user contribution: $e');
      throw e;
    }
  }

  // Get user contributions
  Future<List<Map<String, dynamic>>> getUserContributions(String userId) async {
    try {
      QuerySnapshot query = await _editsCollection
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .get();

      return query.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('Error getting user contributions: $e');
      return [];
    }
  }

  // Add resume to user's profile
  Future<void> addUserResume(
      String userId, String resumeId, String resumeName) async {
    try {
      await _usersCollection.doc(userId).update({
        'uploadedResumes': FieldValue.arrayUnion([
          {
            'id': resumeId,
            'name': resumeName,
            'createdAt': FieldValue.serverTimestamp(),
          }
        ]),
      });
    } catch (e) {
      print('Error adding user resume: $e');
      throw e;
    }
  }

  // Remove resume from user's profile
  Future<void> removeUserResume(String userId, String resumeId) async {
    try {
      // First get the current resume list
      DocumentSnapshot doc = await _usersCollection.doc(userId).get();
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        List<dynamic> resumes = data['uploadedResumes'] ?? [];

        // Find and remove the resume with matching ID
        List<dynamic> updatedResumes =
            resumes.where((resume) => resume['id'] != resumeId).toList();

        // Update the user document
        await _usersCollection.doc(userId).update({
          'uploadedResumes': updatedResumes,
        });
      }
    } catch (e) {
      print('Error removing user resume: $e');
      throw e;
    }
  }

  // Verify a user (for trusted contributors)
  Future<void> verifyUser(String userId) async {
    try {
      await _usersCollection.doc(userId).update({
        'isVerified': true,
      });
    } catch (e) {
      print('Error verifying user: $e');
      throw e;
    }
  }

  // Get top contributors (for leaderboard)
  Future<List<User>> getTopContributors({int limit = 10}) async {
    try {
      QuerySnapshot query = await _usersCollection
          .orderBy('reputation', descending: true)
          .limit(limit)
          .get();

      return query.docs.map((doc) {
        return User.fromFirestore(
          doc,
        );
      }).toList();
    } catch (e) {
      print('Error getting top contributors: $e');
      return [];
    }
  }
}
