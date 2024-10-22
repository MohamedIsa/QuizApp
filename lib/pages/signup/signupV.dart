import 'package:flutter/material.dart';
import '../../firebase_options.dart';
import '../../utils/texfield.dart';

class SignUp extends StatelessWidget {
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  final TextEditingController cpassword = TextEditingController();
  SignUp({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up Page'),
        backgroundColor: Colors.green,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            child: const Text.rich(
              TextSpan(
                children: <TextSpan>[
                  TextSpan(
                    text: 'Welcome to the Sign Up Page!\n',
                    style: TextStyle(fontSize: 24),
                  ),
                  TextSpan(
                    text: 'Enter the Email and Password to sign up',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
          ReusableTextField(
            'Enter the Email',
            Icons.email,
            Colors.red,
            false,
            email,
          ),
          ReusableTextField(
            'Enter the Password',
            Icons.lock,
            Colors.red,
            true,
            password,
          ),
          ReusableTextField(
            'Confirm Password',
            Icons.lock,
            Colors.red,
            true,
            cpassword,
          ),
          Container(
            margin: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.0),
              color: Colors.blue,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {},
                borderRadius: BorderRadius.circular(16.0),
                child: Ink(
                  padding: const EdgeInsets.all(10.0),
                  child: const Center(
                    child: Text(
                      'Sign Up',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const Text(
            'Already have an account? ',
            style: TextStyle(
              fontSize: 12.0,
              color: Colors.grey,
              fontWeight: FontWeight.w600,
            ),
          ),
          InkWell(
            child: TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/login');
              },
              child: const Text(
                'Sign In',
                style: TextStyle(
                  fontSize: 12.0,
                  color: Colors.blue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const Center(
            child: Text('Or Sign Up with',
                style: TextStyle(
                  fontSize: 12.0,
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                )),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.0),
              color: Colors.white,
              border: Border.all(color: Colors.transparent),
            ),
            child: IconButton(
              onPressed: () async {
                await signInWithGoogle(context);
              },
              icon: Image.asset(
                'assets/7123025_logo_google_g_icon.png',
                height: 30,
                width: 30,
              ),
            ),
          )
        ],
      ),
    );
  }
}
