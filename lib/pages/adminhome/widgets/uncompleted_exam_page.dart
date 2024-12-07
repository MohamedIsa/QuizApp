import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_444/pages/adminhome/widgets/ExamWidget.dart';
import 'package:project_444/pages/adminhome/widgets/editExamPage.dart';

class UncompletedExamPage extends StatefulWidget {
  const UncompletedExamPage({Key? key}) : super(key: key);

  @override
  _UncompletedExamPageState createState() => _UncompletedExamPageState();
}

class _UncompletedExamPageState extends State<UncompletedExamPage> {
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

  // Filter exams based on search text and whether they are uncompleted (upcoming)
  List<QueryDocumentSnapshot> _filterExams(
      List<QueryDocumentSnapshot> exams, String query) {
    final lowercasedQuery = query.toLowerCase();
    final now = DateTime.now();

    // Filter based on exam name and check if the exam is uncompleted (startDate is in the future)
    return exams.where((exam) {
      final examData = exam.data() as Map<String, dynamic>;
      final examName = examData['examName'] ?? '';
      final startDate = DateTime.parse(examData['startDate']);
      final matchesQuery = examName.toLowerCase().contains(lowercasedQuery);
      final isUncompleted =
          now.isBefore(startDate); // Ensure the exam hasn't started yet

      return matchesQuery && isUncompleted;
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
              ? const Center(child: Text('No uncompleted exams found.'))
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
Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditExamPage(Eid: examId),
                    ));
                      },
                    );
                  },
                ),
        ),
      ],

    );
  }

  // Function to set timers dynamically based on the start time of each exam
  void _setTimers(List<QueryDocumentSnapshot> exams, DateTime now) {
    // Cancel previous timers
    for (var timer in _timers) {
      timer.cancel();
    }
    _timers.clear(); // Clear the list of timers

    for (var exam in exams) {
      final examData = exam.data() as Map<String, dynamic>;
      final startDate = DateTime.parse(examData['startDate']);
      final difference = startDate.difference(now).inSeconds;

      // Only set a timer if the start date is in the future
      if (difference > 0) {
        // Set the timer to trigger when the start date is reached
        final timer = Timer(Duration(seconds: difference), () {
          if (mounted) {
            setState(() {
              // Refresh or remove the completed exam manually if needed
            });
          }
        });
        _timers.add(timer); // Add the timer to the list
      }
    }
  }
}
