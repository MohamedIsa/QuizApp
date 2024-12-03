import 'package:flutter/material.dart';

class AddQuestion extends StatefulWidget {
  final Function(String, String, List<String>, String?) onAddQuestion;

  AddQuestion({required this.onAddQuestion});

  @override
  _AddQuestionState createState() => _AddQuestionState();
}

class _AddQuestionState extends State<AddQuestion> {
  String questionType = '';
  String question = '';
  List<String> options = ['', '', '', ''];
  String? correctAnswer;

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
                correctAnswer = null; // Reset correct answer selection
                if (questionType == 'Multiple Choice') {
                  options = ['', '', '', '']; // Reset options for MC
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
          // Options for multiple-choice or true/false
          if (questionType == 'Multiple Choice') ...[
            for (int i = 0; i < 4; i++)
              TextFormField(
                initialValue: options[i],
                decoration: InputDecoration(labelText: 'Option ${i + 1}'),
                onChanged: (value) {
                  setState(() {
                    options[i] = value;
                  });
                },
              ),
            // Radio buttons to select the correct answer
            Column(
              children: List.generate(options.length, (index) {
                return RadioListTile<String>(
                  title: Text(options[index]),
                  value: options[index],
                  groupValue: correctAnswer,
                  onChanged: (value) {
                    setState(() {
                      correctAnswer = value;
                    });
                  },
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
          // Placeholder for Short Answer and Essay (no options needed)
          if (questionType == 'Short Answer' || questionType == 'Essay') ...[
            Text('No options needed for this type of question'),
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
            if (question.isNotEmpty &&
                questionType.isNotEmpty &&
                (questionType == 'Short Answer' ||
                    questionType == 'Essay' ||
                    correctAnswer != null)) {
              widget.onAddQuestion(
                  questionType, question, options, correctAnswer);
              Navigator.pop(
                  context); // Close the dialog after adding the question
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(
                        'Please fill in all fields and select the correct answer.')),
              );
            }
          },
          child: Text('Add Question'),
        ),
      ],
    );
  }
}
