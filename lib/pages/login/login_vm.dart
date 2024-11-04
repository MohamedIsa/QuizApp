import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/popup.dart';
import 'package:project_444/pages/models/userlogin.dart';

Future<void> signin(BuildContext context, TextEditingController email,
    TextEditingController password) async {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  try {
    UserCredential userCredential = await auth.signInWithEmailAndPassword(
      email: email.text,
      password: password.text,
    );

    DocumentSnapshot userDoc =
        await firestore.collection('users').doc(userCredential.user!.uid).get();
    LoginUser loginUser;

    if (userDoc.exists) {
      loginUser = LoginUser(
        id: userCredential.user!.uid,
        email: userDoc['email'],
        role: userDoc['role'],
      );
    } else {
      loginUser = LoginUser(
        id: userCredential.user!.uid,
        email: email.text,
        role: 'student',
      );
    }

    // Update Firestore with login user data
    await firestore.collection('users').doc(loginUser.id).set(
        {
          'email': loginUser.email,
          'role': loginUser.role,
        },
        SetOptions(
            merge: true)); // Using merge to preserve existing fields like name

    showMessagealert(context, "Login successful!");
    Navigator.of(context).pushReplacementNamed('/dashboard');
  } catch (e) {
    print('Error logging in: $e');
    String errorMessage;
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No user found for that email.';
          break;
        case 'wrong-password':
          errorMessage = 'Wrong password provided for that user.';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email provided.';
          break;
        default:
          errorMessage = 'An error occurred.';
          break;
      }
    } else {
      errorMessage = 'An error occurred.';
    }
    showErrorDialog(context, errorMessage);
  }
}
