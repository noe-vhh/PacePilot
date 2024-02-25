// home_page.dart

import 'package:flutter/material.dart';

// Import necessary files
import '/login/login_page.dart';
import 'home_user_profile.dart';
import 'home_user_active.dart';
import '/../services/authentication.dart';
import '/../assets/theme.dart';
import '/../activity_dashboard/activity.dart';
import '/../activity_log/log.dart';

class DashboardPage extends StatefulWidget {
  final String accessToken;

  const DashboardPage({required this.accessToken, Key? key}) : super(key: key);

  @override
  DashboardPageState createState() => DashboardPageState();
}

class DashboardPageState extends State<DashboardPage> {
  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.themeData,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Dashboard',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          centerTitle: true,
          backgroundColor: const Color(0xFF99BD9C),
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: AppTheme.backgroundGradient,
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                UserProfile(accessToken: widget.accessToken),
                UserActive(accessToken: widget.accessToken),
              ],
            ),
          ),
        ),
        drawer: buildDrawer(),
      ),
    );
  }

  // Build the list of items for the Drawer
  List<Widget> buildDrawerItems() {
    return [
      // Running Dashboard item
      ListTile(
        title: const Text('Running Dashboard'),
        onTap: () {
          Navigator.pop(context);
          navigateToRunningActivityPage();
        },
      ),
      // Running Log item
      ListTile(
        title: const Text('Running Log'),
        onTap: () {
          Navigator.pop(context);
          navigateToRunningLogPage();
        },
      ),
      // Divider for visual separation
      const Divider(),
      // Logout item
      ListTile(
        title: const Text('Logout'),
        onTap: () {
          // Implement logout logic here
          logout();
        },
      ),
    ];
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