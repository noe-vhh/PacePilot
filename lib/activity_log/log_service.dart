// log_service.dart
// ignore_for_file: avoid_print

// Importing necessary libraries
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

// A service class for handling running logs and related operations
class LogService {
  // Fetches and sets the running log based on the provided access token
  static Future<List<Map<String, dynamic>>> fetchAndSetRunningLog(String accessToken) async {
    List<Map<String, dynamic>> runningLog = [];

    try {
      // Helper function to fetch a page of activities
      Future<void> fetchPage(int page) async {
        final apiUrl = Uri.https(
          'www.strava.com',
          '/api/v3/athlete/activities',
          {'page': '$page', 'per_page': '50'},
        );

        final activityResponse = await http.get(
          apiUrl,
          headers: {'Authorization': 'Bearer $accessToken'},
        );

        if (activityResponse.statusCode == 200) {
          final List<dynamic> activities = jsonDecode(activityResponse.body);

          runningLog.clear();

          for (var activity in activities) {
            if (activity['type'] == 'Run') {
              runningLog.add({
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
              });
            }
          }
        } else {
          print('Failed to fetch running log. Status code: ${activityResponse.statusCode}');
        }
      }

      // Fetching all pages of activities
      while (true) {
        int initialLength = runningLog.length;
        await fetchPage(runningLog.length ~/ 50 + 1);

        // Break the loop if the last page is reached
        if (runningLog.length - initialLength < 50) {
          break;
        }
      }

      // Retrieve favorite runs from SharedPreferences
      await retrieveFavoriteRuns(runningLog);
    } catch (e) {
      print('Error fetching and setting running log: $e');
    }

    return runningLog;
  }

  // Retrieves favorite runs from SharedPreferences and updates the running log
  static Future<void> retrieveFavoriteRuns(List<Map<String, dynamic>> runningLog) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? storedFavorites = prefs.getStringList('favorite_runs');
    if (storedFavorites != null) {
      for (var runId in storedFavorites) {
        for (var entry in runningLog) {
          if (entry['id'].toString() == runId) {
            entry['isFavorite'] = true;
            break;
          }
        }
      }

      // Sort the running log based on favorite status and start date
      runningLog.sort((a, b) {
        if (b['isFavorite'] == a['isFavorite']) {
          return DateTime.parse(b['startDate']).compareTo(DateTime.parse(a['startDate']));
        }
        return b['isFavorite'] ? 1 : -1;
      });
    }
  }

  // Stores favorite runs to SharedPreferences
  static Future<void> storeFavoriteRuns(List<Map<String, dynamic>> runningLog, List<String> favorites) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList('favorite_runs', favorites);

    // Update the order of the running log based on favorite status and start date
    updateFavoriteRuns(runningLog);
  }

  // Updates the order of the running log based on favorite status and start date
  static Future<void> updateFavoriteRuns(List<Map<String, dynamic>> runningLog) async {
    runningLog.sort((a, b) {
      if (b['isFavorite'] == a['isFavorite']) {
        return DateTime.parse(b['startDate']).compareTo(DateTime.parse(a['startDate']));
      }
      return b['isFavorite'] ? 1 : -1;
    });
  }

  // Checks if a given activity is present in the running log
  static bool isActivityInLog(List<Map<String, dynamic>> runningLog, dynamic activity) {
    return runningLog.any((logEntry) => logEntry['id'] == activity['id']);
  }

  // Stores the running log to SharedPreferences
  static Future<void> storeRunningLog(List<Map<String, dynamic>> log) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('running_log', jsonEncode(log));
  }

  // Retrieves the running log from SharedPreferences
  static Future<void> retrieveRunningLog(List<Map<String, dynamic>> runningLog) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedRunningLog = prefs.getString('running_log');
    if (storedRunningLog != null) {
      List<dynamic> decodedList = jsonDecode(storedRunningLog);
      List<Map<String, dynamic>> runningLogList = decodedList.cast<Map<String, dynamic>>();

      runningLog.clear();
      runningLog.addAll(runningLogList);
    }
  }

  // Formats duration in seconds to a human-readable string
  static String formatDuration(int seconds) {
    Duration duration = Duration(seconds: seconds);
    return '${duration.inHours}h ${duration.inMinutes.remainder(60)}m ${duration.inSeconds.remainder(60)}s';
  }

  // Calculates and formats pace based on distance and time
  static String calculatePace(double? distance, int? seconds) {
    if (distance == null || seconds == null || distance <= 0) {
      return 'N/A';
    }

    int paceMinutes = 0;
    int paceSeconds = 0;

    double paceInMinutesPerKm = (seconds / 60) / (distance / 1000);

    paceMinutes = paceInMinutesPerKm.toInt();
    paceSeconds = ((paceInMinutesPerKm * 60) % 60).toInt();

    if (paceSeconds >= 60) {
      paceMinutes += 1;
      paceSeconds = 0;
    }

    return '$paceMinutes:${paceSeconds.toString().padLeft(2, '0')} min/km';
  }

  // Builds an IconButton with a star icon for indicating favorite status
  static Widget buildStarIcon(bool isFavorite, VoidCallback onTap) {
    return IconButton(
      icon: Icon(
        isFavorite ? Icons.star : Icons.star_border,
        color: isFavorite ? Colors.amber : null,
      ),
      onPressed: onTap,
    );
  }

  // Fetches and shows details of a running activity
  static Future<void> fetchAndShowDetails(int? activityId, BuildContext context, String accessToken) async {
    if (activityId == null) {
      return;
    }

    final apiUrl = Uri.https(
      'www.strava.com',
      '/api/v3/activities/$activityId',
    );

    try {
      final activityResponse = await http.get(
        apiUrl,
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      if (activityResponse.statusCode == 200) {
        final Map<String, dynamic>? detailedActivity = jsonDecode(activityResponse.body);

        if (detailedActivity != null) {
          // Show a dialog with detailed activity information
          // ignore: use_build_context_synchronously
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                backgroundColor: const Color(0xFF99BD9C),
                content: SingleChildScrollView(
                  child: buildRunDetailsPage(detailedActivity),
                ),
              );
            },
          );
        } else {
          print('Failed to decode detailed activity.');
        }
      } else {
        print('Failed to fetch detailed activity. Status code: ${activityResponse.statusCode}');
      }
    } catch (e) {
      print('Error fetching and showing details: $e');
    }
  }

  // Builds a widget for displaying detailed information about a running activity
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
                buildDetailRow('Distance', '${(double.parse(runDetails['distance']?.toString() ?? '0.0') / 1000.0).toStringAsFixed(2)} km'),
                buildDetailRow('Moving Time', formatDuration(runDetails['elapsed_time'] ?? 0)),
                buildDetailRow('Start Date', DateFormat.yMd().add_Hms().format(DateTime.parse(runDetails['start_date']))),
                buildDetailRow('Average Pace', calculatePace(runDetails['distance'] ?? 0.0, runDetails['elapsed_time'] ?? 0)),
                buildDetailRow('Elevation Gain', '${runDetails['total_elevation_gain'] ?? 0} meters'),
                buildDetailRow('Calories Burned', '${runDetails['calories'] ?? 0} kcal'),
                buildDetailRow('Average Heart Rate', '${runDetails['average_heartrate'] ?? 'N/A'} bpm'),
                buildDetailRow('Max Heart Rate', '${runDetails['max_heartrate'] ?? 'N/A'} bpm'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Builds a row with a label and a value for detailed information
  static Widget buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(value),
        ],
      ),
    );
  }
}