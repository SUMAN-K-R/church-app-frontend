import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'success_page.dart'; // Import the success page
import 'login_page.dart';

// Verify Page
class VerifyPage extends StatefulWidget {
  @override
  _VerifyPageState createState() => _VerifyPageState();
}

class _VerifyPageState extends State<VerifyPage> {
  final TextEditingController codeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Verify OTP"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Code input field
            TextField(
              controller: codeController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: InputDecoration(
                labelText: "Enter 6-digit Code",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),

            // Final Verify button to navigate to profile page
            ElevatedButton(
              onPressed: () {
                if (codeController.text.length == 6) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SuccessPage()),
                  );
                } else {
                  _showErrorDialog(context);
                }
              },
              child: Text("Verify"),
            ),
          ],
        ),
      ),
    );
  }

  // Display error dialog for invalid code
  void _showErrorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Invalid Code"),
          content: Text("Please enter a valid 6-digit code."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }
}


