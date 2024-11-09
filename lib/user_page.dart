import 'package:church_app/add_donation.dart';
import 'package:church_app/login_page.dart';
import 'package:church_app/user_donation.dart';
import 'package:church_app/user_profile_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';


class UserPage extends StatefulWidget {
  final String userType; // Add a field for user_type
  UserPage({required this.userType}); // Constructor for user_type

  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  int totalDonations = 0; // Total donations fetched from API
  List<String> newsList = []; // News items

  @override
  void initState() {
    super.initState();
    _fetchTotalDonations(); // Fetch total donations when the page is loaded
    _fetchNews(); // Fetch news when the page is loaded
  }

  // Fetch total donations
  Future<void> _fetchTotalDonations() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('userToken') ?? '';

    final url = '${dotenv.env['BACKEND_URL']}/api/user/donation/total'; // Adjust accordingly
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': '$token',
      },
    );



    if (response.statusCode == 200) {
      setState(() {
        totalDonations = json.decode(response.body)['donations']; // Adjust based on actual response
      });
    } else {
      print('Failed to load total donations');
    }
  }

  // Fetch news from API
  Future<void> _fetchNews() async {
    final url = '${dotenv.env['BACKEND_URL']}/api/news'; // Replace with your actual API endpoint
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      setState(() {
        newsList = List<String>.from(json.decode(response.body)['news']); // Assuming API returns a list of news titles
      });
    } else {
      print('Failed to load news');
    }
  }

  // Show Profile Update
  void _showProfileUpdate() {
    // Navigate to the profile update page
  }

  // Logout
  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userToken'); // Clear the token
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()), // Directly navigate to LoginPage
    ); // Navigate back to login
  }

  // Add Donation
  void _navigateToAddDonation() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddDonationPage()),
    ).then((value) {
      if (value == true) {
        _fetchTotalDonations(); // Refresh total donations after adding a new one
      }
    });
  }


  // Add this method in the UserPage class
  void _navigateToMyDonations() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId') ?? 0; // Retrieve userId from shared preferences, default to 0 if not found

    if (userId != 0) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MyDonationsPage(userId: userId),
        ),
      );
    } else {
      // Handle the case when userId is not found, maybe show an error or prompt for login
      print("User ID not found. Please log in again.");
    }
  }


  void _navigateToMyProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId') ?? 0;


    if (userId != 0){
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => UserProfilePage(userId: userId),
        ),
      );
    } else {
      print("User ID not found. Please log in again");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // title: Text("Hello World", textAlign: TextAlign.center), // Center title
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'Profile Update') {
                _showProfileUpdate();
              } else if (value == 'Log Out') {
                _logout();
              } else if (value == 'Add Donation') {
                _navigateToAddDonation();
              } else if (value == 'My Donations'){
                _navigateToMyDonations();
              } else if (value == 'Add News'){

              }
            },
            itemBuilder: (BuildContext context) {
              if (widget.userType == 'admin') {
                return {'Add Donation', 'All Donations', 'Add News', 'Log Out'}.map((String choice) {
                  return PopupMenuItem<String>(
                    value: choice,
                    child: Text(choice),
                  );
                }).toList();
              } else {
                return {'About', 'My Donations', 'Log Out'}.map((String choice) {
                  return PopupMenuItem<String>(
                    value: choice,
                    child: Text(choice),
                  );
                }).toList();
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Center the column content vertically
          crossAxisAlignment: CrossAxisAlignment.center, // Center the content horizontally
          children: [
            Text(
              "Total Donations",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            Text(
              "₹$totalDonations", // Using direct rupee symbol
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 30), // Space between donations and news
            Text(
              "News",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            Expanded(
              child: ListView.builder(
                itemCount: newsList.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(newsList[index]), // Display each news item
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
