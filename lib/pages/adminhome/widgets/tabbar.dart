import 'package:flutter/material.dart';

class AdminTabBar extends StatelessWidget {
  const AdminTabBar({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(
            tabs: [
              Tab(text: "Complete Exam"),
              Tab(text: "Uncomplete Exam"),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                Center(child: Text('Complete Content')),
                Center(child: Text('Uncomplete Content')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
