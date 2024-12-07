import 'package:flutter/material.dart';

class StudentExam extends StatefulWidget {
  const StudentExam({super.key});

  @override
  State<StudentExam> createState() => _StudentExamState();
}

class _StudentExamState extends State<StudentExam> {
  bool clicked = false;
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
            leading: Icon(
              Icons.book,
              color: clicked ? Colors.blue : Colors.grey,
            ),
            title: Text(
              'Exam 1',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            subtitle: Text('Date: 12/12/2021\nTime: 10:00 AM'),
            onTap: () {
              setState(() {
                clicked = !clicked;
              });
            },
          ),
        );
      },
    );
  }
}
