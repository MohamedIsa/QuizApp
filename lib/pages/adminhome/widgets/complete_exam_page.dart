import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_444/pages/adminhome/widgets/ExamWidget.dart';

class CompleteExamPage extends StatefulWidget {
  const CompleteExamPage({Key? key}) : super(key: key);

  @override
  _CompleteExamPageState createState() => _CompleteExamPageState();
}

class _CompleteExamPageState extends State<CompleteExamPage> {
  late List<Timer> _timers;
  TextEditingController searchController = TextEditingController();
  List<QueryDocumentSnapshot> allExams = [];
  List<QueryDocumentSnapshot> filteredExams = [];

  @override
  void initState() {
    super.initState();
    _timers = []; // Initialize the list of timers
    _fetchExams(); // Fetch all exams initially
  }

  @override
  void dispose() {
    // Cancel all timers when the widget is disposed
    for (var timer in _timers) {
      timer.cancel();
    }
    super.dispose();
  }

  // Fetch all exams from Firestore
  Future<void> _fetchExams() async {
    final snapshot = await FirebaseFirestore.instance.collection('exams').get();
    setState(() {
      allExams = snapshot.docs;
      filteredExams = _filterExams(allExams,
          searchController.text); // Initialize filtered exams with all exams
    });
  }

  // Filter exams based on search text and whether they are completed (endDate is in the past)
  List<QueryDocumentSnapshot> _filterExams(
      List<QueryDocumentSnapshot> exams, String query) {
    final lowercasedQuery = query.toLowerCase();
    final now = DateTime.now();

    // Filter based on exam name and check if the exam is completed (endDate is in the past)
    return exams.where((exam) {
      final examData = exam.data() as Map<String, dynamic>;
      final examName = examData['examName'] ?? '';
      final endDate = DateTime.parse(examData['endDate']);
      final matchesQuery = examName.toLowerCase().contains(lowercasedQuery);
      final isCompleted = now.isAfter(endDate); // Ensure the exam is completed

      return matchesQuery && isCompleted;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search Field
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    labelText: 'Search Exam...',
                    suffixIcon: IconButton(
                      icon: Icon(Icons.clear),
                      onPressed: () {
                        searchController.clear();
                        setState(() {
                          filteredExams = _filterExams(
                              allExams, ''); // Clear search and reset filter
                        });
                      },
                    ),
                  ),
                  onChanged: (query) {
                    setState(() {
                      filteredExams = _filterExams(
                          allExams, query); // Filter exams when search changes
                    });
                  },
                ),
              ),
            ],
          ),
        ),
        // Display filtered exams or original data
        Expanded(
          child: filteredExams.isEmpty
              ? const Center(child: Text('No completed exams found.'))
              : ListView.builder(
                  itemCount: filteredExams.length,
                  itemBuilder: (context, index) {
                    final examData =
                        filteredExams[index].data() as Map<String, dynamic>;
                    final startDate = DateTime.parse(examData['startDate']);
                    final endDate = DateTime.parse(examData['endDate']);
                    final examName = examData['examName'] ?? 'Unnamed Exam';
                    final attempts = examData['attempts'] ?? 0;

                    return ExamWidget(
                      examName: examName,
                      startDate: startDate,
                      endDate: endDate,
                      attempts: attempts,
                      onTap: () {
                        // Add functionality when the widget is tapped
                        debugPrint('$examName tapped!');
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }

  // Function to set timers dynamically based on the end time of each exam
  void _setTimers(List<QueryDocumentSnapshot> exams, DateTime now) {
    // Cancel previous timers
    for (var timer in _timers) {
      timer.cancel();
    }
    _timers.clear(); // Clear the list of timers

    for (var exam in exams) {
      final examData = exam.data() as Map<String, dynamic>;
      final endDate = DateTime.parse(examData['endDate']);
      final difference = now.difference(endDate).inSeconds;

      // Only set a timer if the end date is in the past
      if (difference > 0) {
        // Set the timer to trigger when the end date is reached
        final timer = Timer(Duration(seconds: difference), () {
          if (mounted) {
            setState(() {
              // Optionally, refresh or remove the completed exam manually here.
            });
          }
        });
        _timers.add(timer); // Add the timer to the list
      }
    }
  }
}
