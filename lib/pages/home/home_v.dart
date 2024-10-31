import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
        backgroundColor: Colors.green,
      ),
      body: Column(
        children: [
          const Text(
            'Welcome to the Home Page!',
            style: TextStyle(fontSize: 24),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/login');
            },
            child: const Text('Go to Login Page'),
          ),
        ],
      ),
    );
  }
}
