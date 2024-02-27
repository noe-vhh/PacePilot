// main.dart
import 'package:flutter/material.dart';

import '/home/home_page.dart';
import '/login/login_page.dart';
import '/services/authentication.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  late final Future<String?> storedAccessToken = getStoredAccessToken();

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: storedAccessToken,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData && snapshot.data != null) {
            return MaterialApp(
              home: DashboardPage(accessToken: snapshot.data!),
            );
          } else {
            return const MaterialApp(
              home: LoginPage(),
            );
          }
        } else {
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