import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../pages/login/user_data.dart';

Future<void> signInWithGoogle(BuildContext context) async {
  try {
    final GoogleSignIn googleSignIn =
        GoogleSignIn(clientId: OauthCredential.clientId);

    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    if (googleUser == null) {
      return;
    }

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final UserCredential userCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);

    final User? firebaseUser = userCredential.user;
    if (firebaseUser != null) {
      String? userRole = await getUserRole(firebaseUser.uid);
      if (userRole != null) {
        UserData.setUserData(
            firebaseUser.email ?? '', firebaseUser.displayName ?? '', userRole);
        if (userRole == 'student') {
          Navigator.pushReplacementNamed(context, '/dashboard');
        } else {
          Navigator.pushReplacementNamed(context, '/completeProfile');
        }
      }
    }
  } catch (e) {
    print(e.toString());
  }
}

Future<String?> getUserRole(String uid) async {
  try {
    DocumentSnapshot userSnapshot =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();

    if (userSnapshot.exists) {
      Map<String, dynamic> userData =
          userSnapshot.data() as Map<String, dynamic>;

      if (userData.containsKey('role')) {
        return userData['role'];
      }
    }

    return null;
  } catch (e) {
    print("Error getting user role: $e");
    return null;
  }
}
