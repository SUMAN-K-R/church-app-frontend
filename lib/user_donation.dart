import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';


class MyDonationsPage extends StatefulWidget {
  final int userId; // User ID to fetch donations for
  MyDonationsPage({required this.userId}); // Constructor for userId

  @override
  _MyDonationsPageState createState() => _MyDonationsPageState();
}

class _MyDonationsPageState extends State<MyDonationsPage> {
  List<dynamic> donations = []; // List to hold donations

  @override
  void initState() {
    super.initState();
    _fetchMyDonations(); // Fetch donations when the page is loaded
  }

  // Fetch donations for the user
  Future<void> _fetchMyDonations() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('userToken') ?? '';
    final userID = prefs.getInt('userId') ?? '';

    final url = '${dotenv.env['BACKEND_URL']}/api/user/donation/${userID}'; // Adjust accordingly
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': '$token',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        donations = json.decode(response.body)['donations']; // Adjust based on actual response
      });
    } else {
      print('Failed to load donations');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Donations"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: donations.isEmpty
            ? Center(child: CircularProgressIndicator()) // Show loading indicator while fetching data
            : ListView.builder(
          itemCount: donations.length,
          itemBuilder: (context, index) {
            final donation = donations[index];
            return Card(
              elevation: 4,
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                title: Text("₹${donation['amount']}"), // Display amount
                subtitle: Text("Purpose: ${donation['purpose']}\nDate: ${donation['donated_at']}"), // Display purpose and date
              ),
            );
          },
        ),
      ),
    );
  }
}
