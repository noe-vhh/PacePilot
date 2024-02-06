// data_calling.dart
// ignore_for_file: avoid_print

import 'package:http/http.dart' as http;
import 'dart:convert' show jsonDecode;

Future<void> fetchStravaData(String accessToken) async {
  try {
    int page = 1;
    const int perPage = 10; // Adjust as needed

    while (true) {
      // Construct the API endpoint URL for fetching activities with pagination
      final apiUrl = Uri.https(
        'www.strava.com',
        '/api/v3/athlete/activities',
        {'page': '$page', 'per_page': '$perPage'},
      );

      // Make the API request with the access token
      final response = await http.get(
        apiUrl,
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      if (response.statusCode == 200) {
        // Parse the response JSON
        final List<dynamic> activities = jsonDecode(response.body);

        if (activities.isEmpty) {
          // No more activities, break out of the loop
          break;
        }

        // Process the retrieved activities
        for (var activity in activities) {
          print('Activity ID: ${activity['id']}');
          print('Name: ${activity['name']}');
          print('Type: ${activity['type']}');
          print('Distance: ${activity['distance']} meters');
          print('---');
        }

        // Move to the next page
        page++;
      } else {
        print('Failed to fetch activities. Status code: ${response.statusCode}');
        break; // Break out of the loop on error
      }
    }
  } catch (e) {
    print('Error fetching activities: $e');
  }
}
