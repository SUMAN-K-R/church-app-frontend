import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddDonationPage extends StatefulWidget {
  @override
  _AddDonationPageState createState() => _AddDonationPageState();
}

class _AddDonationPageState extends State<AddDonationPage> {
  int? selectedUserId;
  String selectedPurpose = "Medical Support";
  TextEditingController amountController = TextEditingController();
  TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> users = [];
  List<Map<String, dynamic>> filteredUsers = [];

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    final url = '${dotenv.env['BACKEND_URL']}/api/user/donation-user-list';

    // Retrieve the token from shared preferences
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('userToken') ?? '';

    print("Fetching users from API..."); // Log the start of the fetch
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': '$token', // Include the token in the headers
        'Content-Type': 'application/json',
      },
    );

    // Log the response status code
    print("Response status code: ${response.statusCode}");

    if (response.statusCode == 200) {
      // Log the response body
      print("Response body: ${response.body}");

      setState(() {
        users = List<Map<String, dynamic>>.from(json.decode(response.body)['users']);
        filteredUsers = users; // Initialize filteredUsers with all users
      });

      // Log the loaded users
      print("Loaded users: $users");
    } else {
      print('Failed to load users. Error: ${response.reasonPhrase}');
    }
  }

  void _filterUsers(String query) {
    if (query.isEmpty) {
      setState(() {
        filteredUsers = users; // Show all users if the query is empty
      });
    } else {
      setState(() {
        filteredUsers = users.where((user) {
          return user['phone_number'].contains(query) || user['email'].contains(query) || user['full_name'].toLowerCase().contains(query.toLowerCase());
        }).toList(); // Filter users based on query
      });
    }
  }

  Future<void> _addDonation() async {
    // Retrieve the token from shared preferences
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('userToken') ?? '';

    final url = '${dotenv.env['BACKEND_URL']}/api/user/donation';
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': '$token',
      },
      body: json.encode({
        'user_id': selectedUserId,
        'amount': int.parse(amountController.text),
        'purpose': selectedPurpose,
      }),
    );

    if (response.statusCode == 200) {
      // Show a success message and reset the form
      _showDialog('Success', 'Donation added successfully');

      // Clear the form fields and reset the state
      setState(() {
        selectedUserId = null;
        selectedPurpose = 'Medical Support';
        amountController.clear();
        searchController.clear();
        filteredUsers = users; // Reset the list to show all users
      });
    } else {
      _showDialog('Failed', 'Failed to add donation');
      print('Failed to add donation');
    }
  }

  void _showDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Donation"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Text(
                    "Add New Donation",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  "Search User",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                TextField(
                  controller: searchController,
                  onChanged: _filterUsers,
                  decoration: InputDecoration(
                    labelText: "Enter Phone Number, Email, or Name",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "Select User",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                DropdownButton<int>(
                  value: selectedUserId,
                  isExpanded: true,
                  onChanged: (int? newValue) {
                    setState(() {
                      selectedUserId = newValue;
                    });
                  },
                  items: filteredUsers.map<DropdownMenuItem<int>>((user) {
                    return DropdownMenuItem<int>(
                      value: user['user_id'],
                      child: Text("${user['full_name']} (${user['phone_number']}) - ${user['email']}"),
                    );
                  }).toList(),
                  hint: Text("Select a User"),
                ),
                SizedBox(height: 20),
                Text(
                  "Donation Purpose",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                DropdownButton<String>(
                  value: selectedPurpose,
                  isExpanded: true,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedPurpose = newValue!;
                    });
                  },
                  items: ['Medical Support', 'Missionary Support', 'Monthly Subscription', 'Thank Offering', 'Poor Fund', 'Death Relief Fund', 'Building Fund', 'Harvest Dues', 'Others']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  hint: Text("Select Purpose"),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "Donation Amount",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    if (selectedUserId != null && amountController.text.isNotEmpty) {
                      _addDonation();
                    } else {
                      _showDialog('Validation Error', 'Please select a user and enter a donation amount');
                    }
                  },
                  child: Text(
                    "Submit Donation",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
