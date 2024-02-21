// activity_service.dart

// Importing necessary libraries
import 'dart:convert';
import 'package:http/http.dart' as http;

// A class for handling activity-related operations
class ActivityService {
  // Fetches running activities from the Strava API
  static Future<Map<String, dynamic>> fetchRunningActivities(String accessToken) async {
    try {
      // Sending a GET request to Strava API
      final response = await http.get(
        Uri.https('www.strava.com', '/api/v3/athlete/activities'),
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      // Checking the response status code
      if (response.statusCode == 200) {
        // Returning success with decoded JSON data
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        // Returning failure with an error message
        return {'success': false, 'error': 'Failed to fetch activities. Status code: ${response.statusCode}'};
      }
    } catch (e) {
      // Returning failure with an error message
      return {'success': false, 'error': 'Error: $e'};
    }
  }

  // Calculates running summary based on a given time period
  static Map<String, dynamic> calculateRunningSummary(List<dynamic> activities, String period) {
    double totalRunningTime = 0.0;
    double totalRunningDistance = 0.0;

    // Getting the current date and defining start dates for the requested period
    DateTime now = DateTime.now();
    DateTime startOfCurrentYear = DateTime(now.year);
    DateTime startOfPreviousYear = DateTime(now.year - 1);

    // Iterating through activities to calculate summary
    for (var activity in activities) {
      DateTime startDate = DateTime.parse(activity['start_date']);
      Duration difference = now.difference(startDate);

      // Applying different criteria based on the requested period
      switch (period) {
        case 'Week':
          if (difference.inDays <= 7) {
            totalRunningTime += activity['moving_time']?.toDouble() ?? 0;
            totalRunningDistance += activity['distance']?.toDouble() ?? 0;
          }
          break;
        case 'Month':
          if (difference.inDays <= 30) {
            totalRunningTime += activity['moving_time']?.toDouble() ?? 0;
            totalRunningDistance += activity['distance']?.toDouble() ?? 0;
          }
          break;
        case 'Year':
          if (startDate.isAfter(startOfCurrentYear)) {
            totalRunningTime += activity['moving_time']?.toDouble() ?? 0;
            totalRunningDistance += activity['distance']?.toDouble() ?? 0;
          }
          break;
        case 'Previous Year':
          if (startDate.isAfter(startOfPreviousYear) && startDate.isBefore(startOfCurrentYear)) {
            totalRunningTime += activity['moving_time']?.toDouble() ?? 0;
            totalRunningDistance += activity['distance']?.toDouble() ?? 0;
          }
          break;
      }
    }

    // Rounding totalRunningTime to seconds and calculating average pace
    totalRunningTime = totalRunningTime.roundToDouble();
    double averagePace = totalRunningTime > 0 ? (totalRunningTime / 60) / (totalRunningDistance / 1000) : 0;

    // Returning the calculated running summary
    return {
      'runningTime': Duration(seconds: totalRunningTime.toInt()),
      'totalDistance': totalRunningDistance / 1000,
      'averagePace': averagePace,
    };
  }
}