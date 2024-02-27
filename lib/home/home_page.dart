// home_page.dart

import 'package:flutter/material.dart';

import '/login/login_page.dart';
import 'home_user_profile.dart';
import 'home_user_active.dart';

import '/../services/authentication.dart';
import '../activity_dashboard/activity_dashboard.dart';

import '/../assets/theme.dart';
import '/../assets/icon_container.dart'; 
import '/../assets/custom_icon.dart';

class DashboardPage extends StatefulWidget {
  final String accessToken;

  const DashboardPage({required this.accessToken, Key? key}) : super(key: key);

  @override
  DashboardPageState createState() => DashboardPageState();
}

class DashboardPageState extends State<DashboardPage> {
  late ThemeData _themeData;
  late UserProfile userProfile;
  late UserActive userActive;
  bool _isRunningIconClicked = false;

  @override
  void initState() {
    super.initState();
    _themeData = AppTheme.themeData;
    userProfile = UserProfile(accessToken: widget.accessToken);
    userActive = UserActive(accessToken: widget.accessToken);
  }

  // Widget to build the running icon
  Widget buildRunningIcon() {
    return Positioned(
      top: 117,
      left: MediaQuery.of(context).size.width / 2 - 20,
      child: CustomIcon(
        imagePath: 'assets/images/Running_Icon.png',
        onTap: navigateToRunningActivityPage,
        isClicked: _isRunningIconClicked,
      ),
    );
  }

  // Widget to build the user profile
  Widget buildUserProfile() {
    return Positioned(
      top: 180,
      left: MediaQuery.of(context).size.width / 2 - 150,
      child: userProfile,
    );
  }

  // Widget to build the user active
  Widget buildUserActive() {
    return Positioned(
      top: 580,
      left: 20,
      child: Center(
        child: SizedBox(
          width: 370,
          height: 200,
          child: userActive,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: _themeData,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Dashboard',
            style: AppTheme.heading3,
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: AppTheme.backgroundGradient,
          ),
          child: SingleChildScrollView( 
            child: Stack(
              children: <Widget>[
                Container(
                  width: double.infinity,
                  height: 800,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    gradient: LinearGradient(
                      begin: Alignment(1, -2.9434392700977696e-8),
                      end: Alignment(-2.220446049250313e-16, 4.938271522521973),
                      colors: [
                        Color.fromRGBO(255, 255, 255, 1),
                        Color.fromRGBO(228, 228, 228, 1),
                      ],
                    ),
                  ),
                  child: Stack(
                    children: <Widget>[
                      Positioned(
                        top: 60,
                        left: 0,
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          height: 830,
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(40)),
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ),
                      const IconContainer(top: 110), 
                      buildRunningIcon(),
                      buildUserProfile(),
                      buildUserActive(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        drawer: buildDrawer(),
      ),
    );
  }

  // Widget to build the Drawer
  Widget buildDrawer() {
    return Drawer(
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                DrawerHeader(
                  decoration: const BoxDecoration(
                    color: AppTheme.primaryColor,
                  ),
                  child: Center(
                    child: Text(
                      'Dashboard',
                      style: AppTheme.themeData.textTheme.displayLarge,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: buildDrawerItems(),
          ),
        ],
      ),
    );
  }

  // List of Widgets for Drawer items
  List<Widget> buildDrawerItems() {
    return [
      const Divider(),
      ListTile(
        title: const Text(
          'Logout',
          style: AppTheme.labelText2,
        ),
        onTap: logout,
      ),
    ];
  }

  // Navigate to Running Activity Page
  void navigateToRunningActivityPage() {
    setState(() {
      _isRunningIconClicked = true;
    });

    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() {
        _isRunningIconClicked = false;
      });

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ActivityDashboard(accessToken: widget.accessToken)),
      );
    });
  }

  // Logout logic
  void logout() {
    deleteStoredAccessToken();
    navigateToLoginPage();
  }

  // Navigate to Login Page
  void navigateToLoginPage() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }
}