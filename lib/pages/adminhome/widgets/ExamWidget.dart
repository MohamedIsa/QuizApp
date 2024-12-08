import 'package:flutter/material.dart';

class ExamWidget extends StatelessWidget {
  final String examName;
  final DateTime startDate;
  final DateTime endDate;
  final int attempts;
  final VoidCallback? onTap;
  final Color color; // New optional parameter for color

  const ExamWidget({
    Key? key,
    required this.examName,
    required this.startDate,
    required this.endDate,
    required this.attempts,
    this.onTap,
    this.color = Colors.grey, // Default color is blue
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 5,
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(
          Icons.book,
          color: color, // Use the color passed or default
        ),
        title: Text(
          examName,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: color, // Use the color passed or default
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              'Start Date: ${_formatDateTime(startDate)}',
              style: TextStyle(color: Colors.grey[700]),
            ),
            Text(
              'End Date: ${_formatDateTime(endDate)}',
              style: TextStyle(color: Colors.grey[700]),
            ),
            const SizedBox(height: 8),
            Text(
              'Attempts: $attempts',
              style: TextStyle(color: color), // Use the color passed or default
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }

  // Helper method to format DateTime
  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${_twoDigits(dateTime.month)}-${_twoDigits(dateTime.day)} '
        '${_twoDigits(dateTime.hour)}:${_twoDigits(dateTime.minute)}';
  }

  // Helper method to ensure two-digit formatting
  String _twoDigits(int n) {
    return n.toString().padLeft(2, '0');
  }
}
