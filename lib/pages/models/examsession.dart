class ExamSession {
  final String sessionId;
  final String studentEmail;
  final String examId;
  final DateTime examStartTime;
  final int examDuration;
  final int timeElapsed;
  final String status;

  ExamSession({
    required this.sessionId,
    required this.studentEmail,
    required this.examId,
    required this.examStartTime,
    required this.examDuration,
    required this.timeElapsed,
    required this.status,
  });

  factory ExamSession.fromFirestore(
      Map<String, dynamic> data, String documentId) {
    return ExamSession(
      sessionId: documentId,
      studentEmail: data['studentEmail'] ?? '',
      examId: data['examId'] ?? '',
      examStartTime: DateTime.parse(data['examStartTime'] ?? ''),
      examDuration: data['examDuration'] ?? 0,
      timeElapsed: data['timeElapsed'] ?? 0,
      status: data['status'] ?? 'in-progress',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'studentEmail': studentEmail,
      'examId': examId,
      'examStartTime': examStartTime.toIso8601String(),
      'examDuration': examDuration,
      'timeElapsed': timeElapsed,
      'status': status,
    };
  }
}
