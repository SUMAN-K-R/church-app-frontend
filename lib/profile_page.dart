import 'package:flutter/material.dart';
// Import login page for returning after success
import 'submit_page.dart';
import 'success_page.dart'; // Adjust the import based on the actual file location

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController weddingAnniversaryController = TextEditingController();
  String? selectedMaritalStatus;
  String? selectedGender;
  bool isSingle = true;
  bool isCheckboxChecked = false;

  @override
  void dispose() {
    fullNameController.dispose();
    dobController.dispose();
    weddingAnniversaryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile Page"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Full Name field
            TextField(
              controller: fullNameController,
              decoration: InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),

            // Date of Birth field with Calendar picker
            TextField(
              controller: dobController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Date of Birth',
                border: OutlineInputBorder(),
              ),
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime(2100),
                  );

                  // Check if a date was picked and set the text accordingly
                  if (pickedDate != null) {
                    setState(() {
                      dobController.text = "${pickedDate.day}-${pickedDate.month}-${pickedDate.year}";
                    });
                  }
                },

            ),
            SizedBox(height: 20),

            // Gender Dropdown
            DropdownButtonFormField<String>(
              value: selectedGender,
              items: [
                DropdownMenuItem(value: null, child: Text("")),
                DropdownMenuItem(value: "Male", child: Text("Male")),
                DropdownMenuItem(value: "Female", child: Text("Female")),
                DropdownMenuItem(value: "Other", child: Text("Other")),
              ],
              onChanged: (value) {
                setState(() {
                  selectedGender = value;
                });
              },
              decoration: InputDecoration(
                labelText: 'Gender',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),

            // Marital Status Dropdown
            DropdownButtonFormField<String>(
              value: selectedMaritalStatus,
              items: [
                DropdownMenuItem(value: null, child: Text("")),
                DropdownMenuItem(value: "Single", child: Text("Single")),
                DropdownMenuItem(value: "Married", child: Text("Married")),
                DropdownMenuItem(value: "Divorced", child: Text("Divorced")),
                DropdownMenuItem(value: "Widowed", child: Text("Widowed")),
              ],
              onChanged: (value) {
                setState(() {
                  selectedMaritalStatus = value;
                  isSingle = (value == "Single");
                });
              },
              decoration: InputDecoration(
                labelText: 'Marital Status',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),

            // Wedding Anniversary field (only enabled if married)
            TextField(
              controller: weddingAnniversaryController,
              readOnly: true,
              enabled: !isSingle,
              decoration: InputDecoration(
                labelText: 'Wedding Anniversary',
                border: OutlineInputBorder(),
              ),
              onTap: !isSingle
                  ? () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(1900),
                  lastDate: DateTime(2100),
                );

                // Check if a date was picked and set the text accordingly
                if (pickedDate != null) {
                  setState(() {
                    weddingAnniversaryController.text = "${pickedDate.day}-${pickedDate.month}-${pickedDate.year}";
                  });
                }
              }
                  : null,

            ),
            SizedBox(height: 20),

            // Profession field (optional)
            TextField(
              decoration: InputDecoration(
                labelText: 'Profession (Optional)',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),

            // Checkbox for confirmation
            CheckboxListTile(
              value: isCheckboxChecked,
              title: Text("I confirm that the above information is correct"),
              onChanged: (value) {
                setState(() {
                  isCheckboxChecked = value!;
                });
              },
            ),
            SizedBox(height: 20),

            // Submit button (enabled only if checkbox is checked and mandatory fields are filled)
            ElevatedButton(
              onPressed: isCheckboxChecked &&
                  fullNameController.text.isNotEmpty &&
                  dobController.text.isNotEmpty &&
                  selectedGender != null &&
                  selectedMaritalStatus != null &&
                  (isSingle || weddingAnniversaryController.text.isNotEmpty)
                  ? () {
                // Clear all fields and navigate to success page
                fullNameController.clear();
                dobController.clear();
                weddingAnniversaryController.clear();
                setState(() {
                  selectedGender = null;
                  selectedMaritalStatus = null;
                  isSingle = true;
                  isCheckboxChecked = false;
                });
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SuccessPage()),
                );
              }
                  : null,
              child: Text("Submit"),
            ),
          ],
        ),
      ),
    );
  }
}

class SuccessPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Success'),
      ),
      body: Center(
        child: Text(
          'Profile submitted successfully!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}

