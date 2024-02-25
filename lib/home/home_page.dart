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
  late UserProfile userProfile;
  late UserActive userActive;

  @override
  void initState() {
    super.initState();
    // Initialize UserProfile and UserActive widgets with the provided accessToken
    userProfile = UserProfile(accessToken: widget.accessToken);
    userActive = UserActive(accessToken: widget.accessToken);
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.themeData,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Dashboard',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: AppTheme.backgroundGradient,
          ),
          child: Stack(
            children: <Widget>[
              Container(
                width: double.infinity,
                height: 800,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment(1, -2.9434392700977696e-8),
                    end: Alignment(-2.220446049250313e-16, 4.938271522521973),
                    colors: [Color.fromRGBO(255, 255, 255, 1), Color.fromRGBO(228, 228, 228, 1)],
                  ),
                ),
                child: Stack(
                  children: <Widget>[
                    Positioned(
                      top: 60,
                      left: 4.547473508864641e-13,
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: 830,
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(40),
                            topRight: Radius.circular(40),
                            bottomLeft: Radius.circular(40),
                            bottomRight: Radius.circular(40),
                          ),
                          color: Color.fromRGBO(153, 189, 156, 1),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 110,
                      left: MediaQuery.of(context).size.width / 2 - 160,  
                      child: Container(
                        width: 320,
                        height: 53,
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                            bottomLeft: Radius.circular(20),
                            bottomRight: Radius.circular(20),
                          ),
                          boxShadow: [BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.25),
                            offset: Offset(0, 4),
                            blurRadius: 4),],
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 117,
                      left: MediaQuery.of(context).size.width / 2 - 20,  
                      child: SizedBox(
                        width: 40,
                        height: 40,
                        child: Stack(
                          children: <Widget>[
                            Positioned(
                              top: 0,
                              left: 0,
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(8),
                                    topRight: Radius.circular(8),
                                    bottomLeft: Radius.circular(8),
                                    bottomRight: Radius.circular(8),
                                  ),
                                  color: Colors.white,
                                border : Border.all(
                                  color: const Color.fromRGBO(0, 0, 0, 1),
                                  width: 1,
                                )),
                              ),
                            ),
                            Positioned(
                              top: 6,
                              left: 7,
                              child: Container(
                                width: 27,
                                height: 28,
                                decoration: const BoxDecoration(
                                  image: DecorationImage(
                                    image: AssetImage('assets/images/Running_Icon.png'),
                                    fit: BoxFit.fitWidth,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 180, 
                      left: MediaQuery.of(context).size.width / 2 - 150, 
                      child: userProfile,
                    ),
                    Positioned(
                      top: 580, 
                      left: 20, 
                      child: userActive,
                    ),
                  ],
                ),
              ),
            ],
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