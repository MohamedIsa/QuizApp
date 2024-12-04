class Question {
  final String questionId;
  final String questionText;
  final String questionType;
  final String grade;
  final String? imageUrl;
  final String? correctAnswer;
  final List<String>? options;

  Question({
    required this.questionId,
    required this.questionText,
    required this.questionType,
    required this.grade,
    this.imageUrl,
    this.correctAnswer,
    this.options,
  });

  factory Question.fromFirestore(Map<String, dynamic> data, String documentId) {
    return Question(
      questionId: documentId,
      questionText: data['questionText'] ?? '',
      questionType: data['questionType'] ?? '',
      grade: data['grade'] ?? '',
      imageUrl: data['imageUrl'],
      correctAnswer: data['correctAnswer'],
      options:
          data['options'] != null ? List<String>.from(data['options']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'questionText': questionText,
      'questionType': questionType,
      'grade': grade,
      'imageUrl': imageUrl,
      'correctAnswer': correctAnswer,
      'options': options,
    };
  }
}
