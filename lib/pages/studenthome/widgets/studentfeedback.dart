import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_444/constant.dart';

class StudentFeedbackPage extends StatelessWidget {
  final String examId;
  final String userId;

  const StudentFeedbackPage({
    super.key,
    required this.examId,
    required this.userId,
  });

  void displayFeedback(BuildContext context, DocumentSnapshot studentSnapshot) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Feedback Information'),
          content: Text(studentSnapshot['feedback'] ?? 'No feedback provided.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Student Feedback',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.pageColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.appBarColor,
        iconTheme: IconThemeData(color: AppColors.pageColor),
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline),
            onPressed: () async {
              var studentSnapshot = await FirebaseFirestore.instance
                  .collection('exams')
                  .doc(examId)
                  .collection('studentsSubmissions')
                  .doc(userId)
                  .get();
              displayFeedback(context, studentSnapshot);
            },
          ),
        ],
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future:
            FirebaseFirestore.instance.collection('exams').doc(examId).get(),
        builder: (context, examSnapshot) {
          // Error handling for exam data
          if (examSnapshot.hasError) {
            return Center(child: Text('Error: ${examSnapshot.error}'));
          }

          // Loading state for exam data
          if (examSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: SizedBox.shrink());
          }

          // Check if exam data exists
          if (!examSnapshot.hasData || !examSnapshot.data!.exists) {
            return Center(child: Text('Exam data not found.'));
          }

          // Safely extract exam data
          var examData =
              examSnapshot.data!.data() as Map<String, dynamic>? ?? {};
          var questions = examData['questions'] as List<dynamic>? ?? [];

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('exams')
                .doc(examId)
                .collection('studentsSubmissions')
                .snapshots(),
            builder: (context, studentSnapshot) {
              if (studentSnapshot.hasError) {
                return Center(child: Text('Error: ${studentSnapshot.error}'));
              }

              if (studentSnapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (!studentSnapshot.hasData ||
                  studentSnapshot.data!.docs.isEmpty) {
                return Center(child: Text('No student submissions found.'));
              }

              // Safely extract student submission data
              var studentData = studentSnapshot.data!.docs.first;

              return ListView.builder(
                itemCount: questions.length,
                itemBuilder: (context, index) {
                  var question = questions[index] as Map<String, dynamic>;
                  var questionText = question['question'] ?? 'No Question';
                  var studentAnswer =
                      (studentData['answers'] as List<dynamic>? ?? [])
                          .firstWhere(
                    (answer) => answer['Qid'] == question['questionId'],
                    orElse: () => {
                      'AnswerValue': 'No Answer Provided',
                      'grade': 'Not Graded'
                    },
                  );

                  return Card(
                    child: ListTile(
                      leading: question['imageUrl'] != null
                          ? Image.network(
                              question['imageUrl'] ?? '',
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            )
                          : null,
                      title: Text(
                        questionText,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Your Answer: ${studentAnswer['AnswerValue']}',
                            style: TextStyle(color: Colors.black87),
                          ),
                          if (question['correctAnswer'] != null)
                            Text(
                                'Correct Answer: ${question['correctAnswer']}'),
                          Text(
                            'Grade: ${studentAnswer['grade']}',
                            style: TextStyle(
                              color: studentAnswer['grade'] != 'Not Graded'
                                  ? Colors.green
                                  : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
