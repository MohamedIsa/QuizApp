import 'package:flutter/material.dart';

class ShortAnswerQuestion extends StatelessWidget {
  // Student data
  final String Sid;
  final String Semail;
  final String Sname;
  // Question data
  final String Qid;
  final int grade;
  final String? imgURL; // Made imgURL nullable
  final String questionTxt;
  // Callback to notify the parent when the answer changes
  final Function(String answer) onAnswerChanged;

  const ShortAnswerQuestion({
    super.key,
    required this.Qid,
    required this.grade,
    this.imgURL, // Nullable parameter
    required this.questionTxt,
    required this.Sname,
    required this.Semail,
    required this.Sid,
    required this.onAnswerChanged, // Add callback
  });

  @override
  Widget build(BuildContext context) {
    // Text controller for the short answer input
    final TextEditingController shortAnswerController = TextEditingController();

    return Container(
        color: Colors.grey[100],
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
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

              // Short Answer Input
              const Text(
                "Write your short answer below:",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: shortAnswerController,
                maxLines: 1, // Single-line input for short answer
                decoration: InputDecoration(
                  hintText: "Type your answer here...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onChanged: (value) {
                  // Update the answer when user types
                  onAnswerChanged(value);
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ));
  }
}
