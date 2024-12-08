import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project_444/constant.dart';
import 'package:project_444/pages/adminhome/widgets/complete_exam_page.dart';
import 'package:project_444/pages/adminhome/widgets/uncompleted_exam_page.dart';
import 'package:project_444/pages/login/login_v.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_444/pages/login/user_data.dart';

class Adminhome extends StatelessWidget {
  const Adminhome({super.key});
//===================================================================
  Future<String> fetchUserName() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;

      if (userId != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();

        if (userDoc.exists) {
          return userDoc.data()?['name'] ?? 'User';
        }
      }
      return 'User';
    } catch (e) {
      return 'User';
    }
  }

  //===================================================================
  Future<void> signOut() async {
    try {
      final FirebaseAuth _auth = FirebaseAuth.instance;
      await _auth.signOut();
    } catch (e) {
      print(e.toString());
    }
  }

//===================================================================
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        //===================================================================
        // Drawer for navigation
        //===================================================================
        drawer: Drawer(
          backgroundColor: AppColors.buttonTextColor,
          child: ListView(
            children: [
              UserAccountsDrawerHeader(
                decoration: BoxDecoration(
                  color: AppColors.appBarColor,
                ),
                accountName: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${UserData.name}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: AppColors.buttonTextColor,
                      ),
                    ),
                    Text(
                      "[${UserData.role.toUpperCase()}]",
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    const Divider(
                      color: AppColors.appBarColor,
                      thickness: 1,
                      endIndent: 0,
                      height: 1,
                    ),
                  ],
                ),
                accountEmail: Text(
                  "${UserData.email}",
                  style: const TextStyle(color: AppColors.buttonTextColor),
                ),
              ),
              ListTile(
                iconColor: AppColors.buttonColor,
                textColor: AppColors.textBlack,
                tileColor: AppColors.buttonTextColor,
                leading: const Icon(Icons.home),
                title: const Text('Home'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                iconColor: AppColors.buttonColor,
                textColor: AppColors.textBlack,
                tileColor: AppColors.buttonTextColor,
                leading: const Icon(Icons.logout),
                title: const Text('Logout'),
                onTap: () async {
                  await signOut();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                    (Route<dynamic> route) => false,
                  );
                },
              ),
            ],
          ),
        ),
        //===================================================================
        // AppBar setup
        //===================================================================
        appBar: AppBar(
          backgroundColor: AppColors.appBarColor,
          iconTheme: IconThemeData(color: AppColors.buttonTextColor),
          title: FutureBuilder<String>(
            future: fetchUserName(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Text(
                  "Hi, Loading...",
                  style: TextStyle(color: AppColors.buttonTextColor),
                );
              } else if (snapshot.hasError || !snapshot.hasData) {
                return Text(
                  "Hi, User",
                  style: TextStyle(color: AppColors.buttonTextColor),
                );
              } else {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Hi, ${snapshot.data}",
                      style: TextStyle(
                          fontSize: 18.0, color: AppColors.buttonTextColor),
                    ),
                    StreamBuilder<int>(
                      stream: _countNegativeGradeStudentsStream(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Icon(Icons.notifications);
                        } else if (snapshot.hasError) {
                          return Icon(Icons.notifications);
                        } else {
                          final count = snapshot.data ?? 0;
                          if (count > 0) {
                            return Badge.count(
                              count: count,
                              child: Icon(Icons.notifications),
                            );
                          } else {
                            return Icon(Icons.notifications);
                          }
                        }
                      },
                    )
                  ],
                );
              }
            },
          ),
          //===================================================================
          // Body of the Admin Home screen
          //===================================================================
          bottom: const TabBar(
            labelColor: AppColors.buttonTextColor, // Active tab text color
            unselectedLabelColor: Colors.grey, // Inactive tab text color
            indicatorColor: AppColors.buttonTextColor,
            tabs: [
              Tab(
                icon: Icon(Icons.check_rounded),
                text: "Complete Exam",
              ),
              Tab(icon: Icon(Icons.book), text: "Upcoming Exam"),
            ],
          ),
        ),

        body: const TabBarView(
          children: [
            CompleteExamPage(),
            UncompletedExamPage(),
          ],
        ),
        //===================================================================
        // Floating Action Button for creating new exam
        //===================================================================
        floatingActionButton: FloatingActionButton(
          backgroundColor: AppColors.appBarColor,
          child: const Icon(
            Icons.add,
            color: AppColors.buttonTextColor,
          ),
          onPressed: () {
            Navigator.pushNamed(context, '/createExam');
          },
        ),
      ),
    );
  }
}

Stream<int> _countNegativeGradeStudentsStream() {
  return FirebaseFirestore.instance
      .collection('exams')
      .snapshots()
      .asyncMap((_) async {
    int count = 0;
    final examsSnapshot =
        await FirebaseFirestore.instance.collection('exams').get();
    for (var exam in examsSnapshot.docs) {
      final submissionsSnapshot =
          await exam.reference.collection('studentsSubmissions').get();
      for (var submission in submissionsSnapshot.docs) {
        if (submission.data()['totalGrade'] < 0) {
          count++;
        }
      }
    }
    return count;
  });
}
