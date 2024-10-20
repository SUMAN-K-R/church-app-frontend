import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UserPage extends StatefulWidget {
  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  String userName = "User Name"; // Fetch from API
  int totalDonations = 0; // Total donations fetched from API

  @override
  void initState() {
    super.initState();
    _fetchTotalDonations(); // Fetch total donations when the page is loaded
  }

  Future<void> _fetchTotalDonations() async {
    final url = 'http://10.0.2.2:6666/api/user/donations/total'; // Adjust accordingly
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      setState(() {
        totalDonations = json.decode(response.body)['total']; // Adjust based on actual response
      });
    } else {
      // Handle error
      print('Failed to load total donations');
    }
  }

  void _showProfileUpdate() {
    // Navigate to the profile update page
  }

  void _logout() {
    // Clear user session and navigate to login page
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Church Events"),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'Profile Update') {
                _showProfileUpdate();
              } else if (value == 'Log Out') {
                _logout();
              }
            },
            itemBuilder: (BuildContext context) {
              return {'Profile Update', 'Log Out'}.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 30,
              child: Text(userName.substring(0, 1)), // Display the first letter of the user name
            ),
            SizedBox(height: 10),
            Text("Total Donations: \$${totalDonations}", style: TextStyle(fontSize: 20)),
            // Other UI components like recent donations can be added here
          ],
        ),
      ),
    );
  }
}
