import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class EditExamQuestions extends StatefulWidget {
  final String examId;
  const EditExamQuestions({Key? key, required this.examId}) : super(key: key);

  @override
  _EditExamQuestionsState createState() => _EditExamQuestionsState();
}

class _EditExamQuestionsState extends State<EditExamQuestions> {
  List<Map<String, dynamic>> _questions = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchExamQuestions();
  }

  // Fetch exam questions
  void _fetchExamQuestions() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final examDoc = await FirebaseFirestore.instance
          .collection('exams')
          .doc(widget.examId)
          .get();

      if (examDoc.exists) {
        final data = examDoc.data();
        if (data != null && data['questions'] != null) {
          setState(() {
            _questions = List<Map<String, dynamic>>.from(data['questions']);
          });
        }
      }
    } catch (error) {
      _showErrorSnackBar("Failed to load questions: $error");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Show error snackbar
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  // Dialog for adding or editing a question
  void _showQuestionDialog({int? index}) {
    // Determine if we're editing an existing question
    final bool isEdit = index != null;

    // Prepare initial values
    final questionController = TextEditingController();
    final gradeController = TextEditingController();

    // Option controllers for Multiple Choice
    final optionControllers = List.generate(4, (_) => TextEditingController());

    // Initial values if editing
    String questionType = 'Multiple Choice';
    String? correctAnswer;
    String? existingImageUrl;

    // Populate fields if editing an existing question
    if (isEdit) {
      final currentQuestion = _questions[index!];
      questionType = currentQuestion['type'] ?? 'Multiple Choice';
      questionController.text = currentQuestion['question'] ?? '';
      gradeController.text =
          (currentQuestion['Questiongrade'] ?? 0.0).toString();
      correctAnswer = currentQuestion['correctAnswer'];
      existingImageUrl = currentQuestion['imageUrl'];

      // Populate options for Multiple Choice
      if (questionType == 'Multiple Choice' &&
          currentQuestion['options'] != null) {
        final options = currentQuestion['options'] as List;
        for (int i = 0; i < options.length && i < 4; i++) {
          optionControllers[i].text = options[i] ?? '';
        }
      }
    }

    // Image selection
    File? imageFile;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(isEdit ? 'Edit Question' : 'Add Question'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Question Type Dropdown
                    DropdownButtonFormField<String>(
                      value: questionType,
                      decoration: InputDecoration(
                        labelText: 'Question Type',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        'Multiple Choice',
                        'True/False',
                        'Short Answer',
                        'Image'
                      ]
                          .map((type) =>
                              DropdownMenuItem(value: type, child: Text(type)))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          questionType = value!;
                          // Reset type-specific fields
                          correctAnswer = null;
                          optionControllers.forEach((c) => c.clear());
                        });
                      },
                    ),
                    SizedBox(height: 10),

                    // Question Text Field
                    TextField(
                      controller: questionController,
                      decoration: InputDecoration(
                        labelText: 'Question Text',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 10),

                    // Grade Field
                    TextField(
                      controller: gradeController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Grade',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 10),

                    // Type-specific fields
                    if (questionType == 'True/False')
                      DropdownButtonFormField<String>(
                        value: correctAnswer,
                        decoration: InputDecoration(
                          labelText: 'Correct Answer',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          DropdownMenuItem(value: 'True', child: Text('True')),
                          DropdownMenuItem(
                              value: 'False', child: Text('False')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            correctAnswer = value;
                          });
                        },
                      ),

                    if (questionType == 'Multiple Choice')
                      Column(
                        children: List.generate(
                            4,
                            (i) => Column(
                                  children: [
                                    TextField(
                                      controller: optionControllers[i],
                                      decoration: InputDecoration(
                                        labelText: 'Option ${i + 1}',
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                    if (i == 0)
                                      DropdownButtonFormField<String>(
                                        value: correctAnswer,
                                        decoration: InputDecoration(
                                          labelText: 'Correct Answer',
                                          border: OutlineInputBorder(),
                                        ),
                                        items: optionControllers
                                            .where((controller) =>
                                                controller.text.isNotEmpty)
                                            .map((controller) =>
                                                DropdownMenuItem(
                                                    value: controller.text,
                                                    child:
                                                        Text(controller.text)))
                                            .toList(),
                                        onChanged: (value) {
                                          setState(() {
                                            correctAnswer = value;
                                          });
                                        },
                                      ),
                                  ],
                                )),
                      ),

                    if (questionType == 'Image')
                      Column(
                        children: [
                          // Display existing or newly selected image
                          if (existingImageUrl != null)
                            Image.network(existingImageUrl!, height: 100),
                          if (imageFile != null)
                            Image.file(imageFile!, height: 100),

                          ElevatedButton(
                            onPressed: () async {
                              final pickedFile = await ImagePicker()
                                  .pickImage(source: ImageSource.gallery);
                              if (pickedFile != null) {
                                setState(() {
                                  imageFile = File(pickedFile.path);
                                  existingImageUrl = null;
                                });
                              }
                            },
                            child: Text('Pick Image'),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Validate inputs
                    if (questionController.text.isEmpty ||
                        gradeController.text.isEmpty) {
                      _showErrorSnackBar('Please fill all required fields');
                      return;
                    }

                    // Prepare question data
                    final newQuestion = {
                      'questionId': isEdit
                          ? _questions[index!]['questionId']
                          : FirebaseFirestore.instance
                              .collection('exams')
                              .doc()
                              .id,
                      'question': questionController.text,
                      'type': questionType,
                      'Questiongrade': double.parse(gradeController.text),
                      'options': questionType == 'Multiple Choice'
                          ? optionControllers
                              .map((c) => c.text)
                              .where((text) => text.isNotEmpty)
                              .toList()
                          : [],
                      'correctAnswer': questionType == 'True/False' ||
                              questionType == 'Multiple Choice'
                          ? correctAnswer
                          : null,
                      'imageUrl': existingImageUrl
                    };

                    // Update questions list
                    setState(() {
                      if (isEdit) {
                        _questions[index!] = newQuestion;
                      } else {
                        _questions.add(newQuestion);
                      }
                    });

                    // Update Firestore
                    _updateExamQuestionsList();

                    Navigator.of(context).pop();
                  },
                  child: Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Update exam questions in Firestore
  void _updateExamQuestionsList() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection('exams')
          .doc(widget.examId)
          .update({'questions': _questions});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Exam updated successfully!"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (error) {
      _showErrorSnackBar("Failed to update exam questions: $error");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Remove question from Firestore
  void _removeQuestion(int index) async {
    // Remove image from Firebase Storage if it exists
    final question = _questions[index];
    if (question['imageUrl'] != null) {
      try {
        await FirebaseStorage.instance
            .refFromURL(question['imageUrl'])
            .delete();
      } catch (e) {
        print('Error deleting image: $e');
      }
    }

    setState(() {
      _questions.removeAt(index);
    });
    _updateExamQuestionsList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Exam Questions"),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Expanded(
                    child: _questions.isEmpty
                        ? Center(
                            child: Text(
                              "No questions added yet",
                              style: TextStyle(fontSize: 18),
                            ),
                          )
                        : ListView.builder(
                            itemCount: _questions.length,
                            itemBuilder: (context, index) {
                              final question = _questions[index];
                              return Card(
                                margin:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                child: ListTile(
                                  title: Text(
                                    '${index + 1}. ${question['question']}',
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text.rich(
                                        TextSpan(
                                          children: [
                                            TextSpan(
                                              text: 'Type: ${question['type']}',
                                              style:
                                                  TextStyle(color: Colors.blue),
                                            ),
                                            if (question['type'] ==
                                                'Multiple Choice')
                                              TextSpan(
                                                text:
                                                    '\nOptions: ${(question['options'] as List).join(', ')}',
                                                style: TextStyle(
                                                    color: Colors.blue),
                                              ),
                                            if (question['type'] ==
                                                    'True/False' ||
                                                question['type'] ==
                                                    'Multiple Choice')
                                              TextSpan(
                                                text:
                                                    '\nCorrect Answer: ${question['correctAnswer']}',
                                                style: TextStyle(
                                                    color: Colors.blue),
                                              ),
                                            TextSpan(
                                              text:
                                                  '\nGrade: ${question['Questiongrade']}',
                                              style:
                                                  TextStyle(color: Colors.blue),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (question['imageUrl'] != null)
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 8.0),
                                          child: Image.network(
                                            question['imageUrl'],
                                            width: 100,
                                            height: 100,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                    ],
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        onPressed: () =>
                                            _showQuestionDialog(index: index),
                                        icon: Icon(Icons.edit,
                                            color: Colors.orange),
                                      ),
                                      IconButton(
                                        onPressed: () => _removeQuestion(index),
                                        icon: Icon(Icons.delete,
                                            color: Colors.red),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () => _showQuestionDialog(),
                    icon: Icon(Icons.add),
                    label: Text("Add Question"),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text("Cancel"),
                      ),
                      ElevatedButton(
                        onPressed: _updateExamQuestionsList,
                        child: Text("Save Exam"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}
