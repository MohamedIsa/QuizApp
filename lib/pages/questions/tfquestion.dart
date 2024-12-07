import 'package:flutter/material.dart';

class TFQuestion extends StatelessWidget {
  // Student data
  final String Sid;
  final String Semail;
  final String Sname;
  // Question data
  final String Qid;
  final int grade;
  final String? imgURL; // Made imgURL nullable
  final String questionTxt;
  final String correctAnswer; // Correct answer for comparison
  // Callback to notify the parent when the answer changes
  final Function(String answer, int grade)
      onAnswerChanged; // Pass grade along with answer

  const TFQuestion({
    super.key,
    required this.Qid,
    required this.grade,
    this.imgURL, // Nullable parameter
    required this.questionTxt,
    required this.Sname,
    required this.Semail,
    required this.Sid,
    required this.correctAnswer, // Correct answer passed in constructor
    required this.onAnswerChanged, // Add callback
  });

  @override
  Widget build(BuildContext context) {
    // State management using ValueNotifier for Radio buttons
    ValueNotifier<String?> selectedAnswer = ValueNotifier<String?>(null);

    return Container(
      color: Colors.grey[100],
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question and Marks
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  questionTxt, // Use the passed question text
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                "$grade marks", // Use the passed grade
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Conditionally Display the Image
          if (imgURL != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                imgURL!,
                height: 200,
                width: 200,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Text(
                      "Image failed to load.",
                      style: TextStyle(color: Colors.red),
                    ),
                  );
                },
              ),
            ),
          if (imgURL != null)
            const SizedBox(height: 20), // Spacing if image exists

          // Radio Buttons for True/False
          const Text(
            "Select the correct answer:",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          ValueListenableBuilder<String?>(
            valueListenable: selectedAnswer,
            builder: (context, value, child) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RadioListTile<String>(
                    value: "True",
                    groupValue: value,
                    title: const Text("True"),
                    onChanged: (val) {
                      selectedAnswer.value = val;
                      // Check answer and notify parent with grade
                      int assignedGrade = (val == correctAnswer) ? grade : 0;
                      onAnswerChanged(val!, assignedGrade);
                    },
                  ),
                  RadioListTile<String>(
                    value: "False",
                    groupValue: value,
                    title: const Text("False"),
                    onChanged: (val) {
                      selectedAnswer.value = val;
                      // Check answer and notify parent with grade
                      int assignedGrade = (val == correctAnswer) ? grade : 0;
                      onAnswerChanged(val!, assignedGrade);
                    },
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
