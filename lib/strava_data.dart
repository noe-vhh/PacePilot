// strava_data.dart

import 'package:http/http.dart' as http;
import 'dart:convert' show jsonDecode;

Future<Map<String, dynamic>> fetchUserActivitySummary(String accessToken, String selectedPeriod) async {
  try {
    DateTime currentDate = DateTime.now();
    DateTime startDate;
    DateTime endDate = currentDate;

    switch (selectedPeriod) {
      case 'Week':
        startDate = currentDate.subtract(const Duration(days: 7));
        break;
      case 'Month':
        startDate = DateTime(currentDate.year, currentDate.month - 1, currentDate.day);
        break;
      case 'Year':
        startDate = DateTime(currentDate.year, 1, 1); // Start of the current year
        break;
      case 'Previous Year':
        startDate = DateTime(currentDate.year - 1, 1, 1); // Start of the previous year
        endDate = DateTime(currentDate.year - 1, 12, 31); // End of the previous year
        break;
      default:
        throw ArgumentError('Invalid period: $selectedPeriod');
    }

    // Fetch user's profile information
    final profileUrl = Uri.https('www.strava.com', '/api/v3/athlete');
    final profileResponse = await http.get(
      profileUrl,
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (profileResponse.statusCode == 200) {
      final Map<String, dynamic> profileData = jsonDecode(profileResponse.body);

      // Construct the API endpoint URL for fetching the user's activity summary
      final apiUrl = Uri.https(
        'www.strava.com',
        '/api/v3/athlete/activities',
        {
          'after': (startDate.millisecondsSinceEpoch / 1000).round().toString(),
          'before': (endDate.millisecondsSinceEpoch / 1000).round().toString(),
        },
      );

      // Make the API request with the access token
      final activityResponse = await http.get(
        apiUrl,
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      if (activityResponse.statusCode == 200) {
        final List<dynamic> activities = jsonDecode(activityResponse.body);

        if (activities.isNotEmpty) {
          Duration totalActiveTime = Duration.zero;

          for (var activity in activities) {
            totalActiveTime += Duration(seconds: (activity['moving_time'] ?? 0).toInt());
          }

          return {
            'success': true,
            'profileData': profileData,
            'totalActiveTime': totalActiveTime.inSeconds.toDouble(),
            'selectedPeriod': selectedPeriod,
          };
        } else {
          return {
            'success': false,
            'error': 'No activities found for the selected period',
            'selectedPeriod': selectedPeriod,
          };
        }
      } else {
        return {
          'success': false,
          'error': 'Failed to fetch user activities. Status code: ${activityResponse.statusCode}',
          'selectedPeriod': selectedPeriod,
        };
      }
    } else {
      return {
        'success': false,
        'error': 'Failed to fetch user profile. Status code: ${profileResponse.statusCode}',
        'selectedPeriod': selectedPeriod,
      };
    }
  } catch (e) {
    return {
      'success': false,
      'error': 'Error fetching user data: $e',
      'selectedPeriod': selectedPeriod,
    };
  }
}