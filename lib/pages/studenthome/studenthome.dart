import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:project_444/pages/login/login_v.dart';

import '../../utils/examsview.dart';
import 'package:project_444/pages/login/user_data.dart';
import 'wedgets/examsview.dart';
import 'wedgets/gradeview.dart';



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

  //======================================
  // logout function
  //======================================
  Future<void> signOut() async {
    try {
      final FirebaseAuth _auth = FirebaseAuth.instance;
      return await _auth.signOut();
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  //======================================
  // build function
  //======================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          children: [
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue, // Background color

              ),
              accountName: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${UserData.name}",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.white, // Name text color
                    ),
                  ),
                  Text(
                    "[${UserData.role.toUpperCase()}]",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white70, // Role text color
                    ),
                  ),
                  Divider(
                    color: Colors.blue, // Divider color
                    thickness: 1, // Divider thickness
                    endIndent: 0, // To ensure it spans the full width
                    height: 1, // Space before and after divider
                  ),
                ],
              ),
              accountEmail: Text(
                "${UserData.email}",
                style: TextStyle(
                  color: Colors.white, // Email text color
                ),
              ),
            ),

            // DrawerHeader(
            //   decoration: BoxDecoration(
            //     color: Colors.blue,
            //   ),
            //   child: Text(
            //     'Menu',
            //     style: TextStyle(
            //       color: Colors.white,
            //       fontSize: 24,
            //     ),
            //   ),
            // ),
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
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () async {
                await signOut();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          LoginPage()), // Replace LoginPage with your actual login page widget.
                  (Route<dynamic> route) => false,
                );
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: Text("Hi, ${UserData.name} "),
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
