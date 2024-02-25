// home_user_active.dart
// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'home_user_active_service.dart';

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

  double buttonWidth = 30.0;
  double buttonHeight = 30.0;
  double buttonFontSize = 10.0;

  Color fontColor = Colors.white;
  Color selectedButtonColor = const Color.fromRGBO(120, 150, 123, 1);
  Color unselectedButtonColor = const Color.fromRGBO(153, 189, 156, 1);

  @override
  void initState() {
    super.initState();
    // Fetch user activity summary data
    fetchAndSetUserActivitySummary();
  }

  // Fetch and set user activity summary data
  Future<void> fetchAndSetUserActivitySummary() async {
    final result = await userActiveService.fetchUserActiveSummary(widget.accessToken, selectedPeriod);
    if (result['success']) {
      // Extract total active time from the result and update state
      final totalActiveSeconds = result['totalActiveTime']?.toDouble() ?? 0;
      final activeDuration = Duration(seconds: totalActiveSeconds.toInt());

      setState(() {
        activeTime = activeDuration;
      });
    } else {
      // If fetching fails, set activeTime to null and print an error message
      setState(() {
        activeTime = null;
      });
      print('Error: ${result['error']}');
    }
  }

  // Helper method to build the active time information
  Widget buildActiveTimeInfo() {
    if (activeTime != null) {
      // Format active time and build profile information
      final hours = activeTime!.inHours;
      final minutes = (activeTime!.inMinutes % 60);
      final formattedTime = hours > 0 ? '${hours}h ${minutes}m' : '${minutes}m';

      return buildProfileInfo('Active Time ($selectedPeriod)', formattedTime);
    } else {
      // Display a message if no activities are recorded for the selected period
      return buildProfileInfo('Active Time', 'No activities recorded for the selected period.');
    }
  }

  // Helper method to build a column with profile information
  Widget buildProfileInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text(value, style: const TextStyle(fontSize: 16)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        color: Colors.white,
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
                    onPressed: () {
                      setState(() {
                        selectedPeriod = 'Week';
                        fetchAndSetUserActivitySummary();
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: selectedPeriod == 'Week' ? selectedButtonColor : unselectedButtonColor,
                      minimumSize: Size(buttonWidth, buttonHeight),
                    ),
                    child: Text(
                      'Week',
                      style: TextStyle(
                        fontSize: buttonFontSize,
                        color: fontColor,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        selectedPeriod = 'Month';
                        fetchAndSetUserActivitySummary();
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: selectedPeriod == 'Month' ? selectedButtonColor : unselectedButtonColor,
                      minimumSize: Size(buttonWidth, buttonHeight),
                    ),
                    child: Text(
                      'Month',
                      style: TextStyle(
                        fontSize: buttonFontSize,
                        color: fontColor,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        selectedPeriod = 'Year';
                        fetchAndSetUserActivitySummary();
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: selectedPeriod == 'Year' ? selectedButtonColor : unselectedButtonColor,
                      minimumSize: Size(buttonWidth, buttonHeight),
                    ),
                    child: Text(
                      DateTime.now().year.toString(),
                      style: TextStyle(
                        fontSize: buttonFontSize,
                        color: fontColor,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        selectedPeriod = 'Previous Year';
                        fetchAndSetUserActivitySummary();
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: selectedPeriod == 'Previous Year' ? selectedButtonColor : unselectedButtonColor,
                      minimumSize: Size(buttonWidth, buttonHeight),
                    ),
                    child: Text(
                      (DateTime.now().year - 1).toString(),
                      style: TextStyle(
                        fontSize: buttonFontSize,
                        color: fontColor,
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
    );
  }
}