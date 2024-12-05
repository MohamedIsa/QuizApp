import 'package:flutter/material.dart';
import 'package:project_444/pages/adminhome/widgets/complete_exam_page.dart';
import 'uncompleted_exam_page.dart';

class AdminTabBar extends StatelessWidget {
  const AdminTabBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          bottom: const TabBar(
            tabs: [
              Tab(text: "Complete Exam"),
              Tab(text: "Uncomplete Exam"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            CompleteExamPage(),
            UncompletedExamPage(),
          ],
        ),
      ),
    );
  }
}
