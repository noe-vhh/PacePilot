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
  final UserProfileService userProfileService = UserProfileService();
  String? username;
  String? name;
  String? surname;
  String? location;
  String? profileImageUrl;

  @override
  void initState() {
    super.initState();
    // Fetch user profile data and set initial state
    fetchUserProfile();
  }

  // Fetch user profile data from Strava API
  Future<void> fetchUserProfile() async {
    final profileData = await UserProfileService.fetchUserProfile(widget.accessToken);

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
    );
  }
}