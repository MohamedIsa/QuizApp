import 'package:flutter/material.dart';
import 'package:project_444/pages/home/homeV.dart';
import 'package:project_444/utils/loading.dart';

import 'pages/login/loginV.dart';
import 'pages/signup/signupV.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    initialRoute: '/',
    routes: {
      '/': (context) => const Loading(),
      '/home': (context) => const HomePage(),
      '/login': (context) => LoginPage(),
      '/signup': (context) => SignUp(),
    },
  ));
}
