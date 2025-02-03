import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:quizapp/utils/popup.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> forgetpassword(
    BuildContext context, TextEditingController email) async {
  try {
    if (email.text.isEmpty) {
      showErrorDialog(context, 'Cannot be Empty');
      return;
    }
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email.text)
        .get();

    if (userDoc.docs.isEmpty) {
      showErrorDialog(context, 'Email not found in the users collection.');
      return;
    }
    await FirebaseAuth.instance.sendPasswordResetEmail(email: email.text);
    showMessagealert(context, 'Password reset email sent!');
    Navigator.of(context).pushReplacementNamed('/login');
  } catch (e) {
    showErrorDialog(context, 'Failed to send password reset email: $e');
  }
}
