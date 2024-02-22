// home_user_profile.dart
// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'home_user_profile_service.dart';

class UserProfile extends StatefulWidget {
  final String accessToken;

  const UserProfile({required this.accessToken, Key? key}) : super(key: key);

  @override
  UserProfileState createState() => UserProfileState();
}

class UserProfileState extends State<UserProfile> {
  final StravaData _stravaData = StravaData();
  String? username;
  String? name;
  String? surname;
  String? location;
  String? profileImageUrl;
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
    // Fetch user profile data and set initial state
    fetchUserProfile();
    fetchAndSetUserActivitySummary();
  }

  // Fetch user profile data from Strava API
  Future<void> fetchUserProfile() async {
    final profileData = await StravaData.fetchUserProfile(widget.accessToken);

    if (profileData['success']) {
      setState(() {
        // Update state with user profile data
        username = profileData['username'];
        name = profileData['firstname'];
        surname = profileData['lastname'];
        location = profileData['city'];
        profileImageUrl = profileData['profile'];
      });
    } else {
      // Print an error message if fetching fails
      print('Error fetching user profile: ${profileData['error']}');
    }
  }

  // Fetch and set user activity summary data
  Future<void> fetchAndSetUserActivitySummary() async {
    final result = await _stravaData.fetchUserActivitySummary(widget.accessToken, selectedPeriod);
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // User profile card
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(50.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Display user profile image if available
                  if (profileImageUrl != null)
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.transparent,
                      child: ClipOval(
                        child: Image.network(
                          profileImageUrl!,
                          fit: BoxFit.cover,
                          loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                            if (loadingProgress == null) {
                              return child;
                            } else {
                              // Show loading indicator while image is loading
                              return Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                                      : null,
                                ),
                              );
                            }
                          },
                          errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                            // Display an error icon if image loading fails
                            return const Icon(Icons.error);
                          },
                        ),
                      ),
                    ),
                  const SizedBox(height: 20),
                  // Display user profile information
                  if (username != null) buildProfileInfo('Username', username!),
                  if (name != null && surname != null) buildProfileInfo('Name', '$name $surname'),
                  if (location != null) buildProfileInfo('Location', location!),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // User activity summary card
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Buttons to select the period (Week, Month, Year, Previous Year)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Button for Week
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
                      // Button for Month
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
                      // Button for Year
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
                      // Button for Previous Year
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
        ],
      ),
    );
  }
}