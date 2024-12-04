import 'package:flutter/material.dart';
import '../../utils/examsview.dart';

import '../../utils/gradeview.dart';

class Studenthome extends StatefulWidget {
  final String name;
  Studenthome({required this.name});

  @override
  _StudenthomeState createState() => _StudenthomeState();
}

class _StudenthomeState extends State<Studenthome>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Home'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: Text("hi,${widget.name}"),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: Badge.count(child: Icon(Icons.notifications), count: 99),
            onPressed: () {},
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.book), text: 'Coming Exams'),
            Tab(icon: Icon(Icons.grade), text: 'Grades'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          Center(child: StudentExam()),
          Center(child: GradeView()),
        ],
      ),
    );
  }
}
