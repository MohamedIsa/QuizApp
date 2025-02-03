import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/popup.dart';
import '../../pages/models/user.dart';
import 'package:quizapp/pages/login/user_data.dart'; // Import the UserData class

//===================================================================
// SignIn function
//===================================================================
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
    Users loginUser;

    if (userDoc.exists) {
      loginUser = Users.fromFirestore(
          userDoc.data() as Map<String, dynamic>, userCredential.user!.uid);
    } else {
      loginUser = Users(
        id: userCredential.user!.uid,
        name: '',
        email: email.text,
        role: 'student',
      );
    }

    UserData.setUserData(loginUser.email, loginUser.name, loginUser.role);

    await firestore.collection('users').doc(loginUser.id).set({
      'email': loginUser.email,
      'role': loginUser.role,
    }, SetOptions(merge: true));

    showMessagealert(context, "Login successful!");

    if (loginUser.role == 'admin') {
      Navigator.of(context).pushReplacementNamed('/admindashboard');
    } else {
      Navigator.of(context).pushReplacementNamed('/dashboard');
    }
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
