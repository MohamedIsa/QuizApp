class StudentAnswer {
  final String studentEmail;
  final String examId;
  final List<Map<String, dynamic>> answers;
  final String status;
  final DateTime submittedAt;

  StudentAnswer({
    required this.studentEmail,
    required this.examId,
    required this.answers,
    required this.status,
    required this.submittedAt,
  });

  factory StudentAnswer.fromFirestore(Map<String, dynamic> data) {
    return StudentAnswer(
      studentEmail: data['studentEmail'] ?? '',
      examId: data['examId'] ?? '',
      answers: List<Map<String, dynamic>>.from(data['answers'] ?? []),
      status: data['status'] ?? 'in-progress',
      submittedAt: DateTime.parse(data['submittedAt'] ?? ''),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'studentEmail': studentEmail,
      'examId': examId,
      'answers': answers,
      'status': status,
      'submittedAt': submittedAt.toIso8601String(),
    };
  }
}
