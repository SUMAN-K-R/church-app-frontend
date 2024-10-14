import 'package:flutter/material.dart';
import 'forget_password.dart';
import 'registration_page.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController userIdController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String errorMessage = ''; // To hold the error message

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(" ")), // Empty AppBar
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Centered and bold "Login" text
              Text(
                "Login",
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold
                ),
              ),
              SizedBox(height: 20), // Spacing between Login and text fields

              // UserID text field with box style
              TextField(
                controller: userIdController,
                decoration: InputDecoration(
                  labelText: "User ID",
                  border: OutlineInputBorder(), // Box border
                ),
              ),
              SizedBox(height: 15),

              // Password text field with box style
              TextField(
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: "Password",
                  border: OutlineInputBorder(), // Box border
                ),
                obscureText: true,
              ),
              SizedBox(height: 20), // Spacing before buttons

              // Login button
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    // Check if the UserID or password is incorrect
                    if (userIdController.text != 'correctUserID' ||
                        passwordController.text != 'correctPassword') {
                      errorMessage = 'UserID or Password is incorrect/Register';
                    } else {
                      // Clear error message on successful login
                      errorMessage = '';
                      // Perform login action (navigate to the next page)
                      // Navigator.push(...);
                    }
                  });
                },
                child: Text("Login"),
              ),

              SizedBox(height: 10),

              // Display error message if credentials are wrong
              if (errorMessage.isNotEmpty)
                Text(
                  errorMessage,
                  style: TextStyle(color: Colors.red),
                ),

              SizedBox(height: 10), // Spacing before Forget Password button

              // Forget Password button
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ForgetPasswordPage()),
                  );
                },
                child: Text("Forget Password?"),
              ),

              // Create Account (New Register) button
              TextButton(
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
      ),
    );
  }
}
