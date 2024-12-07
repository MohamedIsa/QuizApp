import 'package:flutter/material.dart';

class StudentExamSession extends StatefulWidget {
  final String examId; // Define examId as a property

  const StudentExamSession({Key? key, required this.examId}) : super(key: key);

  @override
  State<StudentExamSession> createState() => _StudentExamSessionState();
}

class _StudentExamSessionState extends State<StudentExamSession> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exam Session'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Exam ID:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              widget.examId, // Access examId from the widget
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
