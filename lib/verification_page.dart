import 'package:church_app/login_page.dart'; // Import your login page
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class VerifyPage extends StatefulWidget {
  final int userId; // Accept userId as an integer

  VerifyPage({required this.userId}); // Constructor to initialize userId

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

            // Final Verify button
            ElevatedButton(
              onPressed: _verifyOtp,
              child: Text("Verify"),
            ),
          ],
        ),
      ),
    );
  }

  // Function to verify the OTP
  Future<void> _verifyOtp() async {
    if (codeController.text.length != 6) {
      _showErrorDialog(context);
      return;
    }

    final url = 'http://10.0.2.2:6666/api/user/register/verify/otp'; // Adjust URL if necessary
    print("URL: " + url);
    // Prepare the request body
    final body = json.encode({
      'user_id': widget.userId, // Pass the user ID
      'otp_code': codeController.text, // Pass the entered OTP
    });

    // Send the POST request
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200) {
        // Show success message
        _showSuccessDialog(context);
      } else {
        // Handle errors
        print('Failed to verify: ${response.statusCode} - ${response.reasonPhrase}');
        print('Response body: ${response.body}'); // Print the response body for debugging
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to verify: ${response.reasonPhrase}'),
        ));
      }
    } catch (error) {
      // Print detailed error information
      print('Network error occurred: $error'); // Print the error for debugging
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Network error: $error'),
      ));
    }
  }

  // Display success dialog and navigate to login page
  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Registration Successful"),
          content: Text("You have registered successfully. Please log in."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()), // Navigate to your login page
                );
              },
              child: Text("OK"),
            ),
          ],
        );
      },
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
