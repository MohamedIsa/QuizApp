import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StudentFeedbackPage extends StatelessWidget {
  final String examId;
  final String userId;

  const StudentFeedbackPage(
      {super.key, required this.examId, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Student Feedback'),
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('exams')
              .doc(examId)
              .collection('studentsSubmissions')
              .where('Sid', isEqualTo: userId)
              .snapshots(),
          builder: (context, snapshot) {
            // Add more detailed error handling
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(child: Text('No feedback available.'));
            }

            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                var feedback = snapshot.data!.docs[index];
                return ListTile(
                  title: Text(feedback['examName'] ?? 'No Exam Name'),
                  subtitle: Text((feedback.data() as Map<String, dynamic>)
                          .containsKey('feedback')
                      ? feedback['feedback']
                      : 'There is no feedback'),
                );
              },
            );
          },
        ));
  }
}
