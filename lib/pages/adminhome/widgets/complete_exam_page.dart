import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
          .where('endDate',
              isLessThan: DateTime.now()
                  .toIso8601String()) // Filter for exams that ended in the past
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
            var exam = exams[index].data() as Map<String, dynamic>;

            return Container(
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ListTile(
                leading: Icon(
                  Icons.book,
                  color: Colors.grey, // Set default icon color
                ),
                title: Text(
                  exam['examName'] ?? 'Unnamed Exam',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Text(
                      'Start Date: ${_formatDateTime(DateTime.parse(exam['startDate']))}',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    Text(
                      'End Date: ${_formatDateTime(DateTime.parse(exam['endDate']))}',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Attempts: ${exam['attempts'] ?? 0}',
                      style: const TextStyle(color: Colors.blue),
                    ),
                  ],
                ),
                onTap: () {
                  // You can add functionality for the onTap event here if needed
                },
              ),
            );
          },
        );
      },
    );
  }

  // Helper method to format DateTime
  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${_twoDigits(dateTime.month)}-${_twoDigits(dateTime.day)} '
        '${_twoDigits(dateTime.hour)}:${_twoDigits(dateTime.minute)}';
  }

  // Helper method to ensure two-digit formatting
  String _twoDigits(int n) {
    return n.toString().padLeft(2, '0');
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
          // When the timer triggers, rebuild the page and remove the completed exam
          if (mounted) {
            setState(() {
              // Optionally, refresh or remove the completed exam manually here.
              // This will trigger the page to rebuild after the exam is removed.
            });
          }
        });
        _timers.add(timer); // Add the timer to the list
      }
    }
  }
}
