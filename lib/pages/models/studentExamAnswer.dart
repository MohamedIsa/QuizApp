class StudentExamAnswer {
  final String Sid;
  final String Semail;
  final List<Map<String, dynamic>> answers; // List of answers
  final String examId;

  StudentExamAnswer({
    required this.Sid,
    required this.Semail,
    required this.answers,
    required this.examId,
  });

  Map<String, dynamic> toMap() {
    return {
      'Sid': Sid,
      'Semail': Semail,
      'answers': answers,
      'examId': examId,
    };
  }
}
