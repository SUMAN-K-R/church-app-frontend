import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'reset_password_page.dart';  // Next page for entering OTP and new password
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ForgotPasswordPage extends StatefulWidget {
  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  String errorMessage = '';

  Future<void> _sendOtp() async {
    final url = '${dotenv.env['BACKEND_URL']}/api/user/forgot-password';
    final body = json.encode({
      'email': emailController.text,
      'phone_number': phoneNumberController.text,
    });

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        int userId = responseData['user_id'];

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResetPasswordPage(userId: userId),
          ),
        );
      } else {
        setState(() {
          errorMessage = 'Failed to send OTP';
        });
      }
    } catch (error) {
      setState(() {
        errorMessage = 'Network error: $error';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Forgot Password")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: phoneNumberController,
              decoration: InputDecoration(labelText: "Phone Number"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _sendOtp,
              child: Text("Send OTP"),
            ),
            if (errorMessage.isNotEmpty)
              Text(errorMessage, style: TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }
}
