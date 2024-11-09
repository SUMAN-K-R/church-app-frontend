import 'package:church_app/user_page.dart';
import 'package:church_app/user_profile_register_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'forget_password.dart';
import 'registration_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';


class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
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
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20), // Spacing between Login and text fields

              // Phone number text field with box style
              TextField(
                controller: phoneNumberController,
                decoration: InputDecoration(
                  labelText: "Phone Number",
                  border: OutlineInputBorder(), // Box border
                ),
              ),
              SizedBox(height: 15),

              // Email text field with box style
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: "Email",
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
                onPressed: _loginUser,
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
                    MaterialPageRoute(builder: (context) => ForgotPasswordPage()),
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

  // Function to handle user login
  Future<void> _loginUser() async {
    final url = '${dotenv.env['BACKEND_URL']}/api/user/login'; // Use this URL for the Android emulator

    print("url: " + url);
    // Prepare the request body
    final body = json.encode({
      'phone_number': phoneNumberController.text,
      'email': emailController.text,
      'password': passwordController.text,
    });

    // Send the POST request
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200) {
        // Handle success (e.g., navigate to the User Page)
        print('Login successful: ${response.body}');
        final responseData = json.decode(response.body);
        int userId = responseData['user_id'];
        String token = responseData['token'];
        String userType = responseData['user_type'];
        bool profileExists = responseData['profile_exists'];


        //store the token in shared_preferences
        await _storeUserData(token, userType, userId);

        // Navigate based on profile status
        if (!profileExists) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => UserProfileRegisterPage(userId: responseData['user_id']),
            ),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => UserPage(userType: userType),
            ),
          );
        }
      } else {
        // Handle errors
        print('Failed to login: ${response.statusCode} - ${response.reasonPhrase}');
        setState(() {
          errorMessage = 'Failed to login: ${response.reasonPhrase}';
        });
      }
    } catch (error) {
      // Handle network errors
      print('Network error occurred: $error');
      setState(() {
        errorMessage = 'Network error: $error';
      });
    }
  }

}




// Method to store token and user_id
Future<void> _storeUserData(String token, String userType, int userId) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('userToken', token);  // Store the token
  await prefs.setString('userType', userType);
  await prefs.setInt('userId', userId);       // Store the user_id
}
