import 'package:flutter/material.dart';
import 'login_page.dart';
void main() {
  runApp(ChurchApp());

}

class ChurchApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Church App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: ChurchSymbolScreen(), // Starting screen
    );
  }
}


class ChurchSymbolScreen extends StatefulWidget {
  @override
  _ChurchSymbolScreenState createState() => _ChurchSymbolScreenState();
}

class _ChurchSymbolScreenState extends State<ChurchSymbolScreen> {

  @override
  void initState() {
    super.initState();
    // Wait for 3 seconds and navigate to LoginPage
    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.church, size: 100), // Church symbol as an icon
            SizedBox(height: 20),
            Text("Welcome to Our Church ", style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,)
             ),
          ],
        ),
      ),
    );
  }
}



