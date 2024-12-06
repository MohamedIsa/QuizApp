import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EditQuestion extends StatefulWidget {
  final String initialType;
  final String initialQuestion;
  final List<String> initialOptions;
  final String? initialCorrectAnswer;
  final String initialGrade;
  final String? imageUrl;
  final Function(String, String, List<String>, String?, String) onEditQuestion;

  EditQuestion(
      {required this.initialType,
      required this.initialQuestion,
      required this.initialOptions,
      required this.initialCorrectAnswer,
      required this.initialGrade,
      required this.onEditQuestion,
      required this.imageUrl});

  @override
  _EditQuestionState createState() => _EditQuestionState();
}

class _EditQuestionState extends State<EditQuestion> {
  late String questionType;
  late String question;
  late String questionGrade;
  late List<String> options;
  String? correctAnswer;
  late String? imageUrl;

  @override
  void initState() {
    super.initState();
    // Initialize fields with existing data
    questionType = widget.initialType;
    question = widget.initialQuestion;
    questionGrade = widget.initialGrade;
    options = List<String>.from(widget.initialOptions);
    correctAnswer = widget.initialCorrectAnswer;
    imageUrl = widget.imageUrl;
  }

  // Helper method to check for duplicate options
  bool _isDuplicateOption(String currentOption, int currentIndex) {
    if (currentOption.trim().isEmpty) return false;
    return options.where((option) => option == currentOption).toList().length >
        1;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Edit Question'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Dropdown to select the question type
          DropdownButton<String>(
            value: questionType,
            hint: Text('Select Question Type'),
            onChanged: (value) {
              setState(() {
                questionType = value!;
                correctAnswer = null;
                if (questionType == 'Multiple Choice') {
                  options = ['', '', '', ''];
                }
              });
            },
            items: ['Multiple Choice', 'True/False', 'Short Answer', 'Essay']
                .map((type) {
              return DropdownMenuItem<String>(
                value: type,
                child: Text(type),
              );
            }).toList(),
          ),
          // TextField for the question
          TextFormField(
            initialValue: question,
            decoration: InputDecoration(labelText: 'Enter Question'),
            onChanged: (value) {
              setState(() {
                question = value;
              });
            },
          ),
          TextFormField(
            initialValue: questionGrade,
            decoration: InputDecoration(labelText: "Enter Question Grade"),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              questionGrade = value;
            },
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
          ),
          // Options for multiple-choice or true/false
          if (questionType == 'Multiple Choice') ...[
            Column(
              children: List.generate(4, (index) {
                return Row(
                  children: [
                    Radio<String>(
                      value: options[index],
                      groupValue: correctAnswer,
                      onChanged: (value) {
                        setState(() {
                          correctAnswer = value;
                        });
                      },
                    ),
                    Expanded(
                      child: TextFormField(
                        initialValue: options[index],
                        decoration: InputDecoration(
                          labelText: 'Option ${index + 1}',
                          errorText: _isDuplicateOption(options[index], index)
                              ? 'Options must be unique'
                              : null,
                        ),
                        onChanged: (value) {
                          setState(() {
                            options[index] = value;
                          });
                        },
                      ),
                    ),
                  ],
                );
              }),
            ),
          ],
          // True/False options
          if (questionType == 'True/False') ...[
            Column(
              children: ['True', 'False'].map((option) {
                return RadioListTile<String>(
                  title: Text(option),
                  value: option,
                  groupValue: correctAnswer,
                  onChanged: (value) {
                    setState(() {
                      correctAnswer = value;
                    });
                  },
                );
              }).toList(),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context); // Close the dialog
          },
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            bool hasDuplicates = options
                    .where((option) => option.trim().isNotEmpty)
                    .toSet()
                    .length <
                options.where((option) => option.trim().isNotEmpty).length;

            if (question.isNotEmpty &&
                questionType.isNotEmpty &&
                questionGrade.isNotEmpty &&
                (questionType == 'Short Answer' ||
                    questionType == 'Essay' ||
                    (correctAnswer != null && !hasDuplicates))) {
              widget.onEditQuestion(questionType, question, options,
                  correctAnswer, questionGrade);
              Navigator.pop(context);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(hasDuplicates
                      ? 'Options must be unique'
                      : 'Please fill in all fields and select the correct answer.'),
                ),
              );
            }
          },
          child: Text('Save Changes'),
        ),
      ],
    );
  }
}
