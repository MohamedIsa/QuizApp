import 'package:flutter/material.dart';

class GradeView extends StatefulWidget {
  const GradeView({super.key});

  @override
  State<GradeView> createState() => _GradeViewState();
}

class _GradeViewState extends State<GradeView> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 50,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 5,
                blurRadius: 7,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ListTile(
            title: Text(
              'Grade 1',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            subtitle: Text('Date: 12/12/2021\nTime: 10:00 AM'),
            trailing: Text('50 Marks'),
          ),
        );
      },
    );
  }
}
