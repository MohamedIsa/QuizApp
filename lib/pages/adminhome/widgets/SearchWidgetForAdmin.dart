import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_444/pages/adminhome/widgets/ExamWidget.dart';

class SearchWidgetForAdmin extends StatefulWidget {
  const SearchWidgetForAdmin({Key? key}) : super(key: key);

  @override
  _SearchWidgetForAdminState createState() => _SearchWidgetForAdminState();
}

class _SearchWidgetForAdminState extends State<SearchWidgetForAdmin> {
  TextEditingController searchController = TextEditingController();
  List<QueryDocumentSnapshot> allExams = [];
  List<QueryDocumentSnapshot> filteredExams = [];

  @override
  void initState() {
    super.initState();
    _fetchExams();
  }

  // Fetch all exams from Firestore
  Future<void> _fetchExams() async {
    final snapshot = await FirebaseFirestore.instance.collection('exams').get();
    setState(() {
      allExams = snapshot.docs;
      filteredExams = allExams; // Initialize filtered exams with all exams
    });
  }

  // Filter exams based on search text
  void _filterExams(String query) {
    final lowercasedQuery = query.toLowerCase();
    setState(() {
      filteredExams = allExams.where((exam) {
        final examName =
            (exam.data() as Map<String, dynamic>)['examName'] ?? '';
        return examName.toLowerCase().contains(lowercasedQuery);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    labelText: 'Search Exam...',
                    suffixIcon: IconButton(
                      icon: Icon(Icons.clear),
                      onPressed: () {
                        searchController.clear();
                        _filterExams('');
                      },
                    ),
                  ),
                  onChanged: (query) {
                    _filterExams(query);
                  },
                ),
              ),
            ],
          ),
        ),
        // Display filtered exams or original data
        Expanded(
          child: filteredExams.isEmpty
              ? Center(child: Text('No exams found.'))
              : ListView.builder(
                  itemCount: filteredExams.length,
                  itemBuilder: (context, index) {
                    final examData =
                        filteredExams[index].data() as Map<String, dynamic>;
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
                ),
        ),
      ],
    );
  }
}
