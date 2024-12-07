import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Exam {
  final String examName;
  final int duration; // Duration in minutes

  Exam({required this.examName, required this.duration});

  factory Exam.fromFirestore(Map<String, dynamic> data, String docId) {
    return Exam(
      examName: data['examName'] ?? '',
      duration: data['duration'] ?? 0, // Duration is in minutes
    );
  }
}

class StudentExamSession extends StatefulWidget {
  final String examId;

  const StudentExamSession({Key? key, required this.examId}) : super(key: key);

  @override
  State<StudentExamSession> createState() => _StudentExamSessionState();
}

class _StudentExamSessionState extends State<StudentExamSession> {
  Exam? _exam;
  bool _isLoading = true;
  String _errorMessage = '';
  late Timer _timer;
  int _remainingTime = 0; // Remaining time in seconds
  late double _progress = 0.0; // Progress for the progress bar

  @override
  void initState() {
    super.initState();
    _fetchExamDetails();
  }

  Future<void> _fetchExamDetails() async {
    try {
      DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
          .collection('exams')
          .doc(widget.examId)
          .get();

      if (docSnapshot.exists) {
        setState(() {
          _exam = Exam.fromFirestore(
            docSnapshot.data() as Map<String, dynamic>,
            docSnapshot.id,
          );
          _remainingTime =
              (_exam?.duration ?? 0) * 60; // Convert duration to seconds
          _progress = 1.0; // Initial progress is 100%
          _isLoading = false;
        });

        // Start the countdown timer
        _startCountdown();
      } else {
        setState(() {
          _errorMessage = 'Exam not found';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching exam details: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _startCountdown() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        setState(() {
          _remainingTime--; // Decrease the remaining time by 1 second
          _progress = _remainingTime /
              ((_exam?.duration ?? 1) *
                  60); // Update progress based on remaining time
        });
      } else {
        _timer.cancel(); // Stop the timer when it reaches 0
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  // Function to format the time remaining as mm:ss
  String getFormattedTime(int remainingTimeInSeconds) {
    int minutes = remainingTimeInSeconds ~/ 60; // Integer division for minutes
    int seconds = remainingTimeInSeconds % 60; // Remainder for seconds
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_exam?.examName ?? 'Exam Session'),
      ),
      body: _isLoading
          ? Center(
              child:
                  CircularProgressIndicator()) // Show loading indicator while fetching
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Text(
                    _errorMessage,
                    style: TextStyle(color: Colors.red),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Progress Bar
                      LinearProgressIndicator(
                        value: _progress,
                        minHeight: 8,
                      ),
                      SizedBox(height: 20),
                      // Display the formatted time
                      Text(
                        'Time Remaining: ${getFormattedTime(_remainingTime)}',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(onPressed: () {}, child: Text('Submit'))
                    ],
                  ),
                ),
    );
  }
}
