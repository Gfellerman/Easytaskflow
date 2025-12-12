import 'package:easy_task_flow/models/user_model.dart';
import 'package:easy_task_flow/services/database_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

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
    // TODO: Implement Sign in with Apple
    throw UnimplementedError('Sign in with Apple is not yet implemented.');
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
