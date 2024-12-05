import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project_444/pages/adminhome/widgets/tabbar.dart';
import 'package:project_444/pages/login/login_v.dart';

class Adminhome extends StatelessWidget {
  //===================================================================
  // Adminhome constructor
  //===================================================================
  const Adminhome({super.key});
  //===================================================================
  // fetchUserName method
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
              'User'; // Fallback to "User" if 'name' is null
        }
      }
      return 'User'; // Fallback if userId is null or userDoc doesn't exist
    } catch (e) {
      return 'User'; // Fallback in case of an error
    }
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

  //===================================================================
  // build function
  //===================================================================
  @override
  Widget build(BuildContext context) {
    //===================================================================
    // Scaffold widget
    //===================================================================
    return Scaffold(
        //===================================================================
        // Drawer widget
        //===================================================================
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
        //===================================================================
        // AppBar
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
        // Body
        //===================================================================
        body: Center(
          child: AdminTabBar(),
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            Navigator.pushNamed(context, '/createExam');
          },
        ));
  }
}
