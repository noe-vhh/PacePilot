// activity_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

class ActivityService {
  static Future<Map<String, dynamic>> fetchRunningActivities(String accessToken) async {
    try {
      final response = await http.get(
        Uri.https('www.strava.com', '/api/v3/athlete/activities'),
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        return {'success': false, 'error': 'Failed to fetch activities. Status code: ${response.statusCode}'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Error: $e'};
    }
  }

  static Map<String, dynamic> calculateRunningSummary(List<dynamic> activities, String period) {
    double totalRunningTime = 0.0;
    double totalRunningDistance = 0.0;

    DateTime now = DateTime.now();
    DateTime startOfCurrentYear = DateTime(now.year);
    DateTime startOfPreviousYear = DateTime(now.year - 1);

    for (var activity in activities) {
      DateTime startDate = DateTime.parse(activity['start_date']);
      Duration difference = now.difference(startDate);

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

    totalRunningTime = totalRunningTime.roundToDouble();

    double averagePace = totalRunningTime > 0 ? (totalRunningTime / 60) / (totalRunningDistance / 1000) : 0;

    return {
      'runningTime': Duration(seconds: totalRunningTime.toInt()),
      'totalDistance': totalRunningDistance / 1000,
      'averagePace': averagePace,
    };
  }
}