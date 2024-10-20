import 'package:church_app/verification_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RegistrationPage extends StatefulWidget {
  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isPhoneEmailFilled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Register"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Phone number field
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              maxLength: 10,
              decoration: InputDecoration(
                labelText: "Phone Number (10 digits)",
                border: OutlineInputBorder(),
              ),
              onChanged: _validateFields,
            ),
            SizedBox(height: 20),

            // Email field
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: "Email Address",
                border: OutlineInputBorder(),
              ),
              onChanged: _validateFields,
            ),
            SizedBox(height: 20),

            // Password field
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Password",
                border: OutlineInputBorder(),
              ),
              onChanged: _validateFields,
            ),
            SizedBox(height: 20),

            // Generate OTP button at the bottom
            ElevatedButton(
              onPressed: isPhoneEmailFilled ? _registerUser : null,
              child: Text("Generate OTP"),
            ),
          ],
        ),
      ),
    );
  }

  // Validate phone and email input fields
  void _validateFields(String value) {
    setState(() {
      isPhoneEmailFilled =
          phoneController.text.length == 10 &&
              emailController.text.isNotEmpty &&
              _isValidEmail(emailController.text) &&
              passwordController.text.isNotEmpty;
    });
  }

  // Validate email format
  bool _isValidEmail(String email) {
    final RegExp regex = RegExp(
        r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");
    return regex.hasMatch(email);
  }

  // Function to register the user and generate OTP
  Future<void> _registerUser() async {
    final url = 'http://10.0.2.2:6666/api/user/register'; // Use this URL for the Android emulator

    // Prepare the request body
    final body = json.encode({
      'phone_number': phoneController.text,
      'email': emailController.text,
      'password': passwordController.text, // Include the password
    });

    // Send the POST request
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      // Print the entire response
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        // Parse the response if needed
        final responseData = json.decode(response.body);
        final userId = responseData['user_id']; // Extract user_id from the response

        // Ensure userId is an int
        if (userId is int) {
          // Navigate to the OTP verification page
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => VerifyPage(userId: userId)), // Pass userId
          );
        } else {
          print('user_id is not an int: $userId');
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Unexpected user ID format.'),
          ));
        }
      } else {
        // Handle errors
        print('Failed to register: ${response.statusCode} - ${response.reasonPhrase}');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to register: ${response.reasonPhrase}'),
        ));
      }
    } catch (error) {
      // Handle network errors
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Network error: $error'),
      ));
    }
  }

}
