import 'package:firebase_auth/firebase_auth.dart';
import 'package:project_444/constant.dart';
import 'package:flutter/material.dart';
import 'package:project_444/pages/login/login_v.dart';
import 'package:project_444/pages/login/user_data.dart';
import 'widgets/examsview.dart';
import 'widgets/gradeview.dart';

class Studenthome extends StatefulWidget {
  final String name;
  Studenthome({required this.name});

  @override
  _StudenthomeState createState() => _StudenthomeState();
}

class _StudenthomeState extends State<Studenthome>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final String userId = FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // userId is already initialized as a final variable
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
      backgroundColor: AppColors.pageColor,
      drawer: Drawer(
        child: ListView(
          children: [
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(
                color: AppColors.appBarColor, // Background color
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
                    //color: Colors.blue, // Divider color
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
            ListTile(
              leading: Icon(Icons.home),
              iconColor: AppColors.buttonColor,
              title: Text(
                'Home',
                style: TextStyle(color: AppColors.textBlack),
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              iconColor: AppColors.buttonColor,
              title: Text(
                'Logout',
                style: TextStyle(color: AppColors.textBlack),
              ),
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
        title: Text(
          "Hi, ${UserData.name} ",
          style: TextStyle(color: AppColors.buttonTextColor),
        ),
        iconTheme: const IconThemeData(color: AppColors.buttonTextColor),
        backgroundColor: AppColors.appBarColor,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.buttonTextColor,
          labelColor: AppColors.buttonTextColor,
          unselectedLabelColor: Colors.grey,
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
          Center(
              child: GradeView(
            userId: userId,
          )),
        ],
      ),
    );
  }
}
