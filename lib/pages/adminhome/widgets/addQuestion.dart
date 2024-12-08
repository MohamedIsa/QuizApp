import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:project_444/firebase_options.dart';
import 'dart:io';
import '../../../constant.dart';
import '../../models/questions.dart';

class AddQuestion extends StatefulWidget {
  final Function(Question) onAddQuestion;
  final Question? initialQuestion;

  const AddQuestion(
      {super.key, required this.onAddQuestion, this.initialQuestion});

  @override
  AddQuestionState createState() => AddQuestionState();
}

class AddQuestionState extends State<AddQuestion> {
  final _formKey = GlobalKey<FormState>();
  String _questionType = '';
  String _questionText = '';
  int _questionGrade = 0;
  List<String> _options = ['', '', '', ''];
  String? _correctAnswer;
  File? _imageFile;
  String? _imageUrl;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();

    if (widget.initialQuestion != null) {
      _questionType = widget.initialQuestion!.questionType;
      _questionText = widget.initialQuestion!.questionText;
      _questionGrade = widget.initialQuestion!.grade;
      _options = List<String>.from(widget.initialQuestion!.options ?? []);
      _correctAnswer = widget.initialQuestion!.correctAnswer;
      _imageUrl = widget.initialQuestion!.imageUrl;
    }
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
        });
      }
    } catch (e) {
      if (mounted) {
        SnackbarUtils.showErrorSnackbar(context, 'Failed to pick image');
      }
    }
  }

  void _removeImage() {
    setState(() {
      _imageFile = null;
    });
  }

  Future<String?> _uploadImageToFirebase() async {
    if (_imageFile == null) {
      return null;
    }

    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = _imageFile!.path.split('.').last;
      String fileName = 'question_images/image_$timestamp.$extension';

      Reference reference =
          FirebaseStorage.instance.refFromURL(Bucket.ID).child(fileName);

      final TaskSnapshot snapshot = await reference.putFile(_imageFile!);

      final downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } on FirebaseException catch (e) {
      if (mounted) {
        SnackbarUtils.showErrorSnackbar(context, 'Upload failed: ${e.message}');
      }
      return null;
    } catch (e) {
      if (mounted) {
        SnackbarUtils.showErrorSnackbar(context, 'Upload failed');
      }
      return null;
    }
  }

  bool _validateOptions() {
    final nonEmptyOptions =
        _options.where((opt) => opt.trim().isNotEmpty).toList();

    return nonEmptyOptions.toSet().length == nonEmptyOptions.length;
  }

  Future<void> _submitQuestion() async {
    if (!_formKey.currentState!.validate()) return;

    if (_imageFile != null) {
      _imageUrl = await _uploadImageToFirebase();
    }

    switch (_questionType) {
      case 'Multiple Choice':
        if (_correctAnswer == null || !_validateOptions()) {
          SnackbarUtils.showErrorSnackbar(
              context, 'Please fill all options and select a correct answer');
          return;
        }
        break;
      case 'True/False':
        if (_correctAnswer == null) {
          SnackbarUtils.showErrorSnackbar(
              context, 'Please select True or False');
          return;
        }
        break;
    }

    final newQuestion = Question(
      questionId: DateTime.now().millisecondsSinceEpoch.toString(),
      questionType: _questionType,
      questionText: _questionText,
      options: _options,
      correctAnswer: _correctAnswer,
      grade: _questionGrade,
      imageUrl: _imageUrl,
    );

    if (mounted) {
      widget.onAddQuestion(newQuestion);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Add New Question',
        style: TextStyle(color: AppColors.textBlack),
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _questionType.isEmpty ? null : _questionType,
                decoration: InputDecoration(
                  labelText: 'Question Type',
                  labelStyle: TextStyle(color: AppColors.textBlack),
                  hintText: 'Select Question Type',
                  hintStyle: TextStyle(color: AppColors.textBlack),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.appBarColor),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: AppColors.appBarColor, width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
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
                    _options = ['', '', '', ''];
                  });
                },
              ),
              SizedBox(height: 16),
              if (_imageFile == null)
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.buttonColor,
                  ),
                  onPressed: _pickImage,
                  child: Text(
                    'Add Image (Optional)',
                    style: TextStyle(color: AppColors.buttonTextColor),
                  ),
                )
              else
                Stack(
                  children: [
                    Image.file(_imageFile!,
                        height: 100, width: 100, fit: BoxFit.cover),
                    Positioned(
                      right: 0,
                      child: IconButton(
                        icon: Icon(Icons.close, color: Colors.red),
                        onPressed: _removeImage,
                      ),
                    ),
                  ],
                ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Enter Question',
                  labelStyle: TextStyle(color: AppColors.textBlack),
                  hintText: 'Enter the question text',
                  hintStyle: TextStyle(color: AppColors.textBlack),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.appBarColor),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: AppColors.appBarColor, width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'Question cannot be empty'
                    : null,
                onChanged: (value) => _questionText = value,
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Question Grade',
                  labelStyle: TextStyle(color: AppColors.textBlack),
                  hintText: 'Enter the question grade',
                  hintStyle: TextStyle(color: AppColors.textBlack),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.appBarColor),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: AppColors.appBarColor, width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) => value == null || value.isEmpty
                    ? 'Grade cannot be empty'
                    : null,
                onChanged: (value) {
                  setState(() {
                    _questionGrade = int.tryParse(value) ?? 0;
                  });
                },
              ),
              SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.buttonColor,
                ),
                onPressed: _submitQuestion,
                child: Text(
                  'Save Question',
                  style: TextStyle(color: AppColors.buttonTextColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
