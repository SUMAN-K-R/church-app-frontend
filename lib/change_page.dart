import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    home: ForgetPasswordPage(),
  ));
}

class ForgetPasswordPage extends StatefulWidget {
  @override
  _ForgetPasswordPageState createState() => _ForgetPasswordPageState();
}

class _ForgetPasswordPageState extends State<ForgetPasswordPage> {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController otpController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  bool isOtpSent = false; // Track if OTP has been sent
  bool isPasswordChanging = false; // Track if password change is in progress
  bool isSuccess = false; // Track if password change was successful

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Reset Password")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!isOtpSent && !isSuccess) ...[
              Text("Enter Phone Number or Email", style: TextStyle(fontSize: 18)),
              TextField(
                controller: phoneController,
                decoration: InputDecoration(
                  labelText: "Phone Number",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: 16),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: "Email Address",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (phoneController.text.isNotEmpty || emailController.text.isNotEmpty) {
                    // Simulate sending OTP
                    setState(() {
                      isOtpSent = true; // Set OTP sent state to true
                    });
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Please enter either phone number or email.")),
                    );
                  }
                },
                child: Text("Send OTP"),
              ),
            ] else if (isOtpSent && !isSuccess) ...[
              Text("Enter OTP sent to your phone or email", style: TextStyle(fontSize: 18)),
              SizedBox(height: 16),
              TextField(
                controller: otpController,
                decoration: InputDecoration(
                  labelText: "OTP",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (otpController.text.isNotEmpty) {
                    // Simulate OTP verification
                    if (otpController.text == "123456") { // Replace with actual OTP validation logic
                      setState(() {
                        isPasswordChanging = true; // Move to password change state
                      });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Entered invalid OTP.")),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Please enter the OTP.")),
                    );
                  }
                },
                child: Text("Verify OTP"),
              ),
            ] else if (isPasswordChanging) ...[
              Text("Enter New Password", style: TextStyle(fontSize: 18)),
              SizedBox(height: 16),
              TextField(
                controller: newPasswordController,
                decoration: InputDecoration(
                  labelText: "New Password",
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              SizedBox(height: 16),
              TextField(
                controller: confirmPasswordController,
                decoration: InputDecoration(
                  labelText: "Confirm Password",
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (newPasswordController.text.isNotEmpty &&
                      confirmPasswordController.text.isNotEmpty) {
                    if (newPasswordController.text == confirmPasswordController.text) {
                      // Simulate password change success
                      setState(() {
                        isSuccess = true; // Set success state to true
                      });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Passwords do not match.")),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Please fill in both fields.")),
                    );
                  }
                },
                child: Text("Change Password"),
              ),
            ] else if (isSuccess) ...[
              Icon(Icons.check_circle, color: Colors.green, size: 100),
              SizedBox(height: 24),
              Text("Password changed successfully!", style: TextStyle(fontSize: 18)),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  // Navigate to the login page (or home page)
                  Navigator.popUntil(context, ModalRoute.withName(Navigator.defaultRouteName));
                },
                child: Text("Go to Login Page"),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
