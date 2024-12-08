import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_444/constant.dart';
import 'package:project_444/pages/questions/StudentSearch/StudentQuestionWidget.dart';
import 'package:project_444/pages/studenthome/widgets/StudentExamSession.dart';

class SearchQuestionForUser extends StatefulWidget {
  const SearchQuestionForUser({Key? key}) : super(key: key);

  @override
  _SearchQuestionForUserState createState() => _SearchQuestionForUserState();
}

class _SearchQuestionForUserState extends State<SearchQuestionForUser> {
  late List<Timer> _timers;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _timers = [];
  }

  @override
  void dispose() {
    for (var timer in _timers) {
      timer.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Search Questions..."),
        backgroundColor: AppColors.buttonColor,
      ),
      body: Column(
        children: [
          _buildSearchBar(), // Search bar
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection('exams').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      'No exams found.',
                      style: TextStyle(fontSize: 16),
                    ),
                  );
                }

                final exams = snapshot.data!.docs;
                List<Map<String, dynamic>> filteredQuestions = [];

                // Get all questions
                for (var exam in exams) {
                  final examData = exam.data() as Map<String, dynamic>;
                  final examId = exam.id; // Get the exam ID
                  final examName = examData['examName'] ??
                      'Unnamed Exam'; // Get the exam name
                  final questions = examData['questions'] as List<dynamic>?;

                  if (questions != null) {
                    // Filter questions based on (Question Text or Exam Name)
                    final filtered = questions.where((question) {
                      final questionText = question['question'] ?? '';
                      return questionText
                              .toLowerCase()
                              .contains(_searchQuery.toLowerCase()) ||
                          examName
                              .toLowerCase()
                              .contains(_searchQuery.toLowerCase());
                    }).toList();

                    // List Filter
                    for (var question in filtered) {
                      filteredQuestions.add({
                        'examId': examId,
                        'examName': examName, // Add examName
                        'question': question['question'],
                        'questionId': question['questionId'],
                        'questiongrade': question['questiongrade'],
                        'type': question['type'],
                      });
                    }
                  }
                }

                if (filteredQuestions.isEmpty) {
                  return const Center(
                    child: Text(
                      'No matching questions found.',
                      style: TextStyle(fontSize: 16),
                    ),
                  );
                }

                // Display filtered questions (List)
                return ListView.builder(
                  itemCount: filteredQuestions.length,
                  itemBuilder: (context, index) {
                    final questionData = filteredQuestions[index];
                    final examName = questionData['examName']; // Get examName
                    final questionText =
                        questionData['question'] ?? 'Unnamed Question';
                    final questionType =
                        questionData['type'] ?? 'Multiple Choice';
                    final examId = questionData[
                        'examId']; // Get the examId from the question
                    final questionId =
                        questionData['questionId']; // Get questionId

                    // Make sure we got everthing
                    return StudentQuestionWidget(
                      questionText: questionText,
                      questionType: questionType,
                      questionId: questionId, // Pass the required questionId
                      examName: examName, // Pass the examName
                      onTap: () {
                        _handleQuestionTap(examId, context);
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

  // Search bar widget
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        onChanged: (query) {
          setState(() {
            _searchQuery = query;
          });
        },
        decoration: InputDecoration(
          labelText: 'Search Questions or Exam Name',
          border: OutlineInputBorder(),
          suffixIcon: Icon(Icons.search),
        ),
      ),
    );
  }

  void _handleQuestionTap(String examId, BuildContext context) async {
    // For future use,, now it's comment , to prevent user to open the exam multiple times
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => StudentExamSession(examId: examId),
    //   ),
    // );
  }
}
