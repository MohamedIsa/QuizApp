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

  // Pick Date and Time for Start Date
  void _pickStartDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(DateTime.now()),
      );

      if (pickedTime != null) {
        setState(() {
          _startDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  // Pick Date and Time for End Date
  void _pickEndDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(DateTime.now()),
      );

      if (pickedTime != null) {
        setState(() {
          _endDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  void _showSnackBar(BuildContext context, String message, Color color) {
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
      // Check if start and end dates are selected
      if (_startDate == null || _endDate == null) {
        _showSnackBar(
          context,
          'Please select both start and end dates.',
          Colors.red,
        );
        return;
      }

      // Validate that end date is not before start date
      if (_endDate!.isBefore(_startDate!)) {
        _showSnackBar(
          context,
          'End date cannot be before the start date.',
          Colors.red,
        );
        return;
      }

      // Validate duration
      int? duration = int.tryParse(_durationController.text);
      if (duration == null) {
        _showSnackBar(
          context,
          'Please enter a valid duration in minutes.',
          Colors.red,
        );
        return;
      }

      // Check if duration is within allowed time range
      Duration timeDifference = _endDate!.difference(_startDate!);
      int availableDurationInMinutes = timeDifference.inMinutes;

      if (duration > availableDurationInMinutes) {
        _showSnackBar(
          context,
          'Duration cannot be longer than the time between start and end dates.',
          Colors.red,
        );
        return;
      }

      try {
        // Save the exam to Firestore
        final docRef =
            await FirebaseFirestore.instance.collection('exams').add({
          'examName': _examNameController.text.trim(),
          'attempts': int.tryParse(_attemptsController.text.trim()) ?? 0,
          'duration': duration,
          'startDate': _startDate!.toIso8601String(),
          'endDate': _endDate!.toIso8601String(),
        });

        // Show success message
        _showSnackBar(
          context,
          'Exam created successfully.',
          Colors.green,
        );

        // Navigate to AddQuestionsPage with the created examId
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                AddQuestionExam(examId: docRef.id), // Use docRef.id
          ),
        );

        // Clear form after successful submission
        _clearExam();
      } catch (e) {
        // Handle Firestore errors
        _showSnackBar(
          context,
          'Failed to save the exam. Try again.',
          Colors.red,
        );
        print("Error saving exam: $e");
      }
    }
  }

  void _clearExam() {
    _examNameController.clear();
    _attemptsController.clear();
    _durationController.clear();
    setState(() {
      _startDate = null;
      _endDate = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add New Exam")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _examNameController,
                decoration: InputDecoration(labelText: "Exam Name"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter the exam name";
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _attemptsController,
                decoration: InputDecoration(labelText: "Number of Attempts"),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
              ),
              TextFormField(
                controller: _durationController,
                decoration: InputDecoration(labelText: "Duration (minutes)"),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
              ),
              ListTile(
                title: Text(
                    "Start Date: ${_startDate?.toLocal().toString().split(' ')[0] ?? 'Select Date'} ${_startDate != null ? _startDate!.hour.toString().padLeft(2, '0') + ":" + _startDate!.minute.toString().padLeft(2, '0') : ''}"),
                trailing: Icon(Icons.calendar_today),
                onTap: () => _pickStartDate(context),
              ),
              ListTile(
                title: Text(
                    "End Date: ${_endDate?.toLocal().toString().split(' ')[0] ?? 'Select Date'} ${_endDate != null ? _endDate!.hour.toString().padLeft(2, '0') + ":" + _endDate!.minute.toString().padLeft(2, '0') : ''}"),
                trailing: Icon(Icons.calendar_today),
                onTap: () => _pickEndDate(context),
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: _saveExam,
                    child: Text("Next"),
                  ),
                  ElevatedButton(
                    onPressed: _clearExam,
                    child: Text("Cancel"),
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
