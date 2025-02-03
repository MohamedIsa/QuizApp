import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quizapp/pages/adminhome/widgets/ExamAnswers.dart';
import 'package:quizapp/pages/adminhome/widgets/ExamWidget.dart';

class CompleteExamPage extends StatefulWidget {
  const CompleteExamPage({Key? key}) : super(key: key);

  @override
  _CompleteExamPageState createState() => _CompleteExamPageState();
}

class _CompleteExamPageState extends State<CompleteExamPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Check if any answer has a grade of -1
  bool _hasUngradedAnswer(List<dynamic>? answers) {
    if (answers == null || answers.isEmpty) return false;

    return answers.any(
        (answer) => answer is Map<String, dynamic> && answer['grade'] == -1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Search Field
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search Completed Exams...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: (query) {
                setState(() {
                  _searchQuery = query.toLowerCase();
                });
              },
            ),
          ),

          // Stream Builder for Real-time Exams
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection('exams').snapshots(),
              builder: (context, snapshot) {
                // Loading state
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Error state
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                // No data
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text('No exams found.'),
                  );
                }

                // Filter and process exams
                final now = DateTime.now();
                final completedExams = snapshot.data!.docs.where((exam) {
                  final examData = exam.data() as Map<String, dynamic>;
                  final endDate = DateTime.parse(examData['endDate']);
                  final examName = (examData['examName'] ?? '').toLowerCase();

                  // Check if exam is completed and matches search query
                  return now.isAfter(endDate) &&
                      examName.contains(_searchQuery);
                }).toList();

                // StreamBuilder for listening to student submissions
                return StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('exams')
                      .snapshots(),
                  builder: (context, submissionsSnapshot) {
                    // Loading state
                    if (submissionsSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    // Check for ungraded answers for each exam
                    return ListView.builder(
                      itemCount: completedExams.length,
                      itemBuilder: (context, index) {
                        final examDoc = completedExams[index];
                        final examData = examDoc.data() as Map<String, dynamic>;

                        final examName = examData['examName'] ?? 'Unnamed Exam';
                        final startDate = DateTime.parse(examData['startDate']);
                        final endDate = DateTime.parse(examData['endDate']);
                        final attempts = examData['attempts'] ?? 0;
                        final examId = examDoc.id;

                        // Check for ungraded answers
                        return StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('exams')
                              .doc(examId)
                              .collection('studentsSubmissions')
                              .snapshots(),
                          builder: (context, submissionSnapshot) {
                            if (!submissionSnapshot.hasData) {
                              return Container(); // Skip if no data
                            }

                            final submissions = submissionSnapshot.data!.docs;

                            final hasUngradedAnswers = submissions.any(
                                (submission) =>
                                    _hasUngradedAnswer(submission['answers']));

                            // Set the widget color based on ungraded answers
                            return ExamWidget(
                              examName: examName,
                              startDate: startDate,
                              endDate: endDate,
                              attempts: attempts,
                              color: hasUngradedAnswers
                                  ? Colors.orange
                                  : Colors.grey,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ExamAnswers(
                                      Eid: examId,
                                      ExamName: examName,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Check for ungraded answers across all completed exams
  Future<List<String>> _checkUngradedAnswers(
      List<QueryDocumentSnapshot> completedExams) async {
    final List<String> examsWithUngradedAnswers = [];

    for (var exam in completedExams) {
      final submissionsSnapshot = await FirebaseFirestore.instance
          .collection('exams')
          .doc(exam.id)
          .collection('studentsSubmissions')
          .get();

      // Check if any submission has an ungraded answer
      final hasUngradedAnswers = submissionsSnapshot.docs.any((submission) {
        final submissionData = submission.data();
        final answers = submissionData['answers'] as List<dynamic>?;

        return _hasUngradedAnswer(answers);
      });

      if (hasUngradedAnswers) {
        examsWithUngradedAnswers.add(exam.id);
      }
    }

    return examsWithUngradedAnswers;
  }
}
