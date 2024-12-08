import 'package:flutter/material.dart';
import 'EditQuestion.dart';

class QuestionEditDialog extends StatelessWidget {
  final Map<String, dynamic>? question;
  final Function(Map<String, dynamic>) onSubmit;

  const QuestionEditDialog({
    Key? key,
    this.question,
    required this.onSubmit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return EditQuestion(
      initialType: question?['type'] ?? 'Multiple Choice',
      initialQuestion: question?['question'] ?? '',
      initialOptions: List<String>.from(question?['options'] ?? []),
      initialCorrectAnswer: question?['correctAnswer'],
      initialGrade: (question?['Questiongrade'] ?? 0).toString(),
      imageUrl: question?['imageUrl'],
      onEditQuestion:
          (type, questionText, options, correctAnswer, grade, imageUrl) {
        final newQuestionData = {
          'questionId': question?['questionId'] ??
              DateTime.now().millisecondsSinceEpoch.toString(),
          'type': type,
          'question': questionText,
          'options': options,
          'correctAnswer': correctAnswer,
          'Questiongrade': int.tryParse(grade) ?? 0,
          'imageUrl': imageUrl,
        };
        onSubmit(newQuestionData);
      },
    );
  }
}

void showEditQuestionDialog(BuildContext context, Map<String, dynamic> question,
    Function(Map<String, dynamic>) onSubmit) {
  showDialog(
    context: context,
    builder: (context) => QuestionEditDialog(
      question: question,
      onSubmit: onSubmit,
    ),
  );
}
