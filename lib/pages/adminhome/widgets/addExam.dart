import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project_444/pages/adminhome/widgets/addQuestionExam.dart';

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

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _saveExam() async {
    if (_formKey.currentState!.validate()) {
      if (_startDate == null || _endDate == null) {
        _showSnackBar('Please select both start and end dates.', Colors.red);
        return;
      }

      if (_endDate!.isBefore(_startDate!)) {
        _showSnackBar('End date cannot be before the start date.', Colors.red);
        return;
      }

      int? duration = int.tryParse(_durationController.text);
      if (duration == null) {
        _showSnackBar('Please enter a valid duration in minutes.', Colors.red);
        return;
      }

      Duration timeDifference = _endDate!.difference(_startDate!);
      int availableMinutes = timeDifference.inMinutes;

      if (duration > availableMinutes) {
        _showSnackBar(
            'Duration cannot be longer than the time between start and end dates.',
            Colors.red);
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

        _showSnackBar('Exam created successfully.', Colors.green);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => AddQuestionExam(examId: docRef.id),
          ),
        );

        _clearForm();
      } catch (e) {
        _showSnackBar('Failed to save the exam. Try again.', Colors.red);
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
      appBar: AppBar(title: const Text("Add New Exam")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _examNameController,
                decoration: const InputDecoration(labelText: "Exam Name"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter the exam name.";
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _attemptsController,
                decoration:
                    const InputDecoration(labelText: "Number of Attempts"),
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
              TextFormField(
                controller: _durationController,
                decoration:
                    const InputDecoration(labelText: "Duration (minutes)"),
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
              ListTile(
                title: Text(
                  "Start Date: ${_startDate != null ? _startDate!.toString() : 'Select Start Date'}",
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _pickDateTime(context, isStart: true),
              ),
              ListTile(
                title: Text(
                  "End Date: ${_endDate != null ? _endDate!.toString() : 'Select End Date'}",
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _pickDateTime(context, isStart: false),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: _saveExam,
                    child: const Text("Next"),
                  ),
                  ElevatedButton(
                    onPressed: _clearForm,
                    child: const Text("Clear"),
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
