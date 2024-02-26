// activity_dashboard.dart

import 'package:flutter/material.dart';

import 'summary.dart';

import '/../assets/theme.dart';

class ActivityDashboard extends StatefulWidget {
  final String accessToken;

  // Constructor with required parameters
  const ActivityDashboard({Key? key, required this.accessToken}) : super(key: key);

  @override
  ActivityDashboardState createState() => ActivityDashboardState();
}

class ActivityDashboardState extends State<ActivityDashboard> {
  @override
  Widget build(BuildContext context) {
    // Use Theme widget to apply a custom theme to the entire widget tree
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
                top: 90,
                // Center the ActivitySummaryCard horizontally
                left: (MediaQuery.of(context).size.width - 350) / 2,
                child: ActivitySummaryCard(accessToken: widget.accessToken),
              ),
            ],
          ),
        ),
      ),
    );
  }
}