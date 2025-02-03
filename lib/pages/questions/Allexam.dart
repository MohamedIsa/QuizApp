import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quizapp/constant.dart';
import 'package:quizapp/pages/questions/essayQuestion.dart';
import 'package:quizapp/pages/questions/msqQuestion.dart';
import 'package:quizapp/pages/questions/shortAnswerQuestion.dart';
import 'package:quizapp/pages/questions/tfquestion.dart';
import 'package:quizapp/pages/models/studentQuestionsAnswers.dart';
import 'package:quizapp/pages/studenthome/widgets/countdown.dart';

class AllExam extends StatefulWidget {
  final String examId;
  final String Sid;
  final String Semail;
  final String Sname;
  final int duration;

  const AllExam({
    Key? key,
    required this.examId,
    required this.Sid,
    required this.Semail,
    required this.Sname,
    required this.duration,
  }) : super(key: key);

  @override
  State<AllExam> createState() => _AllExamState();
}

class _AllExamState extends State<AllExam> {
  List<StudentQuestionsAnswers> studentAnswers = [];
  int totalGrade = 0;

  void _updateAnswer(String qid, String answerValue, int grade) {
    final index = studentAnswers.indexWhere((answer) => answer.Qid == qid);

    if (index >= 0) {
      studentAnswers[index] = StudentQuestionsAnswers(
        Qid: qid,
        AnswerValue: answerValue,
        grade: grade,
      );
    } else {
      studentAnswers.add(StudentQuestionsAnswers(
        Qid: qid,
        AnswerValue: answerValue,
        grade: grade,
      ));
    }

    totalGrade = studentAnswers
        .where((answer) => answer.grade != -1)
        .fold(0, (sum, answer) => sum + answer.grade);
  }

  void _submitExam() async {
    try {
      // Get all question IDs from the exam
      final examSnapshot = await FirebaseFirestore.instance
          .collection('exams')
          .doc(widget.examId)
          .get();

      final examData = examSnapshot.data();
      if (examData == null) {
        throw Exception("Exam data not found");
      }

      final questions = List<Map<String, dynamic>>.from(
        (examData['questions'] as List<dynamic>? ?? []).map((q) {
          if (q is! Map<String, dynamic>) {
            return <String, dynamic>{};
          }
          return q;
        }),
      );

      // Create a map of all question IDs
      final allQuestionIds =
          questions.map((q) => q['questionId'] as String).toSet();

      // Populate unanswered questions with default values
      for (var qid in allQuestionIds) {
        // Check if this question is already in studentAnswers
        if (!studentAnswers.any((answer) => answer.Qid == qid)) {
          studentAnswers.add(StudentQuestionsAnswers(
            Qid: qid,
            AnswerValue: 'none',
            grade: 0,
          ));
        }
      }

      // Check if all answers have 'none' value and set totalGrade to 0
      if (studentAnswers.every((answer) => answer.AnswerValue == 'none')) {
        totalGrade = 0;
      } else if (questions
          .any((q) => q['type'] == "Short Answer" || q['type'] == "Essay")) {
        totalGrade = -1;
      }

      // Prepare the answers list
      List<Map<String, dynamic>> answersList = studentAnswers.map((answer) {
        return {
          'Qid': answer.Qid,
          'AnswerValue': answer.AnswerValue,
          'grade': answer.grade,
        };
      }).toList();

      // Reference to the student submission document in exam collection
      final examSubmissionRef = FirebaseFirestore.instance
          .collection('exams')
          .doc(widget.examId)
          .collection('studentsSubmissions')
          .doc(widget.Sid);

      // Reference to the student submission document in user collection
      final userSubmissionRef = FirebaseFirestore.instance
          .collection('users')
          .doc(widget.Sid)
          .collection('studentanswer')
          .doc(widget.examId);

      // Run transaction to handle submission
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final examSubmissionSnapshot = await transaction.get(examSubmissionRef);

        int currentAttempts = 0;

        if (examSubmissionSnapshot.exists) {
          // If the document exists, get the current attempts count
          currentAttempts = examSubmissionSnapshot.data()?['attempts'] ?? 0;
        }

        // Prepare the submission data
        Map<String, dynamic> studentExamAnswer = {
          'Sname': widget.Sname,
          'Sid': widget.Sid,
          'ExamId': widget.examId,
          'Semail': widget.Semail,
          'answers': answersList,
          'submittedAt': FieldValue.serverTimestamp(),
          'attempts': currentAttempts + 1,
          'totalGrade': totalGrade,
          'examId': widget.examId,
          'examName': examData['examName'] ?? 'Unnamed Exam',
        };

        // Update or create the submission document in exam collection
        transaction.set(examSubmissionRef, studentExamAnswer);

        // Update or create the submission document in user collection
        transaction.set(userSubmissionRef, studentExamAnswer);
      });

