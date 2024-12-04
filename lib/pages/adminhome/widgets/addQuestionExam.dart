import 'package:flutter/material.dart';
import 'package:project_444/pages/adminhome/widgets/EditQuestion.dart';
import 'package:project_444/pages/adminhome/widgets/addQuestion.dart';

class AddQuestionExam extends StatefulWidget {
  const AddQuestionExam({super.key});

  @override
  State<AddQuestionExam> createState() => _AddQuestionExamState();
}

class _AddQuestionExamState extends State<AddQuestionExam> {
  List<Map<String, dynamic>> _questions = [];

  void _addQuestionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddQuestion(
          onAddQuestion: (String type, String question, List<String> options,
              String? correctAnswer, String questionGrade) {
            setState(() {
              _questions.add({
                'type': type,
                'question': question,
                'options': options,
                'correctAnswer': correctAnswer,
                'Questiongrade': questionGrade,
              });
            });
          },
        );
      },
    );
  }

  void _editQuestionDialog(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddQuestion(
          onAddQuestion: (String type, String question, List<String> options,
              String? correctAnswer, String questionGrade) {
            setState(() {
              _questions[index] = {
                'type': type,
                'question': question,
                'options': options,
                'correctAnswer': correctAnswer,
                'Questiongrade': questionGrade,
              };
            });
          },
        );
      },
    );
  }

  void _removeQuestion(int index) {
    setState(() {
      _questions.removeAt(index);
    });
  }

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
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      title: Text(
                          '${index + 1}. ${_questions[index]['question']}'),
                      subtitle: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: 'Type: ${_questions[index]['type']}',
                              style: TextStyle(color: Colors.blue),
                            ),
                            if (_questions[index]['type'] == 'Multiple Choice')
                              TextSpan(
                                text:
                                    '\nOptions: ${_questions[index]['options'].join(', ')}',
                                style: TextStyle(color: Colors.blue),
                              ),
                            if (_questions[index]['type'] == 'True/False' ||
                                _questions[index]['type'] == 'Multiple Choice')
                              TextSpan(
                                text:
                                    '\nCorrect Answer: ${_questions[index]['correctAnswer']}',
                                style: TextStyle(color: Colors.blue),
                              ),
                            TextSpan(
                              text:
                                  '\nGrade: ${_questions[index]['Questiongrade']}',
                              style: TextStyle(color: Colors.blue),
                            ),
                          ],
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return EditQuestion(
                                    initialType: _questions[index]['type'],
                                    initialQuestion: _questions[index]
                                        ['question'],
                                    initialOptions: _questions[index]
                                        ['options'],
                                    initialCorrectAnswer: _questions[index]
                                        ['correctAnswer'],
                                    initialGrade: _questions[index]
                                        ['Questiongrade'],
                                    onEditQuestion: (String type,
                                        String question,
                                        List<String> options,
                                        String? correctAnswer,
                                        String questionGrade) {
                                      setState(() {
                                        _questions[index] = {
                                          'type': type,
                                          'question': question,
                                          'options': options,
                                          'correctAnswer': correctAnswer,
                                          'Questiongrade': questionGrade,
                                        };
                                      });
                                    },
                                  );
                                },
                              );
                            },
                            icon: Icon(Icons.edit, color: Colors.orange),
                          ),
                          IconButton(
                            onPressed: () => _removeQuestion(index),
                            icon: Icon(Icons.delete, color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            // Button to add a new question
            ElevatedButton.icon(
              onPressed: _addQuestionDialog,
              icon: Icon(Icons.add),
              label: Text("Add Question"),
            ),
            SizedBox(height: 20),
            // Create Exam and Cancel buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OutlinedButton(
                  onPressed: () {
                    // Logic to cancel exam creation
                    Navigator.pop(context);
                  },
                  child: Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Add logic to create the exam
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Exam created successfully!")),
                    );
                  },
                  child: Text("Create Exam"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
