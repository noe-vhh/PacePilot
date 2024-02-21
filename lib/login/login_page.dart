// login_page.dart
// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import '/services/authentication.dart';
import '/home/home_page.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login Page'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            // Attempt to authenticate with Strava
            String? token = await authenticateWithStrava();

            if (token != null) {
              // If authentication successful, navigate to Dashboard
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => DashboardPage(accessToken: token)),
              );
            }
          },
          child: const Text('Login'),
        ),
      ),
    );
  }
}