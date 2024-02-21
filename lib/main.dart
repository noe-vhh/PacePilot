// main.dart
import 'package:flutter/material.dart';

import '/home/home_page.dart';
import '/login/login_page.dart';
import '/services/authentication.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: getStoredAccessToken(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          // If a token is found, navigate to DashboardPage
          if (snapshot.hasData && snapshot.data != null) {
            return MaterialApp(
              home: DashboardPage(accessToken: snapshot.data!),
            );
          } else {
            // If no token is found, show the LoginPage
            return const MaterialApp(
              home: LoginPage(),
            );
          }
        } else {
          // Show loading indicator or a splash screen while checking for the token
          return const MaterialApp(
            home: Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }
      },
    );
  }
}