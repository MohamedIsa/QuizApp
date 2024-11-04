import 'package:flutter/material.dart';
import '../../utils/texfield.dart';
import 'complete_vm.dart';

class Complete extends StatelessWidget {
  final TextEditingController name = TextEditingController();
  Complete({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Profile'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              child: const Text.rich(
                TextSpan(
                  children: <TextSpan>[
                    TextSpan(
                      text: 'Welcome to the Complete Profile Page!\n',
                      style: TextStyle(fontSize: 24),
                    ),
                    TextSpan(
                      text: 'Enter the details to complete your profile',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            ReusableTextField(
              'Enter the Name',
              Icons.person,
              Colors.red,
              false,
              name,
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
                  onTap: () async {
                    await completeProfile(context, name);
                  },
                  borderRadius: BorderRadius.circular(16.0),
                  child: Ink(
                    padding: const EdgeInsets.all(16.0),
                    child: const Center(
                      child: Text(
                        'Complete Profile',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
