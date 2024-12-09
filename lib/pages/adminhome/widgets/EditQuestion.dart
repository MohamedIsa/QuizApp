import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:project_444/constant.dart';
import 'package:project_444/firebase_options.dart';

class EditQuestion extends StatefulWidget {
  final String initialType;
  final String initialQuestion;
  final List<String> initialOptions;
  final String? initialCorrectAnswer;
  final String initialGrade;
  final String? imageUrl;
  final Function(String, String, List<String>, String?, String, String?)
      onEditQuestion;

  const EditQuestion({
    super.key,
    required this.initialType,
    required this.initialQuestion,
    required this.initialOptions,
    required this.initialCorrectAnswer,
    required this.initialGrade,
    required this.onEditQuestion,
    this.imageUrl,
  });

  @override
  _EditQuestionState createState() => _EditQuestionState();
}

class _EditQuestionState extends State<EditQuestion> {
  late String questionType;
  late String question;
  late String questionGrade;
  late List<String> options;
  String? correctAnswer;
  String? imageUrl;
  File? _imageFile;
  bool _isUploading = false;
  bool _imageDeleted = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    questionType = widget.initialType;
    question = widget.initialQuestion;
    questionGrade = widget.initialGrade;
    options = List<String>.from(widget.initialOptions);
    correctAnswer = widget.initialCorrectAnswer;
    imageUrl = widget.imageUrl;
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
          imageUrl = null;
          _imageDeleted = false;
        });
      }
    } catch (e) {
      SnackbarUtils.showErrorSnackbar(context, 'Failed to pick image');
    }
  }

  Future<String?> _uploadImage() async {
    if (_imageFile == null) return _imageDeleted ? null : imageUrl;

    setState(() => _isUploading = true);
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final path =
          'question_images/image_$timestamp.${_imageFile!.path.split('.').last}';

      final ref = FirebaseStorage.instance.refFromURL(Bucket.ID).child(path);
      final uploadTask = ref.putFile(_imageFile!);
      final snapshot = await uploadTask;

      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      SnackbarUtils.showErrorSnackbar(context, 'Failed to upload image');

      return null;
    } finally {
      setState(() => _isUploading = false);
    }
  }

  Future<void> _removeImage() async {
    try {
      setState(() {
        _imageFile = null;
        imageUrl = null;
        _imageDeleted = true;
      });
    } catch (e) {
      SnackbarUtils.showErrorSnackbar(context, 'Failed to remove image');
    }
  }

  bool _isDuplicateOption(String currentOption, int currentIndex) {
    if (currentOption.trim().isEmpty) return false;
    return options.where((option) => option == currentOption).length > 1;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Edit Question'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButton<String>(
              value: questionType,
              isExpanded: true,
              hint: Text('Select Question Type'),
              onChanged: (value) {
                setState(() {
                  questionType = value!;
                  correctAnswer = null;
                  if (questionType == 'Multiple Choice') {
                    options = List.filled(4, '');
                  }
                });
              },
              items: ['Multiple Choice', 'True/False', 'Short Answer', 'Essay']
                  .map((type) =>
                      DropdownMenuItem(value: type, child: Text(type)))
                  .toList(),
            ),

            // Image Section
            if (_imageFile != null)
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
              )
            else if (imageUrl != null && !_imageDeleted)
              Stack(
                children: [
                  Image.network(
                    imageUrl!,
                    height: 100,
                    width: 100,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return Center(child: CircularProgressIndicator());
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(Icons.error, color: Colors.red);
                    },
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: IconButton(
                      icon: Icon(Icons.close, color: Colors.red),
                      onPressed: _removeImage,
                    ),
                  ),
                ],
              ),

            // Image Controls
            if (_imageFile == null && imageUrl == null)
              ElevatedButton(
                onPressed: _pickImage,
                child: Text('Add Image (Optional)'),
              ),

            SizedBox(height: 16),

            TextFormField(
              initialValue: question,
              decoration: InputDecoration(labelText: 'Question Text'),
              onChanged: (value) => setState(() => question = value),
            ),

            TextFormField(
              initialValue: questionGrade,
              decoration: InputDecoration(labelText: 'Grade'),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                FilteringTextInputFormatter.allow(RegExp(r'[1-9][0-9]*')),
              ],
              onChanged: (value) => setState(() => questionGrade = value),
            ),

            if (questionType == 'Multiple Choice') ...[
              SizedBox(height: 16),
              ...List.generate(
                4,
                (index) {
                  if (options.length <= index) {
                    options.add('');
                  }
                  return Row(
                    children: [
                      Radio<String>(
                        value: options[index],
                        groupValue: correctAnswer,
                        onChanged: options[index].isNotEmpty
                            ? (value) => setState(() => correctAnswer = value)
                            : null,
                      ),
                      Expanded(
                        child: TextFormField(
                          initialValue: options[index],
                          decoration: InputDecoration(
                            labelText: 'Option ${index + 1}',
                            errorText: _isDuplicateOption(options[index], index)
                                ? 'Duplicate option'
                                : null,
                          ),
                          onChanged: (value) =>
                              setState(() => options[index] = value),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],

            if (questionType == 'True/False') ...[
              SizedBox(height: 16),
              ...['True', 'False'].map((option) => RadioListTile<String>(
                    title: Text(option),
                    value: option,
                    groupValue: correctAnswer,
                    onChanged: (value) => setState(() => correctAnswer = value),
                  )),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        if (_isUploading)
          CircularProgressIndicator()
        else
          TextButton(
            onPressed: () async {
              if (question.isEmpty || questionGrade.isEmpty) {
                SnackbarUtils.showErrorSnackbar(
                    context, 'Please fill all required fields');

                return;
              }

              if ((questionType == 'Multiple Choice' ||
                      questionType == 'True/False') &&
                  correctAnswer == null) {
                SnackbarUtils.showErrorSnackbar(
                    context, 'Please select correct answer');
                return;
              }

              String? finalImageUrl;
              if (!_imageDeleted) {
                finalImageUrl =
                    _imageFile != null ? await _uploadImage() : imageUrl;
              }

              widget.onEditQuestion(
                questionType,
                question,
                options,
                correctAnswer,
                questionGrade,
                finalImageUrl,
              );
              Navigator.pop(context);
            },
            child: Text('Save'),
          ),
      ],
    );
  }
}
