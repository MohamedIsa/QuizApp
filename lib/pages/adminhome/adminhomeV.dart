import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project_444/pages/login/login_v.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_444/pages/adminhome/widgets/tabbar.dart';
import 'package:project_444/pages/login/user_data.dart';

class Adminhome extends StatelessWidget {
  const Adminhome({super.key});

  //===================================================================
  // Fetch the user name from Firestore
  //===================================================================
  Future<String> fetchUserName() async {
    try {
      // Get the current user's ID
      final userId = FirebaseAuth.instance.currentUser?.uid;

      if (userId != null) {
        // Fetch user document from Firestore
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();

        if (userDoc.exists) {
          return userDoc.data()?['name'] ??
              'User'; // Fallback to 'User' if 'name' is null
        }
      }
      return 'User'; // Fallback if userId is null or userDoc doesn't exist
    } catch (e) {
      return 'User'; // Fallback in case of an error
    }
  }

  //===================================================================
  // Logout function
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
  // Build function to structure the admin home page
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
                    color: Color.fromARGB(255, 103, 80, 164), // Divider color
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
              leading: Icon(Icons.add),
              title: Text('Create Exam'),
              onTap: () {
                Navigator.pushNamed(context, '/createExam');
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
                      IconButton(
                        icon: Icon(Icons.person),
                        onPressed: () {
                          // Handle profile icon click
                        },
                      ),
                      Text(
                        "Hi, ${snapshot.data}",
                        style: TextStyle(fontSize: 18.0),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: Badge.count(
                          count: 99,
                          child: Icon(Icons.notifications),
                        ),
                        onPressed: () {
                          // Handle notification icon click
                        },
                      ),
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
          // Search widget for admin to search exams
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
