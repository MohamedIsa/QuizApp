import 'package:flutter/material.dart';

class StudentQuestionWidget extends StatelessWidget {
  final String examName;
  final String questionText;
  final String questionType;
  final String questionId; // Fetch QuestionID
  final VoidCallback onTap; // for tap use

  const StudentQuestionWidget({
    Key? key,
    required this.examName,
    required this.questionText,
    required this.questionType,
    required this.questionId,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Display the exam name
          Text(
            examName,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          // Display the question
          Text(
            questionText,
            style: const TextStyle(fontSize: 16),
          ),
          // Display the question type
          Text(
            'Type: $questionType',
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
      onTap: onTap, // Open exam when user click on question
    );
  }
}
