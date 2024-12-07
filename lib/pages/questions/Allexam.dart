import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_444/pages/questions/essayQuestion.dart';
import 'package:project_444/pages/questions/msqQuestion.dart';
import 'package:project_444/pages/questions/shortAnswerQuestion.dart';
import 'package:project_444/pages/questions/tfquestion.dart';
import 'package:project_444/pages/models/studentQuestionsAnswers.dart';

class AllExam extends StatefulWidget {
  final String examId;
  final String Sid;
  final String Semail;
  final String Sname;

  const AllExam({
    super.key,
    required this.examId,
    required this.Sid,
    required this.Semail,
    required this.Sname,
  });

  @override
  State<AllExam> createState() => _AllExamState();
}

class _AllExamState extends State<AllExam> {
  // List to store answers
  List<StudentQuestionsAnswers> studentAnswers = [];

  // Function to modify an answer in the list
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
      // Prepare the list of answers in the correct format
      List<Map<String, dynamic>> answersList = studentAnswers.map((answer) {
        return {
          'Qid': answer.Qid,
          'AnswerValue': answer.AnswerValue,
          'grade': answer.grade,
        };
      }).toList();

      // Create a map of the student's answers
      Map<String, dynamic> studentExamAnswer = {
        'Sid': widget.Sid,
        'Semail': widget.Semail,
        'answers': answersList,
        'submittedAt': FieldValue.serverTimestamp(), // Timestamp of submission
      };

      // Save the document to Firebase Firestore inside the exams collection
      // Create a subcollection 'studentsSubmissions' under the 'exams' collection
      await FirebaseFirestore.instance
          .collection('exams')
          .doc(widget.examId) // The document name is the examId
          .collection(
              'studentsSubmissions') // Create subcollection for students' submissions
          .doc(widget.Sid) // Use the student's Sid as the document ID
          .set(
              studentExamAnswer); // Store the student's answers inside the subcollection

      // Show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Exam submitted successfully!")),
      );

      // Optionally, you can navigate back or reset the state
      Navigator.pop(context);
    } catch (e) {
      // Handle any errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
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

        final questions = examData['questions'] as List<dynamic>? ?? [];

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...questions
                  .asMap()
                  .map((index, question) {
                    if (question is! Map) {
                      return MapEntry(index,
                          const SizedBox()); // Skip invalid question entries
                    }

                    final type = question['type'] as String?;
                    final grade = question['Questiongrade'] as int?;
                    final questionText = question['question'] as String?;
                    final imageUrl = question['imageUrl'] as String?;
                    final questionId = question['questionId'] as String?;
                    final correctAnswer = question['correctAnswer'] as String?;

                    switch (type) {
                      case "Multiple Choice":
                        final options =
                            (question['options'] as List<dynamic>?) ?? [];
                        return MapEntry(
                          index,
                          MCQQuestion(
                            Qid: questionId ?? '',
                            grade: grade ?? 0,
                            questionTxt: questionText ?? 'Unnamed Question',
                            imgURL: imageUrl,
                            Sid: widget.Sid,
                            Semail: widget.Semail,
                            Sname: widget.Sname,
                            option1: options.length > 0 ? options[0] : '',
                            option2: options.length > 1 ? options[1] : '',
                            option3: options.length > 2 ? options[2] : '',
                            option4: options.length > 3 ? options[3] : '',
                            correctAnswer: correctAnswer ?? '',
                            onAnswerChanged: (answer, correctAnswer) {
                              int calculatedGrade =
                                  (answer == correctAnswer) ? (grade ?? 0) : 0;
                              _updateAnswer(
                                  questionId ?? '', answer, calculatedGrade);
                            },
                          ),
                        );
                      case "True/False":
                        return MapEntry(
                          index,
                          TFQuestion(
                            Qid: questionId ?? '',
                            grade: grade ?? 0,
                            questionTxt: questionText ?? 'Unnamed Question',
                            imgURL: imageUrl,
                            Sid: widget.Sid,
                            Semail: widget.Semail,
                            Sname: widget.Sname,
                            correctAnswer: correctAnswer ?? '',
                            onAnswerChanged: (answer, grade) {
                              _updateAnswer(questionId ?? '', answer, grade);
                            },
                          ),
                        );
                      case "Essay":
                        return MapEntry(
                          index,
                          EssayQuestion(
                            Qid: questionId ?? '',
                            grade: grade ?? 0,
                            questionTxt: questionText ?? 'Unnamed Question',
                            imgURL: imageUrl,
                            Sid: widget.Sid,
                            Semail: widget.Semail,
                            Sname: widget.Sname,
                            onAnswerChanged: (answer) {
                              _updateAnswer(questionId ?? '', answer, -1);
                            },
                          ),
                        );
                      case "Short Answer":
                        return MapEntry(
                          index,
                          ShortAnswerQuestion(
                            Qid: questionId ?? '',
                            grade: grade ?? 0,
                            questionTxt: questionText ?? 'Unnamed Question',
                            imgURL: imageUrl,
                            Sid: widget.Sid,
                            Semail: widget.Semail,
                            Sname: widget.Sname,
                            onAnswerChanged: (answer) {
                              _updateAnswer(questionId ?? '', answer, -1);
                            },
                          ),
                        );
                      default:
                        return MapEntry(index,
                            const SizedBox()); // Skip unknown question types
                    }
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
