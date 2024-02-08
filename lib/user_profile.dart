//user_profile.dart
// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' show jsonDecode;

import 'strava_data.dart';

class UserProfile extends StatefulWidget {
  final String accessToken;

  const UserProfile({required this.accessToken, Key? key}) : super(key: key);

  @override
  UserProfileState createState() => UserProfileState();
}

class UserProfileState extends State<UserProfile> {
  String? username;
  String? name;
  String? surname;
  String? location;
  String? profileImageUrl;
  Duration? activeTime;
  String selectedPeriod = 'Week';

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
    fetchAndSetUserActivitySummary();
  }

  Future<void> fetchUserProfile() async {
    try {
      final response = await http.get(
        Uri.https('www.strava.com', '/api/v3/athlete'),
        headers: {'Authorization': 'Bearer ${widget.accessToken}'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> userData = jsonDecode(response.body);

        setState(() {
          // Set the user profile information
          username = userData['username'];
          name = userData['firstname'];
          surname = userData['lastname'];
          location = userData['city'];
          profileImageUrl = userData['profile'];
        });
      } else {
        print('Error fetching user profile. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching user profile: $e');
    }
  }

  Future<void> fetchAndSetUserActivitySummary() async {
    final result = await fetchUserActivitySummary(widget.accessToken, selectedPeriod);
    if (result['success']) {
      final totalActiveSeconds = result['totalActiveTime']?.toDouble() ?? 0;
      final activeDuration = Duration(seconds: totalActiveSeconds.toInt());

      setState(() {
        activeTime = activeDuration;
      });
    } else {
      setState(() {
        activeTime = null;
      });
      print('Error: ${result['error']}');
    }
  }

  Widget buildProfileInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text(value, style: const TextStyle(fontSize: 16)),
      ],
    );
  }

  Widget buildActiveTimeInfo() {
    if (activeTime != null) {
      final hours = activeTime!.inHours;
      final minutes = (activeTime!.inMinutes % 60);
      final formattedTime = hours > 0 ? '${hours}h ${minutes}m' : '${minutes}m';

      return buildProfileInfo('Active Time ($selectedPeriod)', formattedTime);
    } else {
      return buildProfileInfo('Active Time', 'No activities recorded for the selected period.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Container(
          constraints: const BoxConstraints(maxHeight: double.infinity),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              shrinkWrap: true,
              children: [
                // Display profile image
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
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        (loadingProgress.expectedTotalBytes ?? 1)
                                    : null,
                              ),
                            );
                          }
                        },
                        errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
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

                const SizedBox(height: 20),

                // Dropdown menu for selecting period
                DropdownButton<String>(
                  value: selectedPeriod,
                  onChanged: (String? value) {
                    setState(() {
                      selectedPeriod = value!;
                      fetchAndSetUserActivitySummary();
                    });
                  },
                  items: <String>['Week', 'Month', 'Year', 'Previous Year']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 20),

                // Display active time for the selected period
                buildActiveTimeInfo(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}