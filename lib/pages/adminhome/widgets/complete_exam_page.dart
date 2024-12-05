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
          .where(
            'endDate',
            isLessThan: DateTime.now().toIso8601String(),
          )
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              'No completed exams found.',
              style: TextStyle(fontSize: 16),
            ),
          );
        }

        final now = DateTime.now();
        final exams = snapshot.data!.docs.where((doc) {
          final examData = doc.data() as Map<String, dynamic>;
          final endDate = DateTime.parse(examData['endDate']);
          return now
              .isAfter(endDate); // Only show exams where endDate is in the past
        }).toList();

        // Display message if no completed exams
        if (exams.isEmpty) {
          return const Center(
            child: Text(
              'There are no completed exams.',
              style: TextStyle(fontSize: 16),
            ),
          );
        }

        // Set timers dynamically based on each exam's end time
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
