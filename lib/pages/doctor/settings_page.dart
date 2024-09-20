import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingsPage extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _logout(BuildContext context) async {
    await _auth.signOut(); // Firebase sign out
    Navigator.pushReplacementNamed(context, '/login'); // Redirect to login page
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Settings',
              style: TextStyle(fontSize: 24),
            ),  
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _logout(context), // Call the logout method
              child: Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
