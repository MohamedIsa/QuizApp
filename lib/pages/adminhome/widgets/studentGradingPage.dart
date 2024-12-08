import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

class StudentGradingPage extends StatefulWidget {
  final String Sid;
  final String Eid;

  const StudentGradingPage({
    super.key,
    required this.Sid,
    required this.Eid,
  });

  @override
  State<StudentGradingPage> createState() => _StudentGradingPageState();
}

class _StudentGradingPageState extends State<StudentGradingPage> {
  late Future<List<Map<String, dynamic>>> questionsAndAnswersFuture;
  final Map<String, TextEditingController> gradingControllers = {};
  final Map<String, int> maxGrades = {};
  final TextEditingController feedbackController = TextEditingController();

  @override
  void initState() {
    super.initState();
    questionsAndAnswersFuture = fetchQuestionsAndAnswers();
  }

  Future<List<Map<String, dynamic>>> fetchQuestionsAndAnswers() async {
    try {
      DocumentSnapshot examSnapshot = await FirebaseFirestore.instance
          .collection('exams')
          .doc(widget.Eid)
          .get();

      final questions = (examSnapshot.data()
          as Map<String, dynamic>)['questions'] as List<dynamic>;

      DocumentSnapshot studentSnapshot = await FirebaseFirestore.instance
          .collection('exams')
          .doc(widget.Eid)
          .collection('studentsSubmissions')
          .doc(widget.Sid)
          .get();

      final answers = (studentSnapshot.data()
          as Map<String, dynamic>)['answers'] as List<dynamic>;

      return questions.map((question) {
        final answer = answers.firstWhere(
          (ans) => ans['Qid'] == question['questionId'],
          orElse: () => null,
        );

        return {
          'question': question,
          'answer': answer,
        };
      }).toList();
    } catch (e) {
      print("Error fetching questions and answers: $e");
      return [];
    }
  }

  Future<void> saveGradesAndFeedback() async {
    try {
      final submissionDoc = await FirebaseFirestore.instance
          .collection('exams')
          .doc(widget.Eid)
          .collection('studentsSubmissions')
          .doc(widget.Sid)
          .get();

      if (!submissionDoc.exists) {
        throw Exception('Submission not found');
      }

      final currentAnswers = List<Map<String, dynamic>>.from(
          submissionDoc.data()?['answers'] ?? []);

      final examDoc = await FirebaseFirestore.instance
          .collection('exams')
          .doc(widget.Eid)
          .get();

      final questions =
          List<Map<String, dynamic>>.from(examDoc.data()?['questions'] ?? []);

      final questionTypes = {
        for (var q in questions) q['questionId'] as String: q['type'] as String
      };

      int totalGrade = 0;
      final updates = currentAnswers.map((answer) {
        final qid = answer['Qid'] as String;
        final questionType = questionTypes[qid];

        int grade;

        if (questionType == 'Multiple Choice' || questionType == 'True/False') {
          grade = answer['grade'];
        } else {
          grade = gradingControllers.containsKey(qid)
              ? int.tryParse(gradingControllers[qid]!.text) ?? answer['grade']
              : answer['grade'];
        }

        totalGrade += grade;

        return {
          'Qid': qid,
          'AnswerValue': answer['AnswerValue'],
          'grade': grade,
        };
      }).toList();

      await FirebaseFirestore.instance
          .collection('exams')
          .doc(widget.Eid)
          .collection('studentsSubmissions')
          .doc(widget.Sid)
          .update({
        'answers': updates,
        'feedback': feedbackController.text,
        'totalGrade': totalGrade,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Grades and feedback saved successfully!")),
        );
      }
    } catch (e) {
      print("Error saving grades and feedback: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error saving grades and feedback: $e")),
        );
      }
    }
  }

  TextInputFormatter gradeInputFormatter(int maxGrade) {
    return TextInputFormatter.withFunction((oldValue, newValue) {
      final newText = newValue.text;

      if (newText.isEmpty) {
        return newValue;
      }

      final parsed = int.tryParse(newText);
      if (parsed == null || parsed < 0 || parsed > maxGrade) {
        return oldValue;
      }

      return newValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Grading Page"),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: saveGradesAndFeedback,
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: questionsAndAnswersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text("Error: ${snapshot.error}"),
            );
          }

          final questionsAndAnswers = snapshot.data;

          if (questionsAndAnswers == null || questionsAndAnswers.isEmpty) {
            return const Center(
              child: Text("No questions or answers found."),
            );
          }

          return ListView.builder(
            itemCount: questionsAndAnswers.length + 1,
            itemBuilder: (context, index) {
              if (index == questionsAndAnswers.length) {
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Feedback",
                          style: TextStyle(
                              fontSize: 16.0, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8.0),
                        TextField(
                          controller: feedbackController,
                          decoration: const InputDecoration(
                            labelText: "Admin's Feedback",
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 4,
                        ),
                      ],
                    ),
                  ),
                );
              }

              final item = questionsAndAnswers[index];
              final question = item['question'] as Map<String, dynamic>;
              final answer = item['answer'] as Map<String, dynamic>?;

              final questionText = question['question'];
              final questionType = question['type'];
              final maxGrade = question['Questiongrade'];
              final answerValue =
                  answer?['AnswerValue'] ?? 'No answer provided';
              final currentGrade = answer?['grade'] ?? -1;
              final imageUrl = question['imageUrl'];

              Widget gradeWidget;

              if (questionType == 'Short Answer' || questionType == 'Essay') {
                final controller = TextEditingController(
                  text: currentGrade == -1 ? '' : currentGrade.toString(),
                );
                gradingControllers[question['questionId']] = controller;
                maxGrades[question['questionId']] = maxGrade;

                gradeWidget = TextField(
                  controller: controller,
                  inputFormatters: [
                    gradeInputFormatter(maxGrade),
                  ],
                  decoration: InputDecoration(
                    labelText: "Grade (Max: $maxGrade)",
                    border: const OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                );
              } else {
                gradeWidget = Text("Grade: $currentGrade/$maxGrade");
              }

              return Card(
                margin: const EdgeInsets.all(8.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Q: $questionText",
                        style: const TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      if (imageUrl != null && imageUrl.isNotEmpty)
                        Column(
                          children: [
                            Image.network(imageUrl),
                            const SizedBox(height: 8.0),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  "Answer: $answerValue",
                                  style: const TextStyle(fontSize: 14.0),
                                ),
                              ],
                            ),
                          ],
                        ),
                      const SizedBox(height: 16.0),
                      gradeWidget,
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
