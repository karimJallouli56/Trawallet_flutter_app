import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential?> signUpWithEmail({
    required String email,
    required String password,
    required String username,
    required String name,
    required String phone,
    required String country,
    required String gender,
  }) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      final uid = userCredential.user!.uid;
      final userData = {
        "id": uid,
        "username": username,
        "name": name,
        "email": email,
        "phone": phone,
        "country": country,
        "gender": gender,
        "userAvatar": gender == 'Female'
            ? 'https://nydkmuqxbdmosymchola.supabase.co/storage/v1/object/public/post-images/avatars/avatar_default_women.png'
            : 'https://nydkmuqxbdmosymchola.supabase.co/storage/v1/object/public/post-images/avatars/avatar_default_man.png',
        "bio": "",
        "interests": [],
        "visitedCountries": 0,
        "travelStory": "",
        "points": 100,
        "createdAt": FieldValue.serverTimestamp(),
        "updatedAt": FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .set(userData);

      return userCredential;
    } catch (e) {
      throw Exception("Signup failed: $e");
    }
  }

  Future<UserCredential?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Sign in with Google
  // Future<UserCredential?> signInWithGoogle() async {
  //   try {
  //     final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
  //     if (googleUser == null) return null;

  //     final GoogleSignInAuthentication googleAuth =
  //         await googleUser.authentication;

  //     final credential = GoogleAuthProvider.credential(
  //       accessToken: googleAuth.accessToken,
  //       idToken: googleAuth.idToken,
  //     );

  //     return await _auth.signInWithCredential(credential);
  //   } catch (e) {
  //     throw 'Google sign-in failed: $e';
  //   }
  // }

  // Sign out
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  // Reset password
  // Future<void> resetPassword(String email) async {
  //   try {
  //     await _auth.sendPasswordResetEmail(email: email);
  //   } on FirebaseAuthException catch (e) {
  //     throw _handleAuthException(e);
  //   }
  // }

  // Delete account
  Future<void> deleteAccount() async {
    try {
      User? user = _auth.currentUser;
      if (user == null) {
        throw 'No user is currently signed in';
      }

      // If user signed in with Google, sign out from Google as well
      if (user.providerData.any((info) => info.providerId == 'google.com')) {
        await _googleSignIn.signOut();
      }

      // Delete the user account
      await user.delete();
    } on FirebaseAuthException catch (e) {
      // If the user needs to re-authenticate
      if (e.code == 'requires-recent-login') {
        throw 'Please sign in again before deleting your account';
      }
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Failed to delete account: $e';
    }
  }

  Future<void> reauthenticateWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) throw 'No user is currently signed in';

      AuthCredential credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );

      await user.reauthenticateWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Re-authenticate with Google
  // Future<void> reauthenticateWithGoogle() async {
  //   try {
  //     User? user = _auth.currentUser;
  //     if (user == null) throw 'No user is currently signed in';

  //     final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
  //     if (googleUser == null) throw 'Google sign-in cancelled';

  //     final GoogleSignInAuthentication googleAuth =
  //         await googleUser.authentication;

  //     final credential = GoogleAuthProvider.credential(
  //       accessToken: googleAuth.accessToken,
  //       idToken: googleAuth.idToken,
  //     );

  //     await user.reauthenticateWithCredential(credential);
  //   } catch (e) {
  //     throw 'Re-authentication failed: $e';
  //   }
  // }

  // Handle Firebase Auth exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'An account already exists for that email.';
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'invalid-email':
        return 'The email address is invalid.';
      case 'requires-recent-login':
        return 'Please sign in again to complete this action.';
      case 'user-disabled':
        return 'This account has been disabled.';
      default:
        return 'An error occurred. Please try again.';
    }
  }
}
