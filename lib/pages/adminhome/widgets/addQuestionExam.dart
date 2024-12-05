import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:project_444/pages/adminhome/widgets/EditQuestion.dart';
import 'package:project_444/pages/adminhome/widgets/addQuestion.dart';

class AddQuestionExam extends StatefulWidget {
  final String examId;
  const AddQuestionExam({Key? key, required this.examId}) : super(key: key);

  @override
  State<AddQuestionExam> createState() => _AddQuestionExamState();
}

class _AddQuestionExamState extends State<AddQuestionExam> {
  List<Map<String, dynamic>> _questions = [];

  void _cancelExam() async {
    try {
      // Delete the exam document from Firestore
      await FirebaseFirestore.instance
          .collection('exams')
          .doc(widget.examId)
          .delete();

      // Navigate back
      Navigator.pop(context);
    } catch (error) {
      // Show an error message if deletion fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to cancel exam. Please try again."),
          backgroundColor: Colors.red,
        ),
      );
      print("Error deleting exam: $error");
    }
  }

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

  void _createExam() async {
    if (_questions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please add at least one question.")),
      );
      return;
    }

    try {
      // Prepare the questions with the correct fields based on the type
      List<Map<String, dynamic>> questionsToSave = _questions.map((question) {
        // Generate a unique questionId for each question
        String questionId =
            FirebaseFirestore.instance.collection('exams').doc().id;

        // Include options and correctAnswer only for Multiple Choice or True/False
        if (question['type'] == 'Multiple Choice') {
          return {
            'questionId': questionId,
            'question': question['question'],
            'type': question['type'],
            'options': question['options'], // Save options for multiple choice
            'correctAnswer': question['correctAnswer'], // Save correctAnswer
            'Questiongrade': question['Questiongrade'],
          };
        }
        // Include options and correctAnswer only for Multiple Choice or True/False
        else if (question['type'] == 'True/False') {
          return {
            'questionId': questionId,
            'question': question['question'],
            'type': question['type'],
            'correctAnswer': question['correctAnswer'], // Save correctAnswer
            'Questiongrade': question['Questiongrade'],
          };
        } else {
          return {
            'questionId': questionId,
            'question': question['question'],
            'type': question['type'],
            'Questiongrade': question['Questiongrade'],
          };
        }
      }).toList();

      // Update the existing exam document by adding questions to the examId
      await FirebaseFirestore.instance
          .collection('exams')
          .doc(widget.examId)
          .update({
        'questions': FieldValue.arrayUnion(
            questionsToSave), // Adds new questions to the existing list
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Exam created successfully!")),
      );

      Navigator.pop(context); // Go back after successful submission
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to create the exam.")),
      );
      print("Error saving exam: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Questions"),
        automaticallyImplyLeading: false,
      ),
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
                  onPressed: _cancelExam,
                  child: Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () {
                    _createExam();
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
