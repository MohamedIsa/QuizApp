import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../../../firebase_options.dart';

class QuestionEditDialog extends StatefulWidget {
  final Map<String, dynamic>? question;
  final Function(Map<String, dynamic>) onSubmit;

  const QuestionEditDialog({
    this.question,
    required this.onSubmit,
  });

  @override
  QuestionEditDialogState createState() => QuestionEditDialogState();
}

class QuestionEditDialogState extends State<QuestionEditDialog> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

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
