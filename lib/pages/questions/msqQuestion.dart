import 'package:flutter/material.dart';

class MCQQuestion extends StatelessWidget {
  final String Sid;
  final String Semail;
  final String Sname;
  final String Qid;
  final int grade;
  final String? imgURL;
  final String questionTxt;
  final String option1;
  final String option2;
  final String option3;
  final String option4;
  final String correctAnswer; // Add the correct answer parameter
  final Function(String answer, String correctAnswer)
      onAnswerChanged; // Modify callback to include correctAnswer

  const MCQQuestion({
    super.key,
    required this.Qid,
    required this.grade,
    this.imgURL,
    required this.questionTxt,
    required this.Sname,
    required this.Semail,
    required this.Sid,
    required this.option1,
    required this.option2,
    required this.option3,
    required this.option4,
    required this.correctAnswer, // Pass correctAnswer here
    required this.onAnswerChanged,
  });

  @override
  Widget build(BuildContext context) {
    ValueNotifier<String?> selectedAnswer = ValueNotifier<String?>(null);

    return Container(
      color: Colors.grey[100],
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  questionTxt,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                "$grade marks",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
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
          if (imgURL != null) const SizedBox(height: 20),
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
                    value: option1,
                    groupValue: value,
                    title: Text(option1),
                    onChanged: (val) {
                      selectedAnswer.value = val;
                      onAnswerChanged(
                          val!, correctAnswer); // Pass correctAnswer
                    },
                  ),
                  RadioListTile<String>(
                    value: option2,
                    groupValue: value,
                    title: Text(option2),
                    onChanged: (val) {
                      selectedAnswer.value = val;
                      onAnswerChanged(val!, correctAnswer);
                    },
                  ),
                  RadioListTile<String>(
                    value: option3,
                    groupValue: value,
                    title: Text(option3),
                    onChanged: (val) {
                      selectedAnswer.value = val;
                      onAnswerChanged(val!, correctAnswer);
                    },
                  ),
                  RadioListTile<String>(
                    value: option4,
                    groupValue: value,
                    title: Text(option4),
                    onChanged: (val) {
                      selectedAnswer.value = val;
                      onAnswerChanged(val!, correctAnswer);
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
