import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/popup.dart';
import 'package:project_444/pages/models/user.dart';

Future<void> registerUser(
    BuildContext context,
    TextEditingController nameController,
    TextEditingController emailController,
    TextEditingController passwordController) async {
  final String name = nameController.text.trim();
  final String email = emailController.text.trim();
  final String password = passwordController.text.trim();
  List<String> errors = [];

  if (name.isEmpty) {
    errors.add("Name cannot be empty");
  }
  if (email.isEmpty) {
    errors.add("Email cannot be empty");
  }
  if (password.isEmpty) {
    errors.add("Password cannot be empty");
  }

  if (errors.isNotEmpty) {
    showErrorDialog(context, errors.join('\n'));
    return;
  }

  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  try {
    print('Registering user...');
    UserCredential userCredential = await auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    Users user = Users(
      id: userCredential.user!.uid,
      name: name,
      email: email,
      role: 'student',
    );

    await firestore.collection('users').doc(user.id).set({
      'name': user.name,
      'email': user.email,
      'role': user.role,
    });

    showMessagealert(context, "Registration successful!");
  } catch (e) {
    print('Error registering user: $e');
    String errorMessage;
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'weak-password':
          errorMessage = "The password provided is too weak.";
          break;
        case 'email-already-in-use':
          errorMessage = "The account already exists for that email.";
          break;
        default:
          errorMessage = "Registration failed. Please try again.";
      }
    } else {
      errorMessage = "An unknown error occurred. Please try again.";
    }

    showErrorDialog(context, errorMessage);
  }
}
