import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';
import 'dart:io';

import 'package:project_444/firebase_options.dart';

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
      builder: (context) => _QuestionEditDialog(
        question: question,
        onSubmit: _updateQuestion,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Exam Questions'),
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
                                style: TextStyle(color: Colors.blue),
                              ),
                              if (_questions[index]['type'] ==
                                  'Multiple Choice')
                                TextSpan(
                                  text:
                                      '\nOptions: ${_questions[index]['options'].join(', ')}',
                                  style: TextStyle(color: Colors.blue),
                                ),
                              if (_questions[index]['type'] == 'True/False' ||
                                  _questions[index]['type'] ==
                                      'Multiple Choice')
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _editQuestion(null),
        child: Icon(Icons.add),
      ),
    );
  }
}

class _QuestionEditDialog extends StatefulWidget {
  final Map<String, dynamic>? question;
  final Function(Map<String, dynamic>) onSubmit;

  const _QuestionEditDialog({
    this.question,
    required this.onSubmit,
  });

  @override
  _QuestionEditDialogState createState() => _QuestionEditDialogState();
}

class _QuestionEditDialogState extends State<_QuestionEditDialog> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  final Logger _logger = Logger();

  String _questionType = 'Multiple Choice';
  String _questionText = '';
  int _questionGrade = 0;
  List<String> _options = List.filled(4, '');
  String? _correctAnswer;
  File? _imageFile;
  String? _imageUrl;

  @override
  void initState() {
    super.initState();
    if (widget.question != null) {
      _initializeFromExistingQuestion();
    }
  }

  void _initializeFromExistingQuestion() {
    try {
      _questionType = widget.question!['type'] ?? 'Multiple Choice';
      _questionText = widget.question!['question'] ?? '';
      _questionGrade =
          (widget.question!['Questiongrade'] as num?)?.toInt() ?? 0;
      _correctAnswer = widget.question!['correctAnswer'];
      _imageUrl = widget.question!['imageUrl'];

      if (_questionType == 'Multiple Choice') {
        final List<dynamic>? existingOptions = widget.question!['options'];
        if (existingOptions != null) {
          _options = List.from(existingOptions.map((o) => o.toString()));
          while (_options.length < 4) {
            _options.add('');
          }
          _options = _options.take(4).toList();
        }
      }
    } catch (e) {
      _logger.e('Error initializing question data: $e');
      _resetToDefaults();
    }
  }

  void _resetToDefaults() {
    _questionType = 'Multiple Choice';
    _questionText = '';
    _questionGrade = 0;
    _options = List.filled(4, '');
    _correctAnswer = null;
    _imageUrl = null;
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1800,
        maxHeight: 1800,
      );

      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
          _imageUrl = null;
        });
      }
    } catch (e) {
      _logger.e('Image picking error: $e');
      _showError('Failed to pick image');
    }
  }

  Future<String?> _uploadImageToFirebase() async {
    if (_imageFile == null) return _imageUrl;

    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = _imageFile!.path.split('.').last;
      String fileName = 'question_images/image_$timestamp.$extension';

      Reference reference =
          FirebaseStorage.instance.refFromURL(Bucket.ID).child(fileName);

      final TaskSnapshot snapshot = await reference.putFile(_imageFile!);
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      _logger.e('Image upload error: $e');
      _showError('Failed to upload image');
      return null;
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  bool _validateForm() {
    if (!_formKey.currentState!.validate()) return false;

    if (_questionType == 'Multiple Choice') {
      final nonEmptyOptions =
          _options.where((o) => o.trim().isNotEmpty).toList();
      if (nonEmptyOptions.length < 2) {
        _showError('Please add at least 2 options');
        return false;
      }
      if (_correctAnswer == null || _correctAnswer!.isEmpty) {
        _showError('Please select a correct answer');
        return false;
      }
    }

    if (_questionType == 'True/False' && _correctAnswer == null) {
      _showError('Please select True or False');
      return false;
    }

    return true;
  }

  Future<void> _submitQuestion() async {
    if (!_validateForm()) return;

    try {
      final imageUrl = await _uploadImageToFirebase();

      final newQuestionData = {
        'questionId': widget.question?['questionId'] ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        'type': _questionType,
        'question': _questionText.trim(),
        'Questiongrade': _questionGrade,
        'options': _questionType == 'Multiple Choice'
            ? _options.where((o) => o.trim().isNotEmpty).toList()
            : [],
        'correctAnswer': _correctAnswer,
        'imageUrl': imageUrl,
      };

      widget.onSubmit(newQuestionData);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      _logger.e('Error submitting question: $e');
      _showError('Failed to save question');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title:
          Text(widget.question != null ? 'Edit Question' : 'Add New Question'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: _questionType,
                decoration: InputDecoration(labelText: 'Question Type'),
                items: [
                  'Multiple Choice',
                  'True/False',
                  'Short Answer',
                  'Essay'
                ]
                    .map((type) =>
                        DropdownMenuItem(value: type, child: Text(type)))
                    .toList(),
                validator: (value) =>
                    value == null ? 'Please select a question type' : null,
                onChanged: (value) {
                  setState(() {
                    _questionType = value!;
                    _correctAnswer = null;
                    _options = List.filled(4, '');
                  });
                },
              ),
              if (_imageFile == null && _imageUrl == null)
                ElevatedButton(
                  onPressed: _pickImage,
                  child: Text('Add Image (Optional)'),
                )
              else if (_imageFile != null)
                Column(
                  children: [
                    Image.file(_imageFile!, height: 100, width: 100),
                    TextButton(
                      onPressed: () => setState(() => _imageFile = null),
                      child: Text('Remove Image'),
                    ),
                  ],
                )
              else if (_imageUrl != null)
                Column(
                  children: [
                    Image.network(_imageUrl!, height: 100, width: 100),
                    TextButton(
                      onPressed: () => setState(() => _imageUrl = null),
                      child: Text('Remove Image'),
                    ),
                    TextButton(
                      onPressed: _pickImage,
                      child: Text('Change Image'),
                    ),
                  ],
                ),
              TextFormField(
                initialValue: _questionText,
                decoration: InputDecoration(labelText: 'Enter Question'),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Question cannot be empty' : null,
                onChanged: (value) => _questionText = value,
              ),
              TextFormField(
                initialValue: _questionGrade.toString(),
                decoration: InputDecoration(labelText: 'Question Grade'),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Grade cannot be empty' : null,
                onChanged: (value) => _questionGrade = int.tryParse(value) ?? 0,
              ),
              if (_questionType == 'Multiple Choice')
                ...List.generate(
                  4,
                  (index) => Row(
                    children: [
                      Radio<String>(
                        value: _options[index],
                        groupValue: _correctAnswer,
                        onChanged: _options[index].isNotEmpty
                            ? (value) => setState(() => _correctAnswer = value)
                            : null,
                      ),
                      Expanded(
                        child: TextFormField(
                          initialValue: _options[index],
                          decoration: InputDecoration(
                            labelText: 'Option ${index + 1}',
                          ),
                          onChanged: (value) {
                            setState(() => _options[index] = value);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              if (_questionType == 'True/False')
                Column(
                  children: ['True', 'False']
                      .map((option) => RadioListTile<String>(
                            title: Text(option),
                            value: option,
                            groupValue: _correctAnswer,
                            onChanged: (value) =>
                                setState(() => _correctAnswer = value),
                          ))
                      .toList(),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submitQuestion,
          child: Text(widget.question != null ? 'Save' : 'Add'),
        ),
      ],
    );
  }
}
