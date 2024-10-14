import 'package:flutter/material.dart';

class AdminPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Admin - Church Events"),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'Add Donation') {
                // Navigate to Add Donation Page
              } else if (value == 'Overall Database') {
                // Navigate to Overall Database Page
              } else if (value == 'About Church') {
                // Navigate to About Church Page
              }
            },
            itemBuilder: (BuildContext context) {
              return {'Add Donation', 'Overall Database', 'About Church'}
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
