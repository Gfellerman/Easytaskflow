import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:easy_task_flow/models/user_model.dart';
import 'package:easy_task_flow/services/database_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final DatabaseService _databaseService = DatabaseService();

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      // Re-throw the exception to be caught by the UI
      throw e;
    }
  }

  Future<User?> signUpWithEmailAndPassword(
    String email,
    String password,
    String name,
    String phoneNumber,
  ) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = result.user;
      if (user != null) {
        await user.updateDisplayName(name);
        final newUser = UserModel(
          userId: user.uid,
          name: name,
          email: email,
          phoneNumber: phoneNumber,
          profilePictureUrl: '',
        );
        await _databaseService.createUser(newUser);
      }
      return user;
    } on FirebaseAuthException catch (e) {
      // Re-throw the exception to be caught by the UI
      throw e;
    }
  }

  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // User cancelled the sign-in
        return null;
      }
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final result = await _auth.signInWithCredential(credential);
      final user = result.user;
      if (user != null) {
        final userExists = await _databaseService.doesUserExist(user.uid);
        if (!userExists) {
          final newUser = UserModel(
            userId: user.uid,
            name: user.displayName ?? '',
            email: user.email ?? '',
            phoneNumber: user.phoneNumber ?? '',
            profilePictureUrl: user.photoURL ?? '',
          );
          await _databaseService.createUser(newUser);
        }
      }
      return user;
    } on FirebaseAuthException catch (e) {
      // Re-throw the exception to be caught by the UI
      throw e;
    }
  }

  Future<User?> signInWithApple() async {
    try {
      if (kIsWeb) {
        final appleProvider = AppleAuthProvider();
        final result = await _auth.signInWithPopup(appleProvider);
        final user = result.user;
        if (user != null) {
          await _ensureUserInDatabase(user);
        }
        return user;
      }

      // Generate a random nonce
      final rawNonce = _generateNonce();
      final nonce = _sha256ofString(rawNonce);

      // Request credential for the default Sign in with Apple request
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      // Create an OAuth Credential for Firebase
      final OAuthCredential credential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
        rawNonce: rawNonce,
      );

      // Sign in with Firebase
      final result = await _auth.signInWithCredential(credential);
      final user = result.user;

      if (user != null) {
        // Check if we need to create the user in our database
        // Apple only returns the name on the first sign in, so we check appleCredential
        String? name;
        if (appleCredential.givenName != null) {
          name = '${appleCredential.givenName} ${appleCredential.familyName ?? ''}'.trim();
        }
        await _ensureUserInDatabase(user, name: name);
      }

      return user;
    } catch (e) {
      // Re-throw or handle
      print('Error signing in with Apple: $e');
      throw e;
    }
  }

  // Helper to ensure user exists in DB
  Future<void> _ensureUserInDatabase(User user, {String? name}) async {
    final userExists = await _databaseService.doesUserExist(user.uid);
    if (!userExists) {
      final newUser = UserModel(
        userId: user.uid,
        name: name ?? user.displayName ?? '',
        email: user.email ?? '',
        phoneNumber: user.phoneNumber ?? '',
        profilePictureUrl: user.photoURL ?? '',
      );
      await _databaseService.createUser(newUser);
    }
  }

  // Helper methods for Nonce
  String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<User?> signInWithX() async {
    try {
      final TwitterAuthProvider twitterProvider = TwitterAuthProvider();
      final UserCredential result =
          await _auth.signInWithProvider(twitterProvider);
      final user = result.user;
      if (user != null) {
        final userExists = await _databaseService.doesUserExist(user.uid);
        if (!userExists) {
          final newUser = UserModel(
            userId: user.uid,
            name: user.displayName ?? '',
            email: user.email ?? '',
            phoneNumber: user.phoneNumber ?? '',
            profilePictureUrl: user.photoURL ?? '',
          );
          await _databaseService.createUser(newUser);
        }
      }
      return user;
    } on FirebaseAuthException catch (e) {
      // Re-throw the exception to be caught by the UI
      throw e;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
