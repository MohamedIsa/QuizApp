import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_444/pages/questions/essayQuestion.dart';
import 'package:project_444/pages/questions/msqQuestion.dart';
import 'package:project_444/pages/questions/shortAnswerQuestion.dart';
import 'package:project_444/pages/questions/tfquestion.dart';
import 'package:project_444/pages/models/studentQuestionsAnswers.dart';
import 'package:project_444/pages/studenthome/widgets/countdown.dart';

class AllExam extends StatefulWidget {
  final String examId;
  final String Sid;
  final String Semail;
  final String Sname;
  final int duration;

  const AllExam({
    super.key,
    required this.examId,
    required this.Sid,
    required this.Semail,
    required this.Sname,
    required this.duration,
  });

  @override
  State<AllExam> createState() => _AllExamState();
}

class _AllExamState extends State<AllExam> {
  List<StudentQuestionsAnswers> studentAnswers = [];

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
  }

  void _submitExam() async {
    try {
      List<Map<String, dynamic>> answersList = studentAnswers.map((answer) {
        return {
          'Qid': answer.Qid,
          'AnswerValue': answer.AnswerValue,
          'grade': answer.grade,
        };
      }).toList();

      Map<String, dynamic> studentExamAnswer = {
        'Sname': widget.Sname,
        'Sid': widget.Sid,
        'Semail': widget.Semail,
        'answers': answersList,
        'submittedAt': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance
          .collection('exams')
          .doc(widget.examId)
          .collection('studentsSubmissions')
          .doc(widget.Sid)
          .set(studentExamAnswer);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Exam submitted successfully!")),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
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

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CountdownTimer(
                duration: widget.duration * 60,
                onComplete: _submitExam,
              ),
              ...questions
                  .asMap()
                  .map((index, question) {
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
                            (question['options'] as List<dynamic>? ?? [])
                                .map((e) => e?.toString() ?? ''));
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
                    return MapEntry(index, questionWidget);
                  })
                  .values
                  .toList(),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: _submitExam,
                  child: const Text("Submit Exam"),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
