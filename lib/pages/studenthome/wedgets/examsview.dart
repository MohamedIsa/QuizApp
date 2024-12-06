import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_444/pages/studenthome/wedgets/studentexamsession.dart';
import 'StudentExamWidget.dart'; // Assuming StudentExamWidget is imported here

class StudentExam extends StatefulWidget {
  const StudentExam({Key? key}) : super(key: key);

  @override
  _StudentExamState createState() => _StudentExamState();
}

class _StudentExamState extends State<StudentExam> {
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
          // Only show exams that have not started yet or are starting at the current time
          return now.subtract(Duration(days: 1)).isBefore(startDate);
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
            final duration = examData['duration'] ??
                0; // Added duration from the Firestore document

            return StudentExamWidget(
              examName: examName,
              startDate: startDate,
              endDate: endDate,
              attempts: attempts,
              duration: duration,
              onTap: () {
                _handleExamTap(context, examName, startDate, endDate, duration);
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

void _handleExamTap(BuildContext context, String examName, DateTime startDate,
    DateTime endDate, int duration) {
  final now = DateTime.now();

  if (now.isAfter(startDate) && now.isBefore(endDate)) {
    // Show dialog when the exam is within the valid range (start and end time)
    _showBottomSheet(context, '$examName',
        'You will have $duration minutes to solve exam. Please make sure you are ready before starting.');
  } else {
    // Show dialog when the exam is not available
    _showDialog(context, 'Exam Unavailable',
        'The exam is not available for interaction yet or has expired.');
  }
}

// Function to show a dialog
void _showDialog(BuildContext context, String title, String content) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
}

void _showBottomSheet(BuildContext context, String title, String content) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true, // Allows flexible height for BottomSheet
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.zero, // Makes the corners square (no radius)
    ),
    builder: (BuildContext context) {
      return FractionallySizedBox(
        alignment: Alignment.center, // Centers the bottom sheet horizontally
        widthFactor: 1.0, // Full width of the screen
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment:
                CrossAxisAlignment.center, // Aligns text in the center
            children: <Widget>[
              Text(
                title,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                content,
                style: TextStyle(
                    fontSize: 16), // Added text for the exam start message
                textAlign: TextAlign.center, // Centers the text
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _showConfirmationDialog(context);
                },
                child: const Text('Start Exam'),
              ),
            ],
          ),
        ),
      );
    },
  );
}

void _showConfirmationDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Are you sure?'),
        content: const Text('Do you want to start the exam now?'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StudentExamSession(),
                ),
              );
            },
            child: const Text('Start Exam'),
          ),
        ],
      );
    },
  );
}
