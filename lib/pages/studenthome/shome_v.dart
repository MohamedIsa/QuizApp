import 'package:flutter/material.dart';

class Studenthome extends StatelessWidget {
  const Studenthome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Home'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              child: const Text.rich(
                TextSpan(
                  children: <TextSpan>[
                    TextSpan(
                      text: 'Welcome to the Student Home Page!\n',
                      style: TextStyle(fontSize: 24),
                    ),
                    TextSpan(
                      text: 'This is the home page for the student',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.0),
                color: Colors.blue,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {},
                  borderRadius: BorderRadius.circular(16.0),
                  child: Ink(
                    padding: const EdgeInsets.all(16.0),
                    child: const Center(
                      child: Text(
                        'Student Home',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
