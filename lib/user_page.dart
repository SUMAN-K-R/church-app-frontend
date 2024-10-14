import 'package:flutter/material.dart';
class UserPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Church Events"),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'My Donation') {
                // Navigate to Donation Page
              } else if (value == 'Online Payment') {
                // Navigate to Payment Page
              } else if (value == 'About Church') {
                // Navigate to About Church Page
              }
            },
            itemBuilder: (BuildContext context) {
              return {'My Donation', 'Online Payment', 'About Church'}
                  .map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: 10, // Assume 10 church events
        itemBuilder: (context, index) {
          return ListTile(
            title: Text('Church Event ${index + 1}'),
          );
        },
      ),
    );
  }
}
