import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hackathon/admin_home.dart';
import 'package:hackathon/service_home.dart';

import '../user_home.dart';


class AuthServices {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> sendEmailVerification() async {
    try {
      await _auth.currentUser?.sendEmailVerification();
    } catch (e) {
      if (kDebugMode) {
        print("Email verification error: $e");
      }
    }
  }

  Future<UserCredential?> loginWithGoogle() async {
    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return null;

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      if (kDebugMode) {
        print("Google login error: $e");
      }
      return null;
    }
  }

  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();
      if (gUser == null) {
        throw FirebaseAuthException(
          code: 'ERROR_ABORTED_BY_USER',
          message: 'Sign-in aborted by user',
        );
      }

      final GoogleSignInAuthentication gAuth = await gUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: gAuth.accessToken,
        idToken: gAuth.idToken,
      );

      UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      User? user = userCredential.user;

      if (user != null) {
        // Ensure email is non-null
        if (user.email == null) {
          throw FirebaseAuthException(
            code: 'ERROR_NO_EMAIL',
            message: 'No email found for this user',
          );
        }

        // Fetch user role from Firestore
        DocumentSnapshot userRoleDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.email)
            .get();

        if (!userRoleDoc.exists) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("User role not found. Contact admin.")),
          );
          return;
        }

        String? role = userRoleDoc['role'] as String?;
        if (role == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Invalid role for user.")),
          );
          return;
        }

        // Navigate based on role
        if (role == 'User') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) =>  UserHome()),
          );
        } else if (role == 'Admin') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const AdminHome()),
          );
        } else if (role == 'Service') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) =>  ServiceHome()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Invalid user role.")),
          );
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error during Google sign-in: $e');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error during Google sign-in: ${e.toString()}")),
      );
    }
  }
}
