// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'dart:async';

import 'authentication.dart';
import 'user_profile.dart';

// Make MyHomePageState and homeKey public
final GlobalKey<MyHomePageState> homeKey = GlobalKey<MyHomePageState>();

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  String? accessToken;

  @override
  void initState() {
    super.initState();
    checkAccessToken();
  }

  Future<void> checkAccessToken() async {
    String? storedToken = await getStoredAccessToken();
    if (storedToken != null) {
      setAccessToken(storedToken);
    }
  }

  void setAccessToken(String? token) {
    setState(() {
      accessToken = token;
      print('Access Token set: $accessToken');
    });
  }

  void logout() async {
    await deleteStoredAccessToken();
    setAccessToken(null);
    print('User logged out');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Dashboard'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Container(
                  constraints: const BoxConstraints(maxHeight: double.infinity),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        if (accessToken == null)
                          Container(
                            padding: const EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.grey.withOpacity(0.2),
                            ),
                            child: ElevatedButton(
                              onPressed: () async {
                                await authenticateWithStrava((token) {
                                  setAccessToken(token);
                                  print('Authentication completed');
                                });
                              },
                              child: const Text('Authenticate with Strava'),
                            ),
                          ),
                        const SizedBox(height: 20),
                        if (accessToken != null)
                          UserProfile(accessToken: accessToken!),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text('User Profile'),
            ),
            ListTile(
              title: const Text('Logout'),
              onTap: () {
                logout();
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}