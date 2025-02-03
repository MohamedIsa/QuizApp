import 'package:flutter/material.dart';
import 'package:quizapp/utils/texfield.dart';
import '../../utils/withgoogle.dart';
import 'package:quizapp/pages/login/login_vm.dart';
import 'package:quizapp/constant.dart';

class LoginPage extends StatelessWidget {
  //===================================================================
  // text fields controllers
  //===================================================================
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  //===================================================================
  // LoginPage constructor
  //===================================================================
  LoginPage({super.key});
  //===================================================================
  // build function
  //===================================================================
  @override
  Widget build(BuildContext context) {
    //===================================================================
    // Scaffold widget
    //===================================================================
    return Scaffold(
      backgroundColor: AppColors.pageColor,
      //===================================================================
      // AppBar
      //===================================================================
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Login Page',
          style: TextStyle(color: AppColors.pageColor),
        ),
        backgroundColor: AppColors.appBarColor,
        iconTheme: const IconThemeData(color: AppColors.pageColor),
      ),
      //===================================================================
      // Body
      //===================================================================
      body: SingleChildScrollView(
        child: Column(
          children: [
            //===================================================================
            // greeting message above the text fields
            //===================================================================
            Container(
              padding: const EdgeInsets.all(20),
              child: const Text.rich(
                TextSpan(
                  children: <TextSpan>[
                    TextSpan(
                      text: 'Welcome to the Login Page!\n',
                      style: TextStyle(fontSize: 24),
                    ),
                    TextSpan(
                      text: 'Enter the Email and Password to login',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            //===================================================================
            // Email text field
            //===================================================================
            ReusableTextField(
              'Enter the Email',
              Icons.email,
              AppColors.buttonColor,
              false,
              email,
            ),
            //===================================================================
            // Password text field
            //===================================================================
            ReusableTextField(
              'Enter the Password',
              Icons.lock,
              AppColors.buttonColor,
              true,
              password,
            ),
            //===================================================================
            // SignIn button
            //===================================================================
            Container(
              margin: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.0),
                color: AppColors.buttonColor,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () async {
                    await signin(context, email, password);
                  },
                  borderRadius: BorderRadius.circular(16.0),
                  child: Ink(
                    padding: const EdgeInsets.all(10.0),
                    child: const Center(
                      child: Text(
                        'Sign In',
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
            //===================================================================
            // Dont have an account text
            //===================================================================
            Container(
              padding: const EdgeInsets.only(left: 30),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Text(
                        'Don\'t have an account?',
                        style: TextStyle(
                          fontSize: 12.0,
                          color: Colors.grey,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      InkWell(
                        child: TextButton(
                          onPressed: () {
                            Navigator.pushReplacementNamed(context, '/signup');
                          },
                          child: const Text(
                            'Sign Up',
                            style: TextStyle(
                              fontSize: 12.0,
                              color: Colors.blue,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  //===================================================================
                  // forgot your password
                  //===================================================================
                  Align(
                    alignment: Alignment.topLeft,
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/forgotpassword');
                      },
                      child: const Text('Forgot Password?',
                          style: TextStyle(color: Colors.blue)),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  //===================================================================
                  // text signIn with google
                  //===================================================================
                  const Text(
                    'Or Sign In with',
                    style: TextStyle(
                      fontSize: 12.0,
                      color: Colors.grey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  //===================================================================
                  // Button to signIn with google
                  //===================================================================
                  Container(
                    margin: const EdgeInsets.only(top: 10),
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
                        'assets/google.png',
                        height: 30,
                        width: 30,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
