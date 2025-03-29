import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart' as app_user;

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with email and password
  Future<UserCredential> signInWithEmailPassword(
      String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
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

      return userCredential;
    } catch (e) {
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
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
        reputation: 0,
        createdAt: DateTime.now(),
        contributions: [],
        savedCompanies: [],
        savedResumes: []);

    await _firestore.collection('users').doc(uid).set(user.toFirestore());
  }

  // Get user profile
  Future<app_user.User?> getUserProfile(String uid) async {
    try {
      final DocumentSnapshot doc =
          await _firestore.collection('users').doc(uid).get();

      if (doc.exists) {
        return app_user.User.fromFirestore(doc);
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
    } catch (e) {
      rethrow;
    }
  }
}
