import '../../pages/models/questions.dart';

class Exam {
  final String examId;
  final String examName;
  final List<Question> questions;
  final int examDuration;
  final DateTime startTime;
  final DateTime endTime;

  Exam({
    required this.examId,
    required this.examName,
    required this.questions,
    required this.examDuration,
    required this.startTime,
    required this.endTime,
  });

  factory Exam.fromFirestore(Map<String, dynamic> data, String documentId) {
    return Exam(
      examId: documentId,
      examName: data['examName'] ?? '',
      questions: (data['questions'] as List<dynamic>?)
              ?.map((questionData) => Question.fromFirestore(
                  questionData, questionData['questionId']))
              .toList() ??
          [],
      examDuration: data['examDuration'] ?? 0,
      startTime: DateTime.parse(data['startTime'] ?? ''),
      endTime: DateTime.parse(data['endTime'] ?? ''),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'examName': examName,
      'questions': questions.map((question) => question.toMap()).toList(),
      'examDuration': examDuration,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
    };
  }
}
