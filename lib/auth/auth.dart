import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Auth {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<String> signInUser(String email, String password) async {
    try {
      // Sign in the user
      final UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User user = userCredential.user!;

      // Query Firestore for user data
      final QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: user.email)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final DocumentSnapshot userData = querySnapshot.docs.first;
        final String role = userData.get('userType');
        return role;
      } else {
        throw Exception('User data not found.');
      }
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleSignInError(e));
    } catch (e) {
      throw Exception('An unexpected error occurred. Please try again.');
    }
  }

  String _handleSignInError(FirebaseAuthException e) {
    if (e.code == 'user-not-found') {
      return 'Email not found. Please check your email and try again.';
    } else if (e.code == 'invalid-credential') {
      return 'Incorrect password. Please try again.';
    } else if (e.code == 'too-many-requests') {
      return 'Too many attempts. Try again later.';
    } else if (e.code == 'invalid-email') {
      return 'The email address is invalid. Please enter a correct email.';
    } else if (e.code == 'channel-error') {
      return 'Please provide a valid email or password.';
    } else {
      return 'Connection Timed Out.... Please try again later.';
    }
  }

  // Sign Up Method
  Future<String> signUpUser(
      String email, String password, String username, String userType) async {
    try {
      final UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final String uid = userCredential.user!.uid;

      await _firestore.collection('users').doc().set({
        'uid': uid,
        'username': username,
        'email': email,
        'userType': userType,
        'first_name': '',
        'last_name': '',
        'location': '',
        'hourly_rate': '',
        'description': '',
        'headline': '',
        'skills': '',
      });

      return userType;
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleSignUpError(e));
    } catch (e) {
      throw Exception('An unexpected error occurred. Please try again.');
    }
  }

  String _handleSignUpError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'This email is already in use. Please use a different email.';
      case 'weak-password':
        return 'The password is too weak. Please use a stronger password.';
      case 'invalid-email':
        return 'Invalid email address. Please enter a valid email.';
      default:
        return 'An unexpected error occurred. Please try again later.';
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
