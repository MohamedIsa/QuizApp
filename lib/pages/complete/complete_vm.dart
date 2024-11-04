import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";

import "../../utils/popup.dart";

Future<void> completeProfile(
    BuildContext context, TextEditingController name) async {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  try {
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      await firestore.collection('users').doc(currentUser.uid).set(
        {
          'email': currentUser.email,
          'name': name.text,
          'role': 'student',
        },
        SetOptions(merge: true),
      );

      Navigator.of(context).pushReplacementNamed('/dashboard');
    } else {
      showErrorDialog(context, 'No user is currently signed in.');
    }
  } catch (e) {
    print('Failed to update user: $e');
    showErrorDialog(context, e.toString());
  }
}
