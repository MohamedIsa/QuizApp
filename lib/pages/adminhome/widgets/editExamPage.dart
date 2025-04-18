import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quizapp/constant.dart';
import 'package:quizapp/pages/adminhome/widgets/editExamQuestions.dart';

class EditExamPage extends StatefulWidget {
  final String Eid; // The exam ID passed to this page

  const EditExamPage({super.key, required this.Eid});

  @override
  State<EditExamPage> createState() => _EditExamPageState();
}

class _EditExamPageState extends State<EditExamPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _examNameController = TextEditingController();
  final TextEditingController _attemptsController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;

  // Loading exam data from Firestore
  Future<void> _loadExamData() async {
    try {
      DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
          .collection('exams')
          .doc(widget.Eid) // Use the exam ID passed in
          .get();

      if (docSnapshot.exists) {
        final examData = docSnapshot.data() as Map<String, dynamic>;
        _examNameController.text = examData['examName'];
        _attemptsController.text = examData['attempts'].toString();
        _durationController.text = examData['duration'].toString();
        _startDate = DateTime.parse(examData['startDate']);
        _endDate = DateTime.parse(examData['endDate']);
        setState(() {}); // Trigger rebuild after loading data
      }
    } catch (e) {
      print('Failed to load exam data: $e');
    }
  }

  // Save the edited exam data to Firestore
  Future<void> _saveExam() async {
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
        await FirebaseFirestore.instance
            .collection('exams')
            .doc(widget.Eid)
            .update({
          'examName': _examNameController.text.trim(),
          'attempts': attempts,
          'duration': duration,
          'startDate': _startDate!.toIso8601String(),
          'endDate': _endDate!.toIso8601String(),
        });
        SnackbarUtils.showSuccessSnackbar(
            context, 'Exam updated successfully.');

        Navigator.pop(context);
      } catch (e) {
        SnackbarUtils.showErrorSnackbar(
            context, 'Failed to save the exam. Try again.');
      }
    }
  }

  // Delete the exam from Firestore
  Future<void> _deleteExam() async {
    try {
      await FirebaseFirestore.instance
          .collection('exams')
          .doc(widget.Eid)
          .delete();
      SnackbarUtils.showSuccessSnackbar(context, 'Exam deleted successfully.');
      Navigator.pop(context);
    } catch (e) {
      SnackbarUtils.showErrorSnackbar(
          context, 'Failed to delete the exam. Try again.');
    }
  }

  // Pick start or end date
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

  @override
  void initState() {
    super.initState();
    _loadExamData(); // Load exam data when the page is first loaded
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: AppColors.buttonTextColor),
        backgroundColor: AppColors.appBarColor,
        title: const Text(
          "Edit Exam",
          style: TextStyle(color: AppColors.buttonTextColor),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const SizedBox(height: 20),
              TextFormField(
                controller: _examNameController,
                decoration: InputDecoration(
                  labelText: "Exam Name",
                  labelStyle:
                      TextStyle(color: AppColors.textBlack), // Label color
                  hintText: "Enter the exam name",
                  hintStyle:
                      TextStyle(color: AppColors.textBlack), // Hint text style
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color:
                            AppColors.appBarColor), // Border when not focused
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: AppColors.appBarColor,
                        width: 2), // Border when focused
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter the exam name.";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _attemptsController,
                decoration: InputDecoration(
                  labelText: "Number of Attempts",
                  labelStyle:
                      TextStyle(color: AppColors.textBlack), // Label color
                  hintText: "Enter number of attempts",
                  hintStyle:
                      TextStyle(color: AppColors.textBlack), // Hint text style
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color:
                            AppColors.appBarColor), // Border when not focused
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: AppColors.appBarColor,
                        width: 2), // Border when focused
                    borderRadius: BorderRadius.circular(8),
                  ),
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
              const SizedBox(height: 20),
              TextFormField(
                controller: _durationController,
                decoration: InputDecoration(
                  labelText: "Duration (minutes)",
                  labelStyle:
                      TextStyle(color: AppColors.textBlack), // Label color
                  hintText: "Enter duration in minutes",
                  hintStyle:
                      TextStyle(color: AppColors.textBlack), // Hint text style
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color:
                            AppColors.appBarColor), // Border when not focused
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: AppColors.appBarColor,
                        width: 2), // Border when focused
                    borderRadius: BorderRadius.circular(8),
                  ),
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
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  border:
                      Border.all(color: AppColors.appBarColor), // Border color
                  borderRadius: BorderRadius.circular(8), // Rounded corners
                ),
                child: ListTile(
                  title: Text(
                    "Start Date: ${_startDate != null ? _startDate!.toString() : 'Select Start Date'}",
                    style: TextStyle(
                        color: AppColors.textBlack), // Title text color
                  ),
                  trailing: Icon(Icons.calendar_today,
                      color: AppColors.appBarColor), // Icon color
                  onTap: () => _pickDateTime(context, isStart: true),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  border:
                      Border.all(color: AppColors.appBarColor), // Border color
                  borderRadius: BorderRadius.circular(8), // Rounded corners
                ),
                child: ListTile(
                  title: Text(
                    "End Date: ${_endDate != null ? _endDate!.toString() : 'Select End Date'}",
                    style: TextStyle(
                        color: AppColors.textBlack), // Title text color
                  ),
                  trailing: Icon(Icons.calendar_today,
                      color: AppColors.appBarColor), // Icon color
                  onTap: () => _pickDateTime(context, isStart: false),
                ),
              ),
              const SizedBox(height: 20),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.buttonColor,
                    ),
                    onPressed: _saveExam,
                    child: const Text(
                      "Save Changes",
                      style: TextStyle(color: AppColors.buttonTextColor),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.buttonColor,
                    ),
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditExamQuestions(
                            examId: widget.Eid,
                          ),
                        )),
                    child: const Text(
                      "Edit Questions",
                      style: TextStyle(color: AppColors.buttonTextColor),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Show confirmation dialog before deleting the exam
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text("Are you sure?"),
                            content: const Text(
                                "Are you sure you want to delete this exam? This action cannot be undone."),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context); // Close the dialog
                                },
                                child: const Text(
                                  "Cancel",
                                  style: TextStyle(color: AppColors.textBlack),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  _deleteExam(); // Delete the exam
                                  Navigator.pop(context); // Close the dialog
                                },
                                child: const Text(
                                  "Delete",
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: const Text(
                      "Delete Exam",
                      style: TextStyle(color: Colors.red),
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
