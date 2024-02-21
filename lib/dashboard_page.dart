// dashboard_page.dart

import 'package:flutter/material.dart';

import 'login_page.dart';
import 'user_profile.dart';
import 'running_activity.dart';
import 'running_log.dart';

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

  List<Widget> buildDrawerItems() {
    List<Widget> items = [];

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
        // Implement logout logic here if needed
        Navigator.pop(context);
        navigateToLoginPage();
      },
    ));

    return items;
  }

  Widget buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Color(0xFF99BD9C),
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

  void navigateToRunningActivityPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RunningActivityPage(accessToken: widget.accessToken)),
    );
  }

  void navigateToRunningLogPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RunningLog(accessToken: widget.accessToken)),
    );
  }

  void navigateToLoginPage() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }
}