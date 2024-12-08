import 'package:flutter/material.dart';

class AppColors {
  static const Color appBarColor = Color(0xFF112D4E);
  static const Color buttonColor = Color(0xFF3F72AF);
  static const Color buttonTextColor = Colors.white;
  static const Color textBlack = Colors.black;
  static const Color pageColor = Color(0xFFF9F7F7);
  static const Color txtblue = Color(0xFFDBE2EF);
}

class SnackbarUtils {
  // Show success snackbar
  static void showSuccessSnackbar(BuildContext context, String message) {
    final snackBar = SnackBar(
      content: Text(
        message,
        style: TextStyle(color: Colors.white), // Text color
      ),
      backgroundColor: AppColors.buttonColor, // Background color for success
      duration: Duration(seconds: 2), // Duration for the snackbar
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  // Show error snackbar
  static void showErrorSnackbar(BuildContext context, String message) {
    final snackBar = SnackBar(
      content: Text(
        message,
        style: TextStyle(color: Colors.white), // Text color
      ),
      backgroundColor: Colors.red, // Background color for error
      duration: Duration(seconds: 2), // Duration for the snackbar
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
