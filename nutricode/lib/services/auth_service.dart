import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/services.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;

  AuthService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    GoogleSignIn? googleSignIn,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  // Auth state changes stream
  Stream<User?> get userStateChanges => _auth.authStateChanges();

  // Current user
  User? get currentUser => _auth.currentUser;

  // Get user data from Firestore
  Future<UserModel?> getUserData() async {
    if (currentUser == null) return null;
    final doc = await _firestore.collection('users').doc(currentUser!.uid).get();
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }

  // Update user profile in Firestore
  Future<void> updateProfile({
    String? name,
    String? photoUrl,
    bool? isVegan,
    List<String>? allergens,
  }) async {
    if (currentUser == null) return;
    
    Map<String, dynamic> updates = {};
    if (name != null) {
      final trimmedName = name.trim();
      if (trimmedName.isEmpty) throw 'Name cannot be empty.';

      // Check if this name is taken by another user
      final nameCheck = await _firestore
          .collection('users')
          .where('name', isEqualTo: trimmedName)
          .get();

      if (nameCheck.docs.isNotEmpty && nameCheck.docs.first.id != currentUser!.uid) {
        throw "The name '$trimmedName' is already being used by another member. Please choose a unique one!";
      }
      updates['name'] = trimmedName;
    }
    if (photoUrl != null) updates['photoUrl'] = photoUrl;
    if (isVegan != null) updates['isVegan'] = isVegan;
    if (allergens != null) updates['allergens'] = allergens;

    if (updates.isNotEmpty) {
      await _firestore.collection('users').doc(currentUser!.uid).update(updates);
    }
  }

  // Convert profile picture to base64 data URI (stored in Firestore)
  Future<String> uploadProfilePicture(File file) async {
    if (currentUser == null) throw 'User not logged in';

    final bytes = await file.readAsBytes();
    final base64String = base64Encode(bytes);
    return 'data:image/jpeg;base64,$base64String';
  }

  // Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // User canceled the sign-in

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Once signed in, return the UserCredential
      UserCredential userCredential = await _auth.signInWithCredential(credential);

      // Update/Create user profile in Firestore
      if (userCredential.user != null) {
        final userDoc = await _firestore.collection('users').doc(userCredential.user!.uid).get();
        
        if (!userDoc.exists) {
          // New user: create the document with Google profile info
          await _firestore.collection('users').doc(userCredential.user!.uid).set({
            'name': userCredential.user!.displayName ?? 'Google User',
            'email': userCredential.user!.email,
            'lastSeen': FieldValue.serverTimestamp(),
            'uid': userCredential.user!.uid,
            'isVegan': false,
            'allergens': [],
          });
        } else {
          // Existing user: only update the last seen timestamp
          await _firestore.collection('users').doc(userCredential.user!.uid).update({
            'lastSeen': FieldValue.serverTimestamp(),
          });
        }
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } on PlatformException catch (e) {
      if (e.code == '10' || e.code == 'DEVELOPER_ERROR') {
        throw 'Google Sign-In Error: Developer Error (10). This usually means your SHA-1 fingerprint is missing in Firebase or the project is misconfigured.';
      }
      throw 'Google Sign-In failed (${e.code}): ${e.message}';
    } catch (e) {
      if (e is String) rethrow;
      print("Google Sign In Error: $e");
      throw 'An unexpected error occurred during Google sign-in.';
    }
  }

  // Sign up with email & password
  Future<UserCredential?> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final trimmedName = name.trim();
      if (trimmedName.isEmpty) throw 'Name cannot be empty.';

      // Check if username is already taken
      final nameCheck = await _firestore
          .collection('users')
          .where('name', isEqualTo: trimmedName)
          .get();

      if (nameCheck.docs.isNotEmpty) {
        throw "Oops! The username '$trimmedName' is already taken. How about trying a different one?";
      }

      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create user profile in Firestore
      if (userCredential.user != null) {
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'name': name,
          'email': email,
          'createdAt': FieldValue.serverTimestamp(),
          'uid': userCredential.user!.uid,
          'isVegan': false,
          'allergens': [],
        });
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      if (e is String) rethrow;
      throw 'An unexpected error occurred during registration.';
    }
  }

  // Sign in with email/username & password
  Future<UserCredential?> signIn({
    required String emailOrUsername,
    required String password,
  }) async {
    String email = emailOrUsername.trim();

    try {
      // Check if it's a username (doesn't contain '@')
      if (!email.contains('@')) {
        final querySnapshot = await _firestore
            .collection('users')
            .where('name', isEqualTo: email)
            .limit(1)
            .get();

        if (querySnapshot.docs.isEmpty) {
          throw 'No account found with that username.';
        }
        email = querySnapshot.docs.first.get('email');
      }

      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      if (e is String) rethrow;
      throw 'Incorrect email/username or password.';
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      // Check if email exists in our Firestore users collection
      final query = await _firestore
          .collection('users')
          .where('email', isEqualTo: email.trim())
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        throw 'No account found with this email address.';
      }

      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      if (e is String) rethrow;
      throw 'An unexpected error occurred. Please try again.';
    }
  }

  // Helper to handle Firebase Auth exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'invalid-credential':
        return 'Incorrect email/username or password.';
      case 'email-already-in-use':
        return "This email is already part of the NutriCode family! Try logging in or resetting your password if you've forgotten it.";
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'network-request-failed':
        return 'Check your internet connection and try again.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      default:
        return e.message ?? 'Authentication failed. Please try again.';
    }
  }
}

