import 'package:church_app/login_page.dart';
import 'package:church_app/user_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';


import 'package:shared_preferences/shared_preferences.dart';

class UserProfilePage extends StatefulWidget {
  final int userId;

  UserProfilePage({required this.userId});

  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController dateOfBirthController = TextEditingController();
  final TextEditingController weddingAnniversaryController = TextEditingController();
  String maritalStatus = 'Single';
  String gender = 'Male';
  final TextEditingController professionController = TextEditingController();

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        controller.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> _saveProfile() async {
    final url = '${dotenv.env['BACKEND_URL']}/api/user/user-profile';

    // Validate the Date of Birth
    if (dateOfBirthController.text.isEmpty || !RegExp(r"^\d{4}-\d{2}-\d{2}$").hasMatch(dateOfBirthController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please enter a valid date of birth (YYYY-MM-DD)'),
      ));
      return;
    }

    final dateOfBirth = DateTime.parse(dateOfBirthController.text);
    final formattedDateOfBirth = dateOfBirth.toIso8601String();

    // Initialize weddingAnniversary as null and will not include if maritalStatus is not 'Married'
    String? trimmedWeddingAnniversay;

    if (maritalStatus == 'Married') {
      if (weddingAnniversaryController.text.isEmpty || !RegExp(r"^\d{4}-\d{2}-\d{2}$").hasMatch(weddingAnniversaryController.text)) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Please enter a valid wedding anniversary date (YYYY-MM-DD)'),
        ));
        return;
      }
      final weddingAnniversary = DateTime.parse(weddingAnniversaryController.text);
      final formattedWeddingAnniversary = weddingAnniversary.toIso8601String();
      trimmedWeddingAnniversay = formattedWeddingAnniversary.split('.').first + 'Z';
    }

    final String trimmedDateOfBirth = formattedDateOfBirth.split('.').first + 'Z';

    final body = json.encode({
      'user_id': widget.userId,
      'full_name': fullNameController.text,
      'date_of_birth': trimmedDateOfBirth,
      'marital_status': maritalStatus,
      'wedding_anniversary': maritalStatus == 'Married' ? trimmedWeddingAnniversay : null,
      'gender': gender,
      'profession': professionController.text,
    });



    try {

      // Retrieve the token from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('userToken') ?? '';
      final userType = prefs.getString('userType') ?? '';

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': '$token',
        },
        body: body,
      );

      if (response.statusCode == 200) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => UserPage(userType: userType)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to save profile: ${response.reasonPhrase}'),
        ));
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Network error: $error'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Enter Personal Details"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: fullNameController,
              decoration: InputDecoration(labelText: "Full Name"),
            ),
            TextField(
              controller: dateOfBirthController,
              readOnly: true,
              onTap: () => _selectDate(context, dateOfBirthController),
              decoration: InputDecoration(labelText: "Date of Birth (YYYY-MM-DD)"),
            ),
            DropdownButtonFormField(
              value: maritalStatus,
              items: ['Single', 'Married', 'Divorced', 'Widowed']
                  .map((status) => DropdownMenuItem(value: status, child: Text(status)))
                  .toList(),
              onChanged: (value) => setState(() => maritalStatus = value!),
              decoration: InputDecoration(labelText: "Marital Status"),
            ),
            if (maritalStatus == 'Married')
              TextField(
                controller: weddingAnniversaryController,
                readOnly: true,
                onTap: () => _selectDate(context, weddingAnniversaryController),
                decoration: InputDecoration(labelText: "Wedding Anniversary (YYYY-MM-DD)"),
              ),
            DropdownButtonFormField(
              value: gender,
              items: ['Male', 'Female', 'Other']
                  .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                  .toList(),
              onChanged: (value) => setState(() => gender = value!),
              decoration: InputDecoration(labelText: "Gender"),
            ),
            TextField(
              controller: professionController,
              decoration: InputDecoration(labelText: "Profession"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveProfile,
              child: Text("Save"),
            ),
          ],
        ),
      ),
    );
  }
}
