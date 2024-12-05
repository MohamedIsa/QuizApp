import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_444/pages/adminhome/widgets/ExamWidget.dart';

class UncompletedExamPage extends StatefulWidget {
  const UncompletedExamPage({Key? key}) : super(key: key);

  @override
  _UncompletedExamPageState createState() => _UncompletedExamPageState();
}

class _UncompletedExamPageState extends State<UncompletedExamPage> {
  late List<Timer> _timers;

  @override
  void initState() {
    super.initState();
    _timers = []; // Initialize the list of timers
  }

  @override
  void dispose() {
    // Cancel all timers when the widget is disposed
    for (var timer in _timers) {
      timer.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('exams')
          .where('endDate', isGreaterThan: DateTime.now().toIso8601String())
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              'No uncompleted exams found.',
              style: TextStyle(fontSize: 16),
            ),
          );
        }

        final now = DateTime.now();
        final exams = snapshot.data!.docs.where((doc) {
          final examData = doc.data() as Map<String, dynamic>;
          final startDate = DateTime.parse(examData['startDate']);
          return now.isBefore(startDate); // Only show exams before startDate
        }).toList();

        // Display message if no upcoming exams
        if (exams.isEmpty) {
          return const Center(
            child: Text(
              'There are no upcoming exams.',
              style: TextStyle(fontSize: 16),
            ),
          );
        }

        // Set timers dynamically based on each exam's start time
        _setTimers(exams, now);

        return ListView.builder(
          itemCount: exams.length,
          itemBuilder: (context, index) {
            final examData = exams[index].data() as Map<String, dynamic>;
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
        );
      },
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
