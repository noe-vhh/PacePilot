// main.dart
// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'dart:async';

import 'authentication.dart';
import 'user_profile.dart';
import 'running_activity.dart';
import 'running_log.dart';

// Global key for accessing MyHomePageState
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
    // Check if there is a stored access token
    String? storedToken = await getStoredAccessToken();
    if (storedToken != null) {
      setState(() {
        accessToken = storedToken;
      });
    }
  }

  void setAccessToken(String? token) {
    // Set the access token and update the UI
    setState(() {
      accessToken = token;
    });
  }

  void logout() async {
    // Logout functionality: delete stored token, clear access token, and log the user out
    await deleteStoredAccessToken();
    setAccessToken(null);
    print('User logged out');
  }

  void navigateToRunningActivityPage() {
    // Navigate to the Running Activity page
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RunningActivityPage(accessToken: accessToken!)),
    );
  }

  void navigateToRunningLogPage() {
    // Navigate to the Running Log page
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RunningLog(accessToken: accessToken!)),
    );
  }

  List<Widget> buildDrawerItems() {
    // Build the list of drawer items dynamically based on the user's authentication status
    List<Widget> items = [];

    if (accessToken != null) {
      items.add(ListTile(
        title: const Text('Running Dashboard'),
        onTap: () {
          Navigator.pop(context);
          navigateToRunningActivityPage();
        },
      ));
      
      
      items.add(ListTile(
        title: const Text('Running Log'),
        onTap: () {
          Navigator.pop(context);
          navigateToRunningLogPage();
        },
      ));

      items.add(const Divider());

      items.add(ListTile(
        title: const Text('Logout'),
        onTap: () {
          logout();
          Navigator.pop(context);
        },
      ));
    }

    return items;
  }

  Widget buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Center(
              child: Text(
                'User Profile',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          ...buildDrawerItems(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Main Scaffold widget with AppBar, body content, and the dynamic drawer
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
      drawer: buildDrawer(),
    );
  }
}