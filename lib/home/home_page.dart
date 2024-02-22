// home_page.dart

import 'package:flutter/material.dart';

import '/login/login_page.dart';
import 'home_user_profile.dart';
import '/activity_dashboard/activity.dart';
import '/activity_log/log.dart';
import '/../services/authentication.dart';  // Import the authentication file

class DashboardPage extends StatefulWidget {
  final String accessToken;

  const DashboardPage({required this.accessToken, Key? key}) : super(key: key);

  @override
  DashboardPageState createState() => DashboardPageState();
}

class DashboardPageState extends State<DashboardPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
                        UserProfile(accessToken: widget.accessToken),
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

  // Build the list of items for the Drawer
  List<Widget> buildDrawerItems() {
    List<Widget> items = [];

    // Running Dashboard item
    items.add(ListTile(
      title: const Text('Running Dashboard'),
      onTap: () {
        Navigator.pop(context);
        navigateToRunningActivityPage();
      },
    ));

    // Running Log item
    items.add(ListTile(
      title: const Text('Running Log'),
      onTap: () {
        Navigator.pop(context);
        navigateToRunningLogPage();
      },
    ));

    // Divider for visual separation
    items.add(const Divider());

    // Logout item
    items.add(ListTile(
      title: const Text('Logout'),
      onTap: () {
        // Implement logout logic here
        logout();
      },
    ));

    return items;
  }

  // Build the Drawer widget
  Widget buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          // Drawer header with user profile info
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Color(0xFF99BD9C),
            ),
            child: Center(
              child: Text(
                'Dashboard',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          // Items in the Drawer
          ...buildDrawerItems(),
        ],
      ),
    );
  }

  // Navigate to Running Activity Page
  void navigateToRunningActivityPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ActivityPage(accessToken: widget.accessToken)),
    );
  }

  // Navigate to Running Log Page
  void navigateToRunningLogPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Log(accessToken: widget.accessToken)),
    );
  }

  // Logout logic
  void logout() {
    // Delete stored access token and refresh token
    deleteStoredAccessToken();

    // Navigate to the login page (with replacement to clear navigation stack)
    navigateToLoginPage();
  }

  // Navigate to Login Page (with replacement to clear navigation stack)
  void navigateToLoginPage() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }
}