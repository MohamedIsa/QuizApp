import 'package:flutter/material.dart';

class ReusableTextField extends StatefulWidget {
  //===================================================================
  // reusable text field data
  //===================================================================
  final String hintText;
  final IconData name;
  final bool isPassword;
  final Color? color;
  final TextEditingController controller;
//===================================================================
  // reusable text field constructor
  //==================================================================
  const ReusableTextField(
      this.hintText, this.name, this.color, this.isPassword, this.controller,
      {super.key});

  @override
  _ReusableTextFieldState createState() => _ReusableTextFieldState();
}

class _ReusableTextFieldState extends State<ReusableTextField> {
  late bool _obscureText;
  //===================================================================
  // initState function
  //===================================================================
  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
  }

  //===================================================================
  // building function
  //===================================================================
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: TextField(
        controller: widget.controller,
        obscureText: _obscureText,
        style: const TextStyle(
          fontWeight: FontWeight.w400,
          color: Colors.black,
          fontSize: 16.0,
        ),
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(10.0),
          ),
          prefixIcon: Icon(widget.name, color: widget.color),
          suffixIcon: widget.isPassword
              ? IconButton(
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                  icon: Icon(
                      _obscureText ? Icons.visibility : Icons.visibility_off),
                )
              : null,
          contentPadding: const EdgeInsets.only(top: 16.0),
          hintText: widget.hintText,
          hintStyle: TextStyle(
            fontWeight: FontWeight.w400,
            color: Colors.black.withOpacity(0.5),
            fontSize: 16.0,
          ),
        ),
      ),
    );
  }
}
