import 'package:flutter/material.dart';
import 'verification_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginPage(),
    );
  }
}

// Login Page
class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Login"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Login Page",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            // Register button
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegistrationPage()),
                );
              },
              child: Text("Register"),
            ),
          ],
        ),
      ),
    );
  }
}

// Registration Page
class RegistrationPage extends StatefulWidget {
  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

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
              decoration: InputDecoration(
                labelText: "Phone Number",
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

            // Generate OTP button at the bottom
            ElevatedButton(
              onPressed: isPhoneEmailFilled
                  ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => VerifyPage()),
                );
              }
                  : null, // Disable if phone/email are not filled
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
          phoneController.text.isNotEmpty && emailController.text.isNotEmpty;
    });
  }
}





