import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quizapp/pages/studenthome/widgets/studentfeedback.dart';

class GradeView extends StatelessWidget {
  final String userId;

  GradeView({required this.userId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('exams').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No grades available'));
        }
        final exams = snapshot.data!.docs;
        return ListView.builder(
          itemCount: exams.length,
          itemBuilder: (context, index) {
            final examData = exams[index].data() as Map<String, dynamic>;
            return StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('exams')
                  .doc(exams[index].id)
                  .collection('studentsSubmissions')
                  .doc(userId)
                  .snapshots(),
              builder: (context, submissionSnapshot) {
                if (submissionSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return Center(child: Container());
                }
                if (!submissionSnapshot.hasData ||
                    !submissionSnapshot.data!.exists) {
                  return SizedBox.shrink(); // Do not display if no submission
                }
                final submissionData =
                    submissionSnapshot.data!.data() as Map<String, dynamic>;
                if (submissionData['totalGrade'] != null &&
                    submissionData['totalGrade'] < 0) {
                  return SizedBox.shrink(); // Do not display the exam
                }

                final startDate = DateTime.parse(examData['startDate']);
                final endDate = DateTime.parse(examData['endDate']);
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
                        Icons.grade,
                        color: Colors.grey,
                      ),
                      title: Text('Exam Title: ${examData['examName']}'),
                      subtitle: Text(
                        'Start Date: $startDate\nEnd Date: $endDate',
                        style: TextStyle(fontSize: 12),
                      ),
                      trailing: Text(
                        'Grade\n${submissionData['totalGrade']} out of ${examData['totalGrade']}',
                        style: TextStyle(
                          color: getColorBasedOnGrade(
                              submissionData['totalGrade'],
                              examData['totalGrade']),
                        ),
                      ),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => StudentFeedbackPage(
                            userId: userId,
                            examId: exams[index].id,
                          ),
                        ),
                      ),
                    ));
              },
            );
          },
        );
      },
    );
  }
}

getColorBasedOnGrade(submissionData, examData) {
  final percentage = (submissionData / examData) * 100;
  if (percentage >= 90) {
    return Colors.green;
  } else if (percentage >= 70) {
    return Colors.orange;
  } else {
    return Colors.red;
  }
}
