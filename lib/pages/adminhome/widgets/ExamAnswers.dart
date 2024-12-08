import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_444/constant.dart';
import 'package:project_444/pages/adminhome/widgets/studentGradingPage.dart';

class ExamAnswers extends StatefulWidget {
  final String ExamName;
  final String Eid;

  const ExamAnswers({
    super.key,
    required this.Eid,
    required this.ExamName,
  });

  @override
  State<ExamAnswers> createState() => _ExamAnswersState();
}

class _ExamAnswersState extends State<ExamAnswers> {
  // Check if any answer requires grading
  bool requiresAdminGrading(List<dynamic>? answers) {
    if (answers == null || answers.isEmpty) return false;
    for (var answer in answers) {
      if (answer['grade'] == -1) {
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.appBarColor,
        iconTheme: IconThemeData(color: AppColors.buttonTextColor),
        title: Text(
          widget.ExamName,
          style: TextStyle(
            color: AppColors.buttonTextColor,
          ),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('exams')
            .doc(widget.Eid)
            .collection('studentsSubmissions')
            .snapshots(), // This creates a real-time stream
        builder: (context, snapshot) {
          // Handle loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Handle error state
          if (snapshot.hasError) {
            return Center(
              child: Text("Error: ${snapshot.error}"),
            );
          }

          // Check if data is available
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("No student submissions found."),
            );
          }

          // Convert snapshot to list of submissions
          final submissions = snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            data['Sid'] = doc.id; // Include document ID as student ID
            return data;
          }).toList();

          return ListView.builder(
            itemCount: submissions.length,
            itemBuilder: (context, index) {
              final submission = submissions[index];
              final studentName = submission['Sname'] ?? 'Unknown Student';
              final studentEmail = submission['Semail'] ?? 'Unknown Email';
              final studentId = submission['Sid']; // Get student ID
              final answers = submission['answers'] as List<dynamic>?;

              // Check if grading is required
              final needsGrading = requiresAdminGrading(answers);

              return Card(
                margin: const EdgeInsets.all(8.0),
                elevation: 4.0,
                child: ListTile(
                  leading: const Icon(
                    Icons.person,
                    color: AppColors.buttonColor,
                  ),
                  title: Text(studentName),
                  subtitle: Text(studentEmail),
                  trailing: needsGrading
                      ? const Icon(Icons.info, color: Colors.orange)
                      : null,
                  onTap: () {
                    // Navigate to StudentGradingPage with student ID
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            StudentGradingPage(Sid: studentId, Eid: widget.Eid),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