      if (mounted) {
        SnackbarUtils.showSuccessSnackbar(
            context, 'Exam submitted successfully!');
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        SnackbarUtils.showErrorSnackbar(context, 'Error: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('exams')
          .doc(widget.examId)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Center(child: Text("Exam not found or does not exist."));
        }

        final examData = snapshot.data!.data() as Map<String, dynamic>?;

        if (examData == null) {
          return const Center(child: Text("Invalid exam data."));
        }

        final questions = List<Map<String, dynamic>>.from(
          (examData['questions'] as List<dynamic>? ?? []).map((q) {
            if (q is! Map<String, dynamic>) {
              return <String, dynamic>{};
            }
            return q;
          }),
        );

        questions.shuffle();

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CountdownTimer(
                duration: widget.duration * 60,
                onComplete: _submitExam,
              ),
              ...questions.asMap().entries.map((entry) {
                final index = entry.key + 1;
                final question = entry.value;
                final type = question['type'] as String? ?? '';
                final grade = question['Questiongrade'] as int? ?? 0;
                final questionText = question['question'] as String? ?? '';
                final imageUrl = question['imageUrl'] as String?;
                final questionId = question['questionId'] as String? ?? '';
                final correctAnswer =
                    question['correctAnswer'] as String? ?? '';

                Widget questionWidget;

                switch (type) {
                  case "Multiple Choice":
                    final options = List<String>.from(
                        (question['options'] as List<dynamic>? ?? []));
                    questionWidget = MCQQuestion(
                      Qid: questionId,
                      grade: grade,
                      questionTxt: questionText,
                      imgURL: imageUrl,
                      Sid: widget.Sid,
                      Semail: widget.Semail,
                      Sname: widget.Sname,
                      option1: options.isNotEmpty ? options[0] : '',
                      option2: options.length > 1 ? options[1] : '',
                      option3: options.length > 2 ? options[2] : '',
                      option4: options.length > 3 ? options[3] : '',
                      correctAnswer: correctAnswer,
                      onAnswerChanged: (answer, correctAnswer) {
                        int calculatedGrade =
                            (answer == correctAnswer) ? grade : 0;
                        _updateAnswer(questionId, answer, calculatedGrade);
                      },
                    );
                    break;
                  case "True/False":
                    questionWidget = TFQuestion(
                      Qid: questionId,
                      grade: grade,
                      questionTxt: questionText,
                      imgURL: imageUrl,
                      Sid: widget.Sid,
                      Semail: widget.Semail,
                      Sname: widget.Sname,
                      correctAnswer: correctAnswer,
                      onAnswerChanged: (answer, grade) {
                        _updateAnswer(questionId, answer, grade);
                      },
                    );
                    break;
                  case "Essay":
                    questionWidget = EssayQuestion(
                      Qid: questionId,
                      grade: grade,
                      questionTxt: questionText,
                      imgURL: imageUrl,
                      Sid: widget.Sid,
                      Semail: widget.Semail,
                      Sname: widget.Sname,
                      onAnswerChanged: (answer) {
                        _updateAnswer(questionId, answer, -1);
                      },
                    );
                    break;
                  case "Short Answer":
                    questionWidget = ShortAnswerQuestion(
                      Qid: questionId,
                      grade: grade,
                      questionTxt: questionText,
                      imgURL: imageUrl,
                      Sid: widget.Sid,
                      Semail: widget.Semail,
                      Sname: widget.Sname,
                      onAnswerChanged: (answer) {
                        _updateAnswer(questionId, answer, -1);
                      },
                    );
                    break;
                  default:
                    questionWidget = const SizedBox();
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (index > 1) Divider(color: Colors.grey, thickness: 1),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Q$index:',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    questionWidget,
                  ],
                );
              }).toList(),
              const Divider(color: Colors.grey, thickness: 1),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.buttonColor,
                    ),
                    onPressed: _submitExam,
                    child: const Text(
                      "Submit Exam",
                      style: TextStyle(color: AppColors.pageColor),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
