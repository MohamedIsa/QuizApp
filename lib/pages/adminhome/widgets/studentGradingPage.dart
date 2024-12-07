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
  final TextEditingController feedbackController =
      TextEditingController(); // Controller for feedback

  @override
  void initState() {
    super.initState();
    questionsAndAnswersFuture = fetchQuestionsAndAnswers();
  }

  // Fetch questions and student's answers from Firestore
  Future<List<Map<String, dynamic>>> fetchQuestionsAndAnswers() async {
    try {
      // Get questions from the exam
      DocumentSnapshot examSnapshot = await FirebaseFirestore.instance
          .collection('exams')
          .doc(widget.Eid)
          .get();

      final questions = (examSnapshot.data()
          as Map<String, dynamic>)['questions'] as List<dynamic>;

      // Get the student's answers
      DocumentSnapshot studentSnapshot = await FirebaseFirestore.instance
          .collection('exams')
          .doc(widget.Eid)
          .collection('studentsSubmissions')
          .doc(widget.Sid)
          .get();

      final answers = (studentSnapshot.data()
          as Map<String, dynamic>)['answers'] as List<dynamic>;

      // Combine questions and answers
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

  // Save updated grades, feedback, and feedback to Firestore
  Future<void> saveGradesAndFeedback() async {
    try {
      final updates = gradingControllers.entries.map((entry) {
        return {
          'Qid': entry.key,
          'grade': int.parse(entry.value.text),
        };
      }).toList();

      // Update Firestore with the new grades and feedback
      await FirebaseFirestore.instance
          .collection('exams')
          .doc(widget.Eid)
          .collection('studentsSubmissions')
          .doc(widget.Sid)
          .update({
        'answers': updates,
        'feedback': feedbackController.text, // Save feedback
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Grades and feedback saved successfully!")),
      );
    } catch (e) {
      print("Error saving grades and feedback: $e");
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error saving grades and feedback: $e")));
    }
  }

  // Custom input formatter to restrict grades
  TextInputFormatter gradeInputFormatter(int maxGrade) {
    return TextInputFormatter.withFunction((oldValue, newValue) {
      final newText = newValue.text;

      if (newText.isEmpty) {
        return newValue; // Allow clearing the field
      }

      final parsed = int.tryParse(newText);
      if (parsed == null || parsed < 0 || parsed > maxGrade) {
        return oldValue; // Reject invalid input
      }

      return newValue; // Accept valid input
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
            onPressed:
                saveGradesAndFeedback, // Save grades and feedback when admin taps save
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
            itemCount:
                questionsAndAnswers.length + 1, // Add 1 for feedback section
            itemBuilder: (context, index) {
              if (index == questionsAndAnswers.length) {
                // Feedback Section at the end
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
                          maxLines: 4, // Multi-line input for feedback
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
              final imageUrl =
                  question['imageUrl']; // Assuming this field exists

              Widget gradeWidget;

              if (questionType == 'Short Answer' || questionType == 'Essay') {
                // Admin grading for Short Answer and Essay
                final controller = TextEditingController(
                  text: currentGrade == -1 ? '' : currentGrade.toString(),
                );
                gradingControllers[question['questionId']] = controller;
                maxGrades[question['questionId']] = maxGrade;

                gradeWidget = TextField(
                  controller: controller,
                  inputFormatters: [
                    gradeInputFormatter(maxGrade), // Restrict input
                  ],
                  decoration: InputDecoration(
                    labelText: "Grade (Max: $maxGrade)",
                    border: const OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                );
              } else {
                // Display immutable grades for T/F and MSQ
                gradeWidget = Text("Grade: $currentGrade/$maxGrade");
              }

              return Card(
                margin: const EdgeInsets.all(8.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Display question text
                      Text(
                        "Q: $questionText",
                        style: const TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      // Display image if exists
                      if (imageUrl != null && imageUrl.isNotEmpty)
                        Column(
                          children: [
                            Image.network(imageUrl),
                            const SizedBox(height: 8.0),
                            // Display answer under image, aligned to the left
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
                      // Display grade widget
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
