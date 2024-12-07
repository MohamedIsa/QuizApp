import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_444/pages/adminhome/widgets/ExamWidget.dart';
import 'package:project_444/pages/adminhome/widgets/editExamPage.dart';

class UncompletedExamPage extends StatefulWidget {
  const UncompletedExamPage({Key? key}) : super(key: key);

  @override
  _UncompletedExamPageState createState() => _UncompletedExamPageState();
}

class _UncompletedExamPageState extends State<UncompletedExamPage> {
  late List<Timer> _timers;
  TextEditingController searchController = TextEditingController();
  List<QueryDocumentSnapshot> filteredExams = [];

  @override
  void initState() {
    super.initState();
    _timers = [];
  }

  @override
  void dispose() {
    for (var timer in _timers) {
      timer.cancel();
    }
    searchController.dispose();
    super.dispose();
  }

  List<QueryDocumentSnapshot> _filterExams(
      List<QueryDocumentSnapshot> exams, String query) {
    final lowercasedQuery = query.toLowerCase();
    final now = DateTime.now();

    return exams.where((exam) {
      final examData = exam.data() as Map<String, dynamic>;
      final examName = examData['examName']?.toString().toLowerCase() ?? '';
      final startDate = DateTime.parse(examData['startDate']);
      return examName.contains(lowercasedQuery) && now.isBefore(startDate);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: searchController,
            decoration: InputDecoration(
              labelText: 'Search Exam...',
              suffixIcon: IconButton(
                icon: Icon(Icons.clear),
                onPressed: () {
                  searchController.clear();
                  setState(() {});
                },
              ),
            ),
            onChanged: (_) => setState(() {}),
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('exams')
                .where('endDate',
                    isGreaterThan: DateTime.now().toIso8601String())
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(
                    child: Text('No uncompleted exams found.',
                        style: TextStyle(fontSize: 16)));
              }

              final now = DateTime.now();
              var exams = snapshot.data!.docs.where((doc) {
                final examData = doc.data() as Map<String, dynamic>;
                final startDate = DateTime.parse(examData['startDate']);
                return now.isBefore(startDate);
              }).toList();

              if (searchController.text.isNotEmpty) {
                exams = _filterExams(exams, searchController.text);
              }

              if (exams.isEmpty) {
                return const Center(
                    child: Text('No matching exams found.',
                        style: TextStyle(fontSize: 16)));
              }

              _setTimers(exams, now);

              return ListView.builder(
                itemCount: exams.length,
                itemBuilder: (context, index) {
                  final examData = exams[index].data() as Map<String, dynamic>;
                  final startDate = DateTime.parse(examData['startDate']);
                  final endDate = DateTime.parse(examData['endDate']);
                  final examName = examData['examName'] ?? 'Unnamed Exam';
                  final attempts = examData['attempts'] ?? 0;
                  final examId = exams[index].id;

                  return ExamWidget(
                    examName: examName,
                    startDate: startDate,
                    endDate: endDate,
                    attempts: attempts,
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditExamPage(Eid: examId),
                          ));
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  void _setTimers(List<QueryDocumentSnapshot> exams, DateTime now) {
    for (var timer in _timers) {
      timer.cancel();
    }
    _timers.clear();

    for (var exam in exams) {
      final examData = exam.data() as Map<String, dynamic>;
      final startDate = DateTime.parse(examData['startDate']);
      final difference = startDate.difference(now).inSeconds;

      if (difference > 0) {
        final timer = Timer(Duration(seconds: difference), () {
          if (mounted) setState(() {});
        });
        _timers.add(timer);
      }
    }
  }
}
