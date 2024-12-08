import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:project_444/constant.dart';
import 'question_edit_dialog.dart';

class EditExamQuestions extends StatefulWidget {
  final String examId;
  const EditExamQuestions({Key? key, required this.examId}) : super(key: key);

  @override
  _EditExamQuestionsState createState() => _EditExamQuestionsState();
}

class _EditExamQuestionsState extends State<EditExamQuestions> {
  final Logger _logger = Logger();
  bool _isLoading = false;
  List<Map<String, dynamic>> _questions = [];

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    setState(() => _isLoading = true);
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('exams')
          .doc(widget.examId)
          .get();

      if (snapshot.exists && snapshot.data()?['questions'] != null) {
        setState(() {
          _questions =
              List<Map<String, dynamic>>.from(snapshot.data()!['questions']);
          _isLoading = false;
        });
      } else {
        setState(() {
          _questions = [];
          _isLoading = false;
        });
      }
    } catch (error) {
      _logger.e("Fetch exam questions error: $error");
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateQuestion(Map<String, dynamic> questionData) async {
    try {
      final List<Map<String, dynamic>> updatedQuestions = [..._questions];
      final existingIndex = updatedQuestions
          .indexWhere((q) => q['questionId'] == questionData['questionId']);

      if (existingIndex >= 0) {
        updatedQuestions[existingIndex] = questionData;
      } else {
        updatedQuestions.add(questionData);
      }

      await FirebaseFirestore.instance
          .collection('exams')
          .doc(widget.examId)
          .update({'questions': updatedQuestions});

      await _loadQuestions();
    } catch (e) {
      _logger.e('Update question error: $e');
    }
  }

  Future<void> _removeQuestion(int index) async {
    try {
      final List<Map<String, dynamic>> updatedQuestions = [..._questions];
      updatedQuestions.removeAt(index);

      await FirebaseFirestore.instance
          .collection('exams')
          .doc(widget.examId)
          .update({'questions': updatedQuestions});

      await _loadQuestions();
    } catch (e) {
      _logger.e('Remove question error: $e');
    }
  }

  void _editQuestion(Map<String, dynamic>? question) {
    showDialog(
      context: context,
      builder: (context) => QuestionEditDialog(
        question: question,
        onSubmit: _updateQuestion,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.appBarColor,
        iconTheme: IconThemeData(color: AppColors.buttonTextColor),
        title: Text(
          'Edit Exam Questions',
          style: TextStyle(color: AppColors.buttonTextColor),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _questions.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    title:
                        Text('${index + 1}. ${_questions[index]['question']}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: 'Type: ${_questions[index]['type']}',
                                style: TextStyle(color: AppColors.textBlack),
                              ),
                              if (_questions[index]['type'] ==
                                  'Multiple Choice')
                                TextSpan(
                                  text:
                                      '\nOptions: ${_questions[index]['options'].join(', ')}',
                                  style: TextStyle(color: AppColors.textBlack),
                                ),
                              if (_questions[index]['type'] == 'True/False' ||
                                  _questions[index]['type'] ==
                                      'Multiple Choice')
                                TextSpan(
                                  text:
                                      '\nCorrect Answer: ${_questions[index]['correctAnswer']}',
                                  style: TextStyle(color: AppColors.textBlack),
                                ),
                              TextSpan(
                                text:
                                    '\nGrade: ${_questions[index]['Questiongrade']}',
                                style: TextStyle(color: AppColors.textBlack),
                              ),
                            ],
                          ),
                        ),
                        if (_questions[index]['imageUrl'] != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Image.network(
                              _questions[index]['imageUrl'],
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
                          onPressed: () => _editQuestion(_questions[index]),
                          icon: Icon(Icons.edit, color: AppColors.buttonColor),
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.appBarColor,
        onPressed: () => _editQuestion(null),
        child: Icon(
          Icons.add,
          color: AppColors.buttonTextColor,
        ),
      ),
    );
  }
}
