import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:project_444/constant.dart';

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
      Navigator.pop(context);
      if (mounted) {
        SnackbarUtils.showSuccessSnackbar(
            context, 'Grades and feedback saved successfully!');
      }
    } catch (e) {
      print("Error saving grades and feedback: $e");
      if (mounted) {
        SnackbarUtils.showErrorSnackbar(
            context, 'Error saving grades and feedback');
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
        iconTheme: IconThemeData(color: AppColors.buttonTextColor),
        centerTitle: true,
        backgroundColor: AppColors.appBarColor,
        title: const Text(
          "Grading Page",
          style: TextStyle(color: AppColors.buttonTextColor),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.save,
              color: AppColors.buttonTextColor,
            ),
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
                  elevation: 4, // Optional: Add elevation for shadow effect
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10), // Rounded corners
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Feedback",
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                            color:
                                AppColors.textBlack, // Custom color if needed
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        TextField(
                          controller: feedbackController,
                          decoration: InputDecoration(
                            labelText: "Admin's Feedback",
                            labelStyle: const TextStyle(
                                color: AppColors.textBlack), // Label color
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(10), // Rounded corners
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: AppColors.appBarColor,
                                  width: 2), // Border color when focused
                              borderRadius: BorderRadius.circular(10),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: AppColors
                                      .textBlack), // Border when not focused
                              borderRadius: BorderRadius.circular(10),
                            ),
                            hintText:
                                'Enter feedback here...', // Optional placeholder text
                            hintStyle: const TextStyle(
                                color: AppColors.textBlack), // Hint text color
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
              print('Answer Value: $answerValue\n');

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
                    labelStyle:
                        TextStyle(color: AppColors.textBlack), // Label color
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(10), // Rounded corners
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: AppColors.appBarColor,
                          width: 2), // Border color when focused
                      borderRadius: BorderRadius.circular(10),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color:
                              AppColors.textBlack), // Border when not focused
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                );
              } else {
                gradeWidget = Text(
                  "Grade: $currentGrade/$maxGrade",
                  style: TextStyle(
                      color: AppColors.textBlack), // Customize text color
                );
              }

              return Card(
                margin: const EdgeInsets.all(8.0),
                elevation: 4, // Optional: Add elevation for shadow effect
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10), // Rounded corners
                ),
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
                          color: AppColors.textBlack, // Text color for question
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Column(
                        children: [
                          imageUrl != null
                              ? Image.network(imageUrl)
                              : SizedBox.shrink(),
                          const SizedBox(height: 8.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                "Answer: $answerValue",
                                style: const TextStyle(
                                    fontSize: 14.0,
                                    color: AppColors
                                        .textBlack), // Answer text color
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
