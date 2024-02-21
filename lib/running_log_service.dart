// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

class RunningLogService {
  static Future<Map<String, dynamic>> fetchRunningLog(String accessToken) async {
    try {
      final apiUrl = Uri.https('www.strava.com', '/api/v3/athlete/activities', {'page': '1', 'per_page': '50'});

      final activityResponse = await http.get(
        apiUrl,
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      if (activityResponse.statusCode == 200) {
        final List<dynamic> activities = jsonDecode(activityResponse.body);

        List<Map<String, dynamic>> runningLog = activities
            .where((activity) => activity['type'] == 'Run')
            .map<Map<String, dynamic>>(_createRunningLogEntry)
            .toList();

        return {'success': true, 'data': runningLog};
      } else {
        return {'success': false, 'error': 'Failed to fetch running log. Status code: ${activityResponse.statusCode}'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Error fetching running log: $e'};
    }
  }

    static Future<Map<String, dynamic>?> fetchDetailedActivity(String accessToken, int activityId) async {
    try {
      final apiUrl = Uri.https('www.strava.com', '/api/v3/activities/$activityId');

      final detailedActivityResponse = await http.get(
        apiUrl,
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      if (detailedActivityResponse.statusCode == 200) {
        final Map<String, dynamic> detailedActivity = jsonDecode(detailedActivityResponse.body);
        return detailedActivity;
      } else {
        print('Failed to fetch detailed activity. Status code: ${detailedActivityResponse.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching detailed activity: $e');
      return null;
    }
  }

    static Future<void> storeFavoriteRuns(List<String> favorites) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList('favorite_runs', favorites);
  }

  static Map<String, dynamic> _createRunningLogEntry(dynamic activity) {
    return {
      'id': activity['id'],
      'name': activity['name'],
      'distance': activity['distance'],
      'movingTime': activity['moving_time'],
      'startDate': activity['start_date'],
      'elevationGain': activity['total_elevation_gain'],
      'calories': activity['calories'],
      'averageHeartrate': activity['average_heartrate'],
      'maxHeartrate': activity['max_heartrate'],
      'isFavorite': false,
    };
  }

  static Future<void> updateFavoriteRuns(List<Map<String, dynamic>> runningLog, List<String> favoritedRuns) async {
    runningLog.sort((a, b) {
      if (b['isFavorite'] == a['isFavorite']) {
        return DateTime.parse(b['startDate']).compareTo(DateTime.parse(a['startDate']));
      }
      return b['isFavorite'] ? 1 : -1;
    });
  }

  static Future<void> storeRunningLog(List<Map<String, dynamic>> log) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('running_log', jsonEncode(log));
  }

  static Future<List<Map<String, dynamic>>> retrieveRunningLog() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedRunningLog = prefs.getString('running_log');

    if (storedRunningLog != null) {
      List<dynamic> decodedList = jsonDecode(storedRunningLog);
      return decodedList.cast<Map<String, dynamic>>();
    } else {
      return [];
    }
  }

  static String formatDuration(int seconds) {
    Duration duration = Duration(seconds: seconds);
    return '${duration.inHours}h ${duration.inMinutes.remainder(60)}m ${duration.inSeconds.remainder(60)}s';
  }

  static String calculatePace(double distance, int seconds) {
    int paceMinutes = 0;
    int paceSeconds = 0;

    if (distance > 0) {
      double paceInMinutesPerKm = (seconds / 60) / (distance / 1000);

      paceMinutes = paceInMinutesPerKm.toInt();
      paceSeconds = ((paceInMinutesPerKm * 60) % 60).toInt();

      if (paceSeconds >= 60) {
        paceMinutes += 1;
        paceSeconds = 0;
      }
    }

    return '$paceMinutes:${paceSeconds.toString().padLeft(2, '0')} min/km';
  }

  static Widget buildRunDetailsPage(Map<String, dynamic> runDetails) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('Distance', '${(double.parse(runDetails['distance']?.toString() ?? '0.0') / 1000.0).toStringAsFixed(2)} km'),
                _buildDetailRow('Moving Time', formatDuration(runDetails['elapsed_time'] ?? 0)),
                _buildDetailRow('Start Date', DateFormat.yMd().add_Hms().format(DateTime.parse(runDetails['start_date']))),
                _buildDetailRow('Average Pace', calculatePace(runDetails['distance'] ?? 0.0, runDetails['elapsed_time'] ?? 0)),
                _buildDetailRow('Elevation Gain', '${runDetails['total_elevation_gain'] ?? 0} meters'),
                _buildDetailRow('Calories Burned', '${runDetails['calories'] ?? 0} kcal'),
                _buildDetailRow('Average Heart Rate', '${runDetails['average_heartrate'] ?? 'N/A'} bpm'),
                _buildDetailRow('Max Heart Rate', '${runDetails['max_heartrate'] ?? 'N/A'} bpm'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(value),
      ],
    );
  }
}
