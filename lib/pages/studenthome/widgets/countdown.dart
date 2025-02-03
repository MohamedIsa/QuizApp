// countdown_timer.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:quizapp/constant.dart';

class CountdownTimer extends StatefulWidget {
  final int duration; // Duration in seconds
  final VoidCallback onComplete; // Callback function when countdown is complete

  const CountdownTimer({
    Key? key,
    required this.duration,
    required this.onComplete, // Receive the callback function
  }) : super(key: key);

  @override
  _CountdownTimerState createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> {
  late Timer _timer;
  int _remainingTime = 0; // Remaining time in seconds
  double _progress = 0.0; // Progress for the progress bar

  @override
  void initState() {
    super.initState();
    _remainingTime =
        widget.duration; // Initialize the countdown with passed duration
    _startCountdown();
  }

  // Start the countdown timer
  void _startCountdown() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        setState(() {
          _remainingTime--; // Decrease the remaining time by 1 second
          _progress = _remainingTime /
              widget.duration; // Update progress based on remaining time
        });
      } else {
        _timer.cancel();
        widget.onComplete(); // Call the callback when countdown finishes
      }
    });
  }

  // Function to format the time remaining as mm:ss
  String getFormattedTime() {
    int minutes = _remainingTime ~/ 60; // Integer division for minutes
    int seconds = _remainingTime % 60; // Remainder for seconds
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        LinearProgressIndicator(
          value: _progress,
          color: AppColors.buttonColor,
          minHeight: 8,
        ),
        SizedBox(height: 20),
        Text(
          'Time Remaining: ${getFormattedTime()}',
          style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.buttonColor),
        ),
      ],
    );
  }
}
