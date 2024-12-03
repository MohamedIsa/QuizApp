import 'package:flutter/material.dart';
import 'package:project_444/pages/adminhome/widgets/addQuestion.dart';

class AddQuestionExam extends StatefulWidget {
  const AddQuestionExam({super.key});

  @override
  State<AddQuestionExam> createState() => _AddQuestionExamState();
}

class _AddQuestionExamState extends State<AddQuestionExam> {
  List<Map<String, dynamic>> _questions = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Questions")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Displaying the list of questions
            Expanded(
              child: ListView.builder(
                itemCount: _questions.length,
                itemBuilder: (context, index) {
                  return ListTile(
                      title: Text(
                          '${index + 1}. ${_questions[index]['question']}'),
                      subtitle: Text.rich(
                        TextSpan(children: [
                          TextSpan(
                            text: 'Type: ${_questions[index]['type']}',
                            style: TextStyle(
                              color: Colors.blue,
                            ),
                          ),
                          TextSpan(
                            text: '\nOptions: ${_questions[index]['options']}',
                            style: TextStyle(
                              color: Colors.blue,
                            ),
                          ),
                          TextSpan(
                            text:
                                '\nCorrect Answer: ${_questions[index]['correctAnswer']}',
                            style: TextStyle(
                              color: Colors.blue,
                            ),
                          ),
                        ]),
                      ));
                },
              ),
            ),
            SizedBox(height: 20),
            // Button to add new question
            IconButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AddQuestion(
                      onAddQuestion: (String type, String question,
                          List<String> options, String? correctAnswer) {
                        setState(() {
                          _questions.add({
                            'type': type,
                            'question': question,
                            'options': options,
                            'correctAnswer': correctAnswer
                          });
                        });
                      },
                    );
                  },
                );
              },
              icon: Icon(Icons.add),
            ),
          ],
        ),
      ),
    );
  }
}
