import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AllDonationsPage extends StatefulWidget {
  @override
  _AllDonationsPageState createState() => _AllDonationsPageState();
}

class _AllDonationsPageState extends State<AllDonationsPage> {
  List<dynamic> donationsList = []; // List to store all donations
  bool isLoading = true; // To show a loading indicator

  int currentPage = 1; // Current page number
  bool isLastPage = false; // To check if we've reached the last page
  bool isLoadingMore = false; // To check if the app is currently loading more data


  List<String> purposes = [
    'Medical Support',
    'Missionary Support',
    'Monthly Subscription',
    'Thank Offering',
    'Poor Fund',
    'Death Relief Fund',
    'Building Fund',
    'Harvest Dues',
    'Others'
  ];


  @override
  void initState() {
    super.initState();
    _fetchAllDonations();
  }


  Future<void> _fetchAllDonations() async {
    if (isLoadingMore) return; // Prevent duplicate requests

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('userToken') ?? '';
    final url = '${dotenv.env['BACKEND_URL']}/api/user/donation/all?page=$currentPage&limit=10';

    try {
      setState(() {
        isLoadingMore = true;
        if (currentPage == 1) donationsList.clear(); // Clear list only when loading first page
      });

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': '$token',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData.containsKey('donations')) {
          setState(() {
            donationsList.addAll(responseData['donations']);
            isLastPage = responseData['donations'].isEmpty;
            currentPage++;
          });
        } else {
          print('Donations key not found in the response.');
        }
      } else {
        print('Failed to load donations, Status Code: ${response.statusCode}, Response: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
    } finally {
      setState(() {
        isLoadingMore = false;
        isLoading = false;
      });
    }
  }

// Update donation method
  Future<void> _updateDonation(int donationId, String currentAmount, String currentPurpose) async {
    print('Update button clicked for donation ID: $donationId');

    // Text controller for amount
    TextEditingController amountController = TextEditingController(text: currentAmount);

    // List of purposes for the dropdown
    List<String> purposes = [
      'Medical Support',
      'Missionary Support',
      'Monthly Subscription',
      'Thank Offering',
      'Poor Fund',
      'Death Relief Fund',
      'Building Fund',
      'Harvest Dues',
      'Others'
    ];

    // Set the initial selected value to be part of the list, if not, use the first item in the list
    String selectedPurpose = purposes.contains(currentPurpose) ? currentPurpose : purposes.first;

    showDialog(
      context: context,
      barrierDismissible: false, // Prevent accidental dismissal
      builder: (BuildContext context) {
        return StatefulBuilder( // Use StatefulBuilder to manage the dialog's state
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Update Donation'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: amountController,
                    decoration: InputDecoration(labelText: 'Amount'),
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 16), // Add some space between the fields
                  DropdownButton<String>(
                    value: selectedPurpose,
                    isExpanded: true,
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        // Use setState from the StatefulBuilder to update the dialog UI
                        setState(() {
                          selectedPurpose = newValue;
                        });
                      }
                    },
                    items: purposes.map<DropdownMenuItem<String>>((String purpose) {
                      return DropdownMenuItem<String>(
                        value: purpose,
                        child: Text(purpose),
                      );
                    }).toList(),
                  )
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    double amount = double.tryParse(amountController.text) ?? 0.0;
                    String purpose = selectedPurpose;

                    if (amount == 0.0 || purpose.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Amount and Purpose cannot be empty!'),
                      ));
                      return;
                    }

                    final prefs = await SharedPreferences.getInstance();
                    final token = prefs.getString('userToken') ?? '';

                    final url = '${dotenv.env['BACKEND_URL']}/api/user/donation';
                    try {
                      final response = await http.put(
                        Uri.parse(url),
                        headers: {
                          'Content-Type': 'application/json',
                          'Authorization': '$token',
                        },
                        body: json.encode({
                          'id': donationId,
                          'amount': amount,
                          'purpose': purpose,
                        }),
                      );

                      if (response.statusCode == 200) {
                        // Close the dialog first
                        Navigator.of(context).pop();

                        // Refresh the donation list
                        donationsList.clear(); // Clear the existing list
                        await _fetchAllDonations(); // Wait for donations to be refreshed

                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Donation updated successfully!'),
                        ));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Failed to update donation.'),
                        ));
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Error occurred: $e'),
                      ));
                    }
                  },
                  child: Text('Update'),
                ),
              ],
            );
          },
        );
      },
    );
  }
  // Delete donation method
  Future<void> _deleteDonation(int donationId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('userToken') ?? '';
    final url = '${dotenv.env['BACKEND_URL']}/api/user/donation/$donationId';

    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': '$token',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          donationsList.removeWhere((donation) => donation['id'] == donationId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Donation deleted successfully.')),
        );
      } else {
        print('Failed to delete donation');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('All Donations'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : donationsList.isEmpty
          ? Center(child: Text('No donations found.'))
          : ListView(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: 20.0,
              headingRowColor: MaterialStateColor.resolveWith((states) => Colors.grey.shade200),
              columns: const [
                DataColumn(label: Text('ID', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('User ID', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Amount (₹)', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Purpose', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Donated At', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
              ],
              rows: donationsList.map((donation) {
                return DataRow(cells: [
                  DataCell(Text(donation['id'].toString())),
                  DataCell(Text(donation['user_id'].toString())),
                  DataCell(Text('₹${donation['amount']}')),
                  DataCell(Text(donation['purpose'])),
                  DataCell(Text(donation['donated_at'])),
                  DataCell(Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _updateDonation(
                            donation['id'],
                            donation['amount'].toString(),
                            donation['purpose']
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _confirmDeleteDialog(donation['id']),
                      ),
                    ],
                  )),
                ]);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // Confirmation dialog before deleting a donation
  void _confirmDeleteDialog(int donationId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Donation'),
          content: Text('Are you sure you want to delete this donation?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteDonation(donationId);
              },
            ),
          ],
        );
      },
    );
  }
}
