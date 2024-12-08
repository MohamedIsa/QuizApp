// This Page is Blocked due to user's attempts
// So user can't go into the exam from (Search Student area)

import 'package:flutter/material.dart';

class StudentExamSession extends StatelessWidget {
  final String examId;

  const StudentExamSession({Key? key, required this.examId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Exam Session')),
      body: Center(
        child: Text('Exam ID: $examId'),
      ),
    );
  }
}
