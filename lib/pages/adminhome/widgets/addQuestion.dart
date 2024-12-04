import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AddQuestion extends StatefulWidget {
  final Function(String, String, List<String>, String?, String) onAddQuestion;

  AddQuestion({required this.onAddQuestion});

  @override
  _AddQuestionState createState() => _AddQuestionState();
}

class _AddQuestionState extends State<AddQuestion> {
  String questionType = '';
  String question = '';
  String Questiongrade = '';
  List<String> options = ['', '', '', ''];
  String? correctAnswer;
// Helper method to check for duplicate options
  bool _isDuplicateOption(String currentOption, int currentIndex) {
    // Ignore empty options
    if (currentOption.trim().isEmpty) return false;

    // Check if this option appears in any other index
    return options.where((option) => option == currentOption).toList().length >
        1;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Question'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Dropdown to select the question type
          DropdownButton<String>(
            value: questionType.isEmpty ? null : questionType,
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
            decoration: InputDecoration(labelText: 'Enter Question'),
            onChanged: (value) {
              setState(() {
                question = value;
              });
            },
          ),
          TextFormField(
            decoration: InputDecoration(labelText: "Enter Question Grade"),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              Questiongrade = value;
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
            // Additional check to ensure no duplicate options
            bool hasDuplicates = options
                    .where((option) => option.trim().isNotEmpty)
                    .toSet()
                    .length <
                options.where((option) => option.trim().isNotEmpty).length;

            if (question.isNotEmpty &&
                questionType.isNotEmpty &&
                Questiongrade.isNotEmpty &&
                (questionType == 'Short Answer' ||
                    questionType == 'Essay' ||
                    (correctAnswer != null && !hasDuplicates))) {
              widget.onAddQuestion(questionType, question, options,
                  correctAnswer, Questiongrade);
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
          child: Text('Add Question'),
        ),
      ],
    );
  }
}
