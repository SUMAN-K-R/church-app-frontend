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
  late TextEditingController _marriageDateController;
  String? _gender;

  bool _isLoading = false;
  bool _isUpdated = false;
  String? _maritalStatus;
  bool _isMarried = false;
  int? _profileId;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController();
    _professionController = TextEditingController();
    _dateOfBirthController = TextEditingController();
    _maritalStatusController = TextEditingController();
    _marriageDateController = TextEditingController();

    // Fetch the user profile data
    _fetchUserProfile();
  }

  // Method to show date picker and set the date in the controller
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

  // Fetch user profile details
  Future<void> _fetchUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('userToken') ?? '';

    final url = '${dotenv.env['BACKEND_URL']}/api/user/user-profile/${widget.userId}';

    // Format date_of_birth to ISO format if not empty
    String formattedDateOfBirth = _dateOfBirthController.text.isNotEmpty
        ? DateTime.parse(_dateOfBirthController.text).toIso8601String().split('.').first + 'Z'
        : '';

    // Format marriage_date to ISO format if user is married
    String? formattedMarriageDate = _isMarried && _marriageDateController.text.isNotEmpty
        ? DateTime.parse(_marriageDateController.text).toIso8601String().split('.').first + 'Z'
        : null;

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': '$token',
      },
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final data = jsonData['user_profile'];

      setState(() {
        _profileId = data['profile_id'];
        _fullNameController.text = data['full_name'];
        _professionController.text = data['profession'];
        _dateOfBirthController.text = data['date_of_birth'];
        _maritalStatusController.text = data['marital_status'];
        _gender = data['gender'];
        if (data['marital_status'] == 'Married') {
          _isMarried = true;
          _marriageDateController.text = data['wedding_anniversary'] ?? '';
        }
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

    final url = '${dotenv.env['BACKEND_URL']}/api/user/user-profile';
    final body = json.encode({
      'profile_id': _profileId,
      'user_id': widget.userId,
      'full_name': _fullNameController.text,
      'date_of_birth': _dateOfBirthController.text,
      'gender': _gender,
      'profession': _professionController.text,
      'marital_status': _maritalStatusController.text,
      'marriage_date': _isMarried ? _marriageDateController.text : null,
    });

    print("Update Body: $body");

    final response = await http.put(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization':  '$token',
      },
      body: body,
    );

    final responseStatus = response.statusCode;
    if (response.statusCode == 200) {
      setState(() {
        _isUpdated = true;
      });
    } else {
      print("response status: $responseStatus");
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
    _marriageDateController.dispose();
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
              DropdownButton<String>(
                value: _maritalStatusController.text.isNotEmpty
                    ? _maritalStatusController.text
                    : null,
                hint: Text('Select Marital Status'),
                items: ['Single', 'Married']
                    .map((status) => DropdownMenuItem(
                  value: status,
                  child: Text(status),
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _maritalStatusController.text = value ?? '';
                    _isMarried = value == 'Married';
                  });
                },
              ),
              SizedBox(height: 20),
              if (_isMarried) ...[
                Text(
                  'Marriage Date',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextFormField(
                  controller: _marriageDateController,
                  readOnly: true,
                  onTap: () => _selectDate(context, _marriageDateController),
                  decoration: InputDecoration(
                    hintText: 'Enter your marriage date (YYYY-MM-DD)',
                  ),
                  validator: (value) {
                    if (_isMarried && (value == null || value.isEmpty)) {
                      return 'Please enter your marriage date';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
              ],
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
