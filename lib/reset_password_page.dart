import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:another_flushbar/flushbar.dart';


class ResetPasswordPage extends StatefulWidget {
  final int userId;
  ResetPasswordPage({required this.userId});

  @override
  _ResetPasswordPageState createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final TextEditingController otpController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String errorMessage = '';

  Future<void> _resetPassword() async {
    final url = '${dotenv.env['BACKEND_URL']}/api/user/reset-password';
    final body = json.encode({
      'user_id': widget.userId,
      'otp_code': otpController.text,
      'new_password': passwordController.text,
    });

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200) {
        _showFlushbar("Password reset successful", Colors.green);

        // Delay navigation to allow Flushbar to display
        Future.delayed(Duration(seconds: 2), () {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.popUntil(context, (route) => route.isFirst);
          });
        });
      } else {
        _showFlushbar("Failed to reset Password: Incorrect or expired OTP", Colors.red);
        setState(() {
          errorMessage = 'Failed to reset password';
        });
      }
    } catch (error) {
      _showFlushbar("Network Error: $error", Colors.red);
      setState(() {
        errorMessage = 'Network error: $error';
      });
    }
  }

  void _showFlushbar(String message, Color color) {
    Flushbar(
      message: message,
      backgroundColor: color,
      duration: Duration(seconds: 3),
      margin: EdgeInsets.all(8),
      borderRadius: BorderRadius.circular(8),
      flushbarPosition: FlushbarPosition.BOTTOM,
    ).show(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Reset Password")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: otpController,
              decoration: InputDecoration(labelText: "OTP"),
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: "New Password"),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _resetPassword,
              child: Text("Reset Password"),
            ),
            if (errorMessage.isNotEmpty)
              Text(errorMessage, style: TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }
}
