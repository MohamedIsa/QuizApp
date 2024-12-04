class Question {
  final String questionId;
  final String questionText;
  final String questionType;
  final String grade;
  final String? imageUrl;

  Question({
    required this.questionId,
    required this.questionText,
    required this.questionType,
    required this.grade,
    this.imageUrl,
  });

  factory Question.fromFirestore(Map<String, dynamic> data, String documentId) {
    return Question(
      questionId: documentId,
      questionText: data['questionText'] ?? '',
      questionType: data['questionType'] ?? '',
      grade: data['grade'] ?? '',
      imageUrl: data['imageUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'questionText': questionText,
      'questionType': questionType,
      'grade': grade,
      'imageUrl': imageUrl,
    };
  }
}
