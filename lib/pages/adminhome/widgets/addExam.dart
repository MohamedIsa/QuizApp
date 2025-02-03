import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quizapp/constant.dart';
import 'package:quizapp/pages/adminhome/widgets/addQuestionExam.dart';

class AddExamWidget extends StatefulWidget {
  const AddExamWidget({super.key});

  @override
  State<AddExamWidget> createState() => _AddExamWidgetState();
}

class _AddExamWidgetState extends State<AddExamWidget> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _examNameController = TextEditingController();
  final TextEditingController _attemptsController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;

  //==================================================================================
  // Helper Methods
  //==================================================================================
  Future<void> _pickDateTime(BuildContext context,
      {required bool isStart}) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        setState(() {
          final selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );

          if (isStart) {
            _startDate = selectedDateTime;
          } else {
            _endDate = selectedDateTime;
          }
        });
      }
    }
  }

  void _saveExam() async {
    if (_formKey.currentState!.validate()) {
      if (_startDate == null || _endDate == null) {
        SnackbarUtils.showErrorSnackbar(
            context, 'Please select both start and end dates.');
        return;
      }

      if (_endDate!.isBefore(_startDate!)) {
        SnackbarUtils.showErrorSnackbar(
            context, 'End date cannot be before the start date.');
        return;
      }

      int? duration = int.tryParse(_durationController.text);
      if (duration == null) {
        SnackbarUtils.showErrorSnackbar(
            context, 'Please enter a valid duration in minutes.');
        return;
      }

      Duration timeDifference = _endDate!.difference(_startDate!);
      int availableMinutes = timeDifference.inMinutes;

      if (duration > availableMinutes) {
        SnackbarUtils.showErrorSnackbar(context,
            'Duration cannot be longer than the time between start and end dates.');
        return;
      }

      int attempts = int.parse(_attemptsController.text.trim());
      try {
        final docRef =
            await FirebaseFirestore.instance.collection('exams').add({
          'examName': _examNameController.text.trim(),
          'attempts': attempts,
          'duration': duration,
          'startDate': _startDate!.toIso8601String(),
          'endDate': _endDate!.toIso8601String(),
        });

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => AddQuestionExam(examId: docRef.id),
          ),
        );

        _clearForm();
      } catch (e) {
        SnackbarUtils.showErrorSnackbar(
            context, 'Failed to save the exam. Try again.');
      }
    }
  }

  void _clearForm() {
    _examNameController.clear();
    _attemptsController.clear();
    _durationController.clear();
    setState(() {
      _startDate = null;
      _endDate = null;
    });
  }

  //==================================================================================
  // Build Method
  //==================================================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: AppColors.buttonTextColor),
        title: const Text(
          "Add New Exam",
          style: TextStyle(color: AppColors.buttonTextColor),
        ),
        backgroundColor: AppColors.appBarColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _examNameController,
                decoration: InputDecoration(
                  labelText: "Exam Name",
                  labelStyle: const TextStyle(
                      color: AppColors.textBlack), // Label color
                  hintText: "Enter the exam name", // Placeholder text
                  hintStyle: const TextStyle(
                      color: AppColors.textBlack), // Placeholder style
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                        color: AppColors.appBarColor), // Border color
                    borderRadius: BorderRadius.circular(8), // Rounded corners
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                        color: AppColors.appBarColor,
                        width: 2), // Border when focused
                    borderRadius: BorderRadius.circular(8),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                        color: Colors.red), // Border for errors
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.red, width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.edit,
                      color: AppColors.appBarColor), // Icon
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter the exam name.";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16), // Space between fields
              TextFormField(
                controller: _attemptsController,
                decoration: InputDecoration(
                  labelText: "Number of Attempts",
                  labelStyle: const TextStyle(color: AppColors.textBlack),
                  hintText: "Enter number of attempts",
                  hintStyle: const TextStyle(color: AppColors.textBlack),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: AppColors.appBarColor),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                        color: AppColors.appBarColor, width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.red),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.red, width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon:
                      const Icon(Icons.replay, color: AppColors.appBarColor),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter the number of attempts.";
                  }
                  int? attempts = int.tryParse(value);
                  if (attempts == null || attempts <= 0) {
                    return "Attempts must be greater than zero.";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16), // Space between fields
              TextFormField(
                controller: _durationController,
                decoration: InputDecoration(
                  labelText: "Duration (minutes)",
                  labelStyle: const TextStyle(color: AppColors.textBlack),
                  hintText: "Enter duration in minutes",
                  hintStyle: const TextStyle(color: AppColors.textBlack),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: AppColors.appBarColor),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                        color: AppColors.appBarColor, width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.red),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.red, width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon:
                      const Icon(Icons.timer, color: AppColors.appBarColor),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter the duration in minutes.";
                  }
                  int? duration = int.tryParse(value);
                  if (duration == null || duration <= 0) {
                    return "Duration must be a positive number.";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColors.appBarColor, // Border color
                    width: 1, // Border width
                  ),
                  borderRadius: BorderRadius.circular(8), // Rounded corners
                ),
                child: ListTile(
                  title: Text(
                    "Start Date: ${_startDate != null ? _startDate!.toString() : 'Select Start Date'}",
                    style: const TextStyle(
                        color: AppColors.textBlack), // Text color
                  ),
                  trailing: const Icon(
                    Icons.calendar_today,
                    color: AppColors.appBarColor, // Icon color
                  ),
                  onTap: () => _pickDateTime(context, isStart: true),
                ),
              ),
              const SizedBox(height: 10), // Space between ListTile items
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColors.appBarColor, // Border color
                    width: 1, // Border width
                  ),
                  borderRadius: BorderRadius.circular(8), // Rounded corners
                ),
                child: ListTile(
                  title: Text(
                    "End Date: ${_endDate != null ? _endDate!.toString() : 'Select End Date'}",
                    style: const TextStyle(
                        color: AppColors.textBlack), // Text color
                  ),
                  trailing: const Icon(
                    Icons.calendar_today,
                    color: AppColors.appBarColor, // Icon color
                  ),
                  onTap: () => _pickDateTime(context, isStart: false),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.buttonColor,
                    ),
                    onPressed: _saveExam,
                    child: const Text(
                        style: TextStyle(color: AppColors.buttonTextColor),
                        "Next"),
                  ),
                  ElevatedButton(
                    onPressed: _clearForm,
                    child: const Text(
                      "Clear",
                      style: TextStyle(color: AppColors.textBlack),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
