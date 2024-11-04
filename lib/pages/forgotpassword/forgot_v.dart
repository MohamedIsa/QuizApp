import 'package:flutter/material.dart';
import 'package:project_444/utils/texfield.dart';
import 'forgot_vm.dart';

class ForgotV extends StatelessWidget {
  final TextEditingController email = TextEditingController();
  ForgotV({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forgot Password'),
        backgroundColor: Colors.green,
      ),
      body: Column(
        children: [
          ReusableTextField(
            'Enter the Email',
            Icons.email,
            Colors.red,
            false,
            email,
          ),
          ElevatedButton(
            onPressed: () => forgetpassword(context, email),
            child: Text('Submit'),
          ),
        ],
      ),
    );
  }
}
