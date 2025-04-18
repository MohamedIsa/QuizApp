import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:quizapp/constant.dart';
import 'package:quizapp/pages/adminhome/widgets/addQuestion.dart';
import '../../models/questions.dart';
import 'EditQuestion.dart';

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
      await FirebaseFirestore.instance
          .collection('exams')
          .doc(widget.examId)
          .delete();
      Navigator.pop(context);
    } catch (error) {
      SnackbarUtils.showErrorSnackbar(
          context, 'Failed to cancel exam. Please try again.');

      print("Error deleting exam: $error");
    }
  }

  void _addQuestionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddQuestion(
          onAddQuestion: (Question question) {
            setState(() {
              _questions.add({
                'type': question.questionType,
                'question': question.questionText,
                'options': question.options,
                'correctAnswer': question.correctAnswer,
                'Questiongrade': question.grade,
                'imageUrl': question.imageUrl,
              });
            });
          },
        );
      },
    );
  }

// In AddQuestionExam.dart, modify _editQuestionDialog:

  void _editQuestionDialog(int index) {
    Map<String, dynamic> existingQuestion = _questions[index];
    final currentImageUrl = existingQuestion['imageUrl'] as String?;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return EditQuestion(
          initialType: existingQuestion['type'],
          initialQuestion: existingQuestion['question'],
          initialOptions: List<String>.from(existingQuestion['options'] ?? []),
          initialCorrectAnswer: existingQuestion['correctAnswer'],
          initialGrade: existingQuestion['Questiongrade'].toString(),
          imageUrl: currentImageUrl,
          onEditQuestion: (String type, String question, List<String> options,
              String? correctAnswer, String grade, String? newImageUrl) async {
            try {
              // Delete old image if it's being replaced or removed
              if (currentImageUrl != null && currentImageUrl != newImageUrl) {
                try {
                  await FirebaseStorage.instance
                      .refFromURL(currentImageUrl)
                      .delete();
                } catch (e) {
                  print('Error deleting old image: $e');
                }
              }

              setState(() {
                _questions[index] = {
                  'type': type,
                  'question': question,
                  'options': options,
                  'correctAnswer': correctAnswer,
                  'Questiongrade': int.parse(grade),
                  'imageUrl': newImageUrl, // Use new image URL
                  'questionId': existingQuestion['questionId'],
                };
              });
            } catch (e) {
              SnackbarUtils.showErrorSnackbar(
                  context, 'Error updating question: $e');
            }
          },
        );
      },
    );
  }

  void _removeQuestion(int index) async {
    // Remove image from Firebase Storage if it exists
    if (_questions[index]['imageUrl'] != null) {
      try {
        await FirebaseStorage.instance
            .refFromURL(_questions[index]['imageUrl'])
            .delete();
      } catch (e) {
        print('Error deleting image: $e');
      }
    }

    setState(() {
      _questions.removeAt(index);
    });
  }

  void _createExam() async {
    if (_questions.isEmpty) {
      SnackbarUtils.showErrorSnackbar(
          context, 'Please add at least one question.');
      return;
    }

    try {
      List<Map<String, dynamic>> questionsToSave = _questions.map((question) {
        String questionId =
            FirebaseFirestore.instance.collection('exams').doc().id;

        // Prepare question based on type
        var baseQuestion = {
          'questionId': questionId,
          'question': question['question'],
          'type': question['type'],
          'Questiongrade': question['Questiongrade'],
          'imageUrl': question['imageUrl'],
        };

        // Add options and correct answer for specific question types
        if (question['type'] == 'Multiple Choice') {
          baseQuestion.addAll({
            'options': question['options'],
            'correctAnswer': question['correctAnswer'],
          });
        } else if (question['type'] == 'True/False') {
          baseQuestion['correctAnswer'] = question['correctAnswer'];
        }

        return baseQuestion;
      }).toList();

      // Update exam document with new questions
      await FirebaseFirestore.instance
          .collection('exams')
          .doc(widget.examId)
          .update({
        'questions': FieldValue.arrayUnion(questionsToSave),
      });

      await FirebaseFirestore.instance
          .collection('exams')
          .doc(widget.examId)
          .update({
        'totalGrade': _calculateTotalGrade(),
      });
      SnackbarUtils.showSuccessSnackbar(context, 'Exam created successfully!');

      Navigator.pop(context);
    } catch (error) {
      SnackbarUtils.showErrorSnackbar(context, 'Failed to create the exam.');
      print("Error saving exam: $error");
    }
  }

  int _calculateTotalGrade() {
    return _questions.fold(
        0, (sum, question) => sum + (question['Questiongrade'] as int));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.appBarColor,
        title: Text(
          "Add Questions",
          style: TextStyle(color: AppColors.buttonTextColor),
        ),
        automaticallyImplyLeading: false,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _questions.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      title: Text(
                          '${index + 1}. ${_questions[index]['question']}'),
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
                                    style:
                                        TextStyle(color: AppColors.textBlack),
                                  ),
                                if (_questions[index]['type'] == 'True/False' ||
                                    _questions[index]['type'] ==
                                        'Multiple Choice')
                                  TextSpan(
                                    text:
                                        '\nCorrect Answer: ${_questions[index]['correctAnswer']}',
                                    style:
                                        TextStyle(color: AppColors.textBlack),
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
                            onPressed: () => _editQuestionDialog(index),
                            icon:
                                Icon(Icons.edit, color: AppColors.buttonColor),
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
            Text(
              'Total Grade: ${_calculateTotalGrade()}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.buttonColor,
              ),
              onPressed: _addQuestionDialog,
              icon: Icon(
                Icons.add,
                color: AppColors.buttonTextColor,
              ),
              label: Text(
                "Add Question",
                style: TextStyle(color: AppColors.buttonTextColor),
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OutlinedButton(
                  onPressed: _cancelExam,
                  child: Text(
                    "Cancel",
                    style: TextStyle(color: AppColors.textBlack),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.buttonColor,
                  ),
                  onPressed: _createExam,
                  child: Text(
                    "Create Exam",
                    style: TextStyle(color: AppColors.buttonTextColor),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
