import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user.dart' as app_user;

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // SharedPreferences keys
  static const String _userKey = 'current_user';
  static const String _authStateKey = 'auth_state';

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with email and password
  Future<UserCredential> signInWithEmailPassword(
      String email, String password) async {
    try {
      final UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Get user profile and save to SharedPreferences
      final app_user.User? userProfile =
          await getUserProfile(userCredential.user!.uid);
      if (userProfile != null) {
        await _saveUserToPrefs(userProfile);
        await _saveAuthState(true);
      }

      return userCredential;
    } catch (e) {
      rethrow;
    }
  }

  // Register with email and password
  Future<UserCredential> registerWithEmailPassword(
    String email,
    String password,
    String name,
  ) async {
    try {
      // Create the user in Firebase Auth
      final UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update the user's display name
      await userCredential.user?.updateDisplayName(name);

      // Create user profile in Firestore
      await _createUserProfile(
        userCredential.user!.uid,
        name,
        email,
        userCredential.user!.photoURL,
      );

      // Get and save user profile to SharedPreferences
      final app_user.User? userProfile =
          await getUserProfile(userCredential.user!.uid);
      if (userProfile != null) {
        await _saveUserToPrefs(userProfile);
        await _saveAuthState(true);
      }

      return userCredential;
    } catch (e) {
      rethrow;
    }
  }

  // Sign in with Google
  Future<UserCredential> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        throw Exception('Google sign in aborted');
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      // Check if this is a new user
      final bool isNewUser =
          userCredential.additionalUserInfo?.isNewUser ?? false;

      if (isNewUser) {
        // Create user profile in Firestore for new users
        await _createUserProfile(
          userCredential.user!.uid,
          userCredential.user!.displayName ?? 'User',
          userCredential.user!.email ?? '',
          userCredential.user!.photoURL,
        );
      }

      // Get and save user profile to SharedPreferences
      final app_user.User? userProfile =
          await getUserProfile(userCredential.user!.uid);
      if (userProfile != null) {
        print("username ------------------------${userProfile.name}");
        await _saveUserToPrefs(userProfile);
        await _saveAuthState(true);
      }

      return userCredential;
    } catch (e) {
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();

      // Clear user data from SharedPreferences
      await _clearUserFromPrefs();
      await _saveAuthState(false);
    } catch (e) {
      rethrow;
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // Create user profile in Firestore
  Future<void> _createUserProfile(
    String uid,
    String name,
    String email,
    String? photoUrl,
  ) async {
    final app_user.User user = app_user.User(
        id: uid,
        name: name,
        email: email,
        photoUrl: photoUrl ?? "",
        reputation: 1,
        createdAt: DateTime.now(),
        contributions: [],
        savedCompanies: [],
        savedResumes: []);

    await _firestore.collection('users').doc(uid).set(user.toFirestore());

    // Save user to SharedPreferences
    await _saveUserToPrefs(user);
  }

  // Get user profile with SharedPreferences cache
  Future<app_user.User?> getUserProfile(String uid) async {
    try {
      // First check if user is in SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final String? userData = prefs.getString(_userKey);

      if (userData != null) {
        return app_user.User.fromPrefs(userData);
      }

      // If not in SharedPreferences, get from Firestore
      final DocumentSnapshot doc =
          await _firestore.collection('users').doc(uid).get();

      if (doc.exists) {
        final app_user.User user = app_user.User.fromFirestore(doc);

        // Save to SharedPreferences for future use
        await _saveUserToPrefs(user);

        return user;
      }

      return null;
    } catch (e) {
      rethrow;
    }
  }

  // Update user profile
  Future<void> updateUserProfile(app_user.User user) async {
    try {
      await _firestore
          .collection('users')
          .doc(user.id)
          .update(user.toFirestore());

      // Update display name in Firebase Auth if it has changed
      if (_auth.currentUser != null &&
          _auth.currentUser!.displayName != user.name) {
        await _auth.currentUser!.updateDisplayName(user.name);
      }

      // Update user in SharedPreferences
      await _saveUserToPrefs(user);
    } catch (e) {
      rethrow;
    }
  }

  // Save user to SharedPreferences
  Future<void> _saveUserToPrefs(app_user.User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userKey, jsonEncode(user.toFirestore()));
    } catch (e) {
      print('Error saving user to SharedPreferences: $e');
    }
  }

  // Clear user from SharedPreferences
  Future<void> _clearUserFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userKey);
    } catch (e) {
      print('Error clearing user from SharedPreferences: $e');
    }
  }

  // Save authentication state
  Future<void> _saveAuthState(bool isAuthenticated) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_authStateKey, isAuthenticated);
    } catch (e) {
      print('Error saving auth state to SharedPreferences: $e');
    }
  }

  // Check if user is authenticated from SharedPreferences
  Future<bool> isUserAuthenticated() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_authStateKey) ?? false;
    } catch (e) {
      print('Error checking auth state from SharedPreferences: $e');
      return false;
    }
  }

  // Get cached user from SharedPreferences
  Future<app_user.User?> getCachedUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? userData = prefs.getString(_userKey);

      if (userData != null) {
        return app_user.User.fromPrefs(userData);
      }

      return null;
    } catch (e) {
      print('Error getting cached user from SharedPreferences: $e');
      return null;
    }
  }
}
