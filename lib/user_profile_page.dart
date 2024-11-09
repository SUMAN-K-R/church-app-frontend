import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class UserProfilePage extends StatefulWidget {
  final int userId;

  UserProfilePage({required this.userId});

  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _fullNameController;
  late TextEditingController _professionController;
  late TextEditingController _dateOfBirthController;
  late TextEditingController _maritalStatusController;
  String? _gender;

  bool _isLoading = false;
  bool _isUpdated = false;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController();
    _professionController = TextEditingController();
    _dateOfBirthController = TextEditingController();
    _maritalStatusController = TextEditingController();

    // Fetch the user profile data
    _fetchUserProfile();
  }

  // Fetch user profile details
  Future<void> _fetchUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('userToken') ?? '';

    final url = '${dotenv.env['BACKEND_URL']}/api/user/user-profile/${widget.userId}'; // Adjust endpoint
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _fullNameController.text = data['full_name'];
        _professionController.text = data['profession'];
        _dateOfBirthController.text = data['date_of_birth'];
        _maritalStatusController.text = data['marital_status'];
        _gender = data['gender'];
      });
    } else {
      print('Failed to load user profile');
    }
  }

  // Update user profile
  Future<void> _updateUserProfile() async {
    setState(() {
      _isLoading = true;
    });

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('userToken') ?? '';

    final url = '${dotenv.env['BACKEND_URL']}/api/user/user-profile/update';
    final body = json.encode({
      'user_id': widget.userId,
      'full_name': _fullNameController.text,
      'date_of_birth': _dateOfBirthController.text,
      'gender': _gender,
      'profession': _professionController.text,
      'marital_status': _maritalStatusController.text,
    });

    final response = await http.put(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: body,
    );

    if (response.statusCode == 200) {
      setState(() {
        _isUpdated = true;
      });
    } else {
      print('Failed to update profile');
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _professionController.dispose();
    _dateOfBirthController.dispose();
    _maritalStatusController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Full Name',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextFormField(
                controller: _fullNameController,
                decoration: InputDecoration(
                  hintText: 'Enter your full name',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your full name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              Text(
                'Profession',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextFormField(
                controller: _professionController,
                decoration: InputDecoration(
                  hintText: 'Enter your profession',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your profession';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              Text(
                'Date of Birth',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextFormField(
                controller: _dateOfBirthController,
                decoration: InputDecoration(
                  hintText: 'Enter your date of birth (YYYY-MM-DD)',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your date of birth';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              Text(
                'Marital Status',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextFormField(
                controller: _maritalStatusController,
                decoration: InputDecoration(
                  hintText: 'Enter your marital status',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your marital status';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              Text(
                'Gender',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              DropdownButton<String>(
                value: _gender,
                hint: Text('Select Gender'),
                items: ['Male', 'Female', 'Other']
                    .map((gender) => DropdownMenuItem(
                  value: gender,
                  child: Text(gender),
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _gender = value;
                  });
                },
              ),
              SizedBox(height: 20),
              _isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    _updateUserProfile();
                  }
                },
                child: Text('Update Profile'),
              ),
              SizedBox(height: 10),
              if (_isUpdated)
                Text(
                  'Profile updated successfully!',
                  style: TextStyle(color: Colors.green),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
