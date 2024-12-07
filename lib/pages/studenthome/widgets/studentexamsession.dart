import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // For Firebase Authentication
import 'package:project_444/pages/questions/Allexam.dart';
import 'package:project_444/pages/studenthome/widgets/countdown.dart';

class Exam {
  final String examName;
  final int duration;

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
  String _errorMessage = '';
  bool _isLoading = true; // Flag to track loading state
  String _userName = '';
  String _userEmail = '';
  String _sid = '';

  @override
  void initState() {
    super.initState();
    _fetchExamDetails();
    _fetchUserDetails();
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
          _isLoading = false; // Data fetched, stop loading
        });
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

  Future<void> _fetchUserDetails() async {
    try {
      // Get current user info from FirebaseAuth
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Fetch the user data from Firestore
        DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid) // Assuming user UID is used as document ID
            .get();

        if (userSnapshot.exists) {
          setState(() {
            _userName = userSnapshot['name'] ?? '';
            _userEmail = userSnapshot['email'] ?? '';
            _sid = user.uid; // Assuming 'Sid' is the field name
          });
        } else {
          setState(() {
            _errorMessage = 'User not found in Firestore';
          });
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching user details: ${e.toString()}';
      });
    }
  }

  void _submitExam() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_exam?.examName ?? 'Exam Session'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Show the countdown timer only if the exam data is fetched
              if (!_isLoading && _exam != null) ...[
                CountdownTimer(
                  duration: (_exam?.duration ?? 0) *
                      60, // Convert duration to seconds
                  onComplete: _submitExam, // Pass the callback
                ),
                SizedBox(height: 20),
                AllExam(
                  Semail: _userEmail,
                  Sname: _userName,
                  Sid: _sid,
                  examId: widget.examId,
                ),
              ],
              // Show an error message if there's any issue
              if (_errorMessage.isNotEmpty)
                Text(
                  _errorMessage,
                  style: TextStyle(color: Colors.red, fontSize: 16),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
