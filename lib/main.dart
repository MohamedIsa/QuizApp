import 'package:flutter/material.dart';
import 'package:project_444/home.dart';
import 'package:project_444/utils/loading.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    initialRoute: '/',
    routes: {
      '/': (context) => const Loading(),
      '/home': (context) => const HomePage()
    },
  ));
}
