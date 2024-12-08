import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project_444/pages/login/login_v.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_444/pages/adminhome/widgets/tabbar.dart';
import 'package:project_444/pages/login/user_data.dart';

class Adminhome extends StatefulWidget {
  const Adminhome({super.key});

  @override
  State<Adminhome> createState() => _AdminhomeState();
}

class _AdminhomeState extends State<Adminhome> {
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
    return Scaffold(
      //===================================================================
      // Drawer for navigation
      //===================================================================
      drawer: Drawer(
        child: ListView(
          children: [
            UserAccountsDrawerHeader(
              decoration:
                  BoxDecoration(color: Color.fromARGB(255, 103, 80, 164)),
              accountName: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${UserData.name}",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    "[${UserData.role.toUpperCase()}]",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),
                  Divider(
                    color: Color.fromARGB(255, 103, 80, 164),
                    thickness: 1,
                    endIndent: 0,
                    height: 1,
                  ),
                ],
              ),
              accountEmail: Text(
                "${UserData.email}",
                style: TextStyle(
                  color: Colors.white,
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
              leading: Icon(Icons.logout),
              title: Text('Logout'),
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
        title: FutureBuilder<String>(
          future: fetchUserName(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Text("Hi, Loading...");
            } else if (snapshot.hasError || !snapshot.hasData) {
              return Text("Hi, User");
            } else {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        "Hi, ${snapshot.data}",
                        style: TextStyle(fontSize: 18.0),
                      ),
                    ],
                  ),
                  Row(
                    children: [
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
                  ),
                ],
              );
            }
          },
        ),
      ),

      //===================================================================
      // Body of the Admin Home screen
      //===================================================================
      body: Column(
        children: [
          Expanded(child: AdminTabBar()),
        ],
      ),

      //===================================================================
      // Floating Action Button for creating new exam
      //===================================================================
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.pushNamed(context, '/createExam');
        },
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
