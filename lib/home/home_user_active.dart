// home_user_active.dart
// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'home_user_active_service.dart';
import '/../assets/theme.dart'; // Import your theme file

class UserActive extends StatefulWidget {
  final String accessToken;

  const UserActive({required this.accessToken, Key? key}) : super(key: key);

  @override
  UserActiveState createState() => UserActiveState();
}

class UserActiveState extends State<UserActive> {
  final UserActiveService userActiveService = UserActiveService();
  Duration? activeTime;
  String selectedPeriod = 'Week';
  bool isLoading = false; // Track loading state

  double buttonWidth = 30.0;
  double buttonHeight = 30.0;
  double buttonFontSize = 10.0;

  @override
  void initState() {
    super.initState();
    // Fetch user activity summary data
    fetchAndSetUserActivitySummary();
  }

  // Fetch and set user activity summary data
  Future<void> fetchAndSetUserActivitySummary() async {
    setState(() {
      isLoading = true; // Set loading state to true
    });

    final result =
        await userActiveService.fetchUserActiveSummary(widget.accessToken, selectedPeriod);

    if (result['success']) {
      // Extract total active time from the result and update state
      final totalActiveSeconds = result['totalActiveTime']?.toDouble() ?? 0;
      final activeDuration = Duration(seconds: totalActiveSeconds.toInt());

      setState(() {
        activeTime = activeDuration;
        isLoading = false; // Set loading state to false when data is fetched
      });
    } else {
      // If fetching fails, set activeTime to null and print an error message
      setState(() {
        activeTime = null;
        isLoading = false; // Set loading state to false even if fetching fails
      });
      print('Error: ${result['error']}');
    }
  }

  // Helper method to build the active time information
  Widget buildActiveTimeInfo() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (activeTime != null) {
      // Format active time and build profile information
      final hours = activeTime!.inHours;
      final minutes = (activeTime!.inMinutes % 60);
      final formattedTime = hours > 0 ? '${hours}h ${minutes}m' : '${minutes}m';

      return Container(
        alignment: Alignment.center,
        child: buildProfileInfo('Active Time ($selectedPeriod)', formattedTime),
      );
    } else {
      // Display a message if no activities are recorded for the selected period
      return Container(
        alignment: Alignment.center,
        child: buildProfileInfo('Active Time', 'No activities recorded for the selected period.'),
      );
    }
  }

  // Helper method to build a column with profile information
  Widget buildProfileInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTheme.labelText3),
        Text(value, style: AppTheme.bodyText),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        color: AppTheme.tertiaryColor,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => switchPeriod('Week'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: selectedPeriod == 'Week'
                          ? AppTheme.selectedButtonColor
                          : AppTheme.unselectedButtonColor,
                      minimumSize: Size(buttonWidth, buttonHeight),
                    ),
                    child: Text(
                      'Week',
                      style: TextStyle(
                        fontSize: buttonFontSize,
                        color: AppTheme.fontColor,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => switchPeriod('Month'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: selectedPeriod == 'Month'
                          ? AppTheme.selectedButtonColor
                          : AppTheme.unselectedButtonColor,
                      minimumSize: Size(buttonWidth, buttonHeight),
                    ),
                    child: Text(
                      'Month',
                      style: TextStyle(
                        fontSize: buttonFontSize,
                        color: AppTheme.fontColor,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => switchPeriod('Year'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: selectedPeriod == 'Year'
                          ? AppTheme.selectedButtonColor
                          : AppTheme.unselectedButtonColor,
                      minimumSize: Size(buttonWidth, buttonHeight),
                    ),
                    child: Text(
                      DateTime.now().year.toString(),
                      style: TextStyle(
                        fontSize: buttonFontSize,
                        color: AppTheme.fontColor,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => switchPeriod('Previous Year'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: selectedPeriod == 'Previous Year'
                          ? AppTheme.selectedButtonColor
                          : AppTheme.unselectedButtonColor,
                      minimumSize: Size(buttonWidth, buttonHeight),
                    ),
                    child: Text(
                      (DateTime.now().year - 1).toString(),
                      style: TextStyle(
                        fontSize: buttonFontSize,
                        color: AppTheme.fontColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Display active time information
              buildActiveTimeInfo(),
            ],
          ),
        ),
      ),
    ),
    );
  }

  void switchPeriod(String newPeriod) async {
    setState(() {
      isLoading = true; 
      selectedPeriod = newPeriod; 
    });

    await fetchAndSetUserActivitySummary(); 

    setState(() {
      isLoading = false; 
    });
  }
}