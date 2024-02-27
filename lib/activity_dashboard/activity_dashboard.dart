// activity_dashboard.dart

import 'package:flutter/material.dart';

import 'summary.dart';
import '/../activity_log/log.dart';

import '/../assets/theme.dart';
import '/../assets/icon_container.dart';
import '/../assets/custom_icon.dart';

class ActivityDashboard extends StatefulWidget {
  final String accessToken;

  // Constructor with required parameters
  const ActivityDashboard({Key? key, required this.accessToken}) : super(key: key);

  @override
  ActivityDashboardState createState() => ActivityDashboardState();
}

class ActivityDashboardState extends State<ActivityDashboard> {
  bool _isLogIconClicked = false;

  // Navigate to Log Page
  void navigateToLog() {
    setState(() {
      _isLogIconClicked = true;
    });

    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() {
        _isLogIconClicked = false;
      });

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Log(accessToken: widget.accessToken)),
      );
    });
  }

  // Widget to build the Log icon
  Widget buildLogIcon() {
    return Positioned(
      top: 96,
      left: MediaQuery.of(context).size.width / 2 - 20,
      child: CustomIcon(
        imagePath: 'assets/images/Log_Icon.png',
        onTap: navigateToLog,
        isClicked: _isLogIconClicked,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.themeData,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Running Dashboard',
            style: AppTheme.heading3,
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
              // Background Container
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
              // Activity Card
              Positioned(
                top: 160,
                // Center the ActivitySummaryCard horizontally
                left: (MediaQuery.of(context).size.width - 332) / 2,
                child: ActivitySummaryCard(accessToken: widget.accessToken),
              ),
              // Add IconContainer and CustomIcon
              const IconContainer(top: 90),
              buildLogIcon(),
            ],
          ),
        ),
      ),
    );
  }
}