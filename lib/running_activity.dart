// running_activity.dart
// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'authentication.dart';
import 'strava_data.dart';

class RunningActivityPage extends StatefulWidget {
  const RunningActivityPage({Key? key}) : super(key: key);

  @override
  RunningActivityPageState createState() => RunningActivityPageState();
}

class RunningActivityPageState extends State<RunningActivityPage> {
  List<Map<String, dynamic>> runningLog = [];
  int currentPage = 1;
  int perPage = 50;

  String selectedRunningSummaryPeriod = 'Week';
  Duration? runningSummaryActiveTime;

  String selectedRunningLog = 'Show Running Log';

  Future<void> fetchAndSetRunningLog() async {
    String? accessToken = await getStoredAccessToken();

    Future<void> fetchPage(int page) async {
      final apiUrl = Uri.https(
        'www.strava.com',
        '/api/v3/athlete/activities',
        {'page': '$page', 'per_page': '$perPage'},
      );

      final activityResponse = await http.get(
        apiUrl,
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      if (activityResponse.statusCode == 200) {
        final List<dynamic> activities = jsonDecode(activityResponse.body);

        for (var activity in activities) {
          if (activity['type'] == 'Run') {
            setState(() {
              runningLog.add({
                'name': activity['name'],
                'distance': activity['distance'],
                'movingTime': activity['moving_time'],
                'startDate': activity['start_date'],
              });
            });
          }
        }
      } else {
        print('Failed to fetch running log. Status code: ${activityResponse.statusCode}');
      }
    }

    while (true) {
      await fetchPage(currentPage);
      if (runningLog.length % perPage != 0) {
        break;
      }
      currentPage++;
    }

    storeRunningLog();
  }

  String formatDuration(int seconds) {
    Duration duration = Duration(seconds: seconds);
    return '${duration.inHours}h ${duration.inMinutes.remainder(60)}m ${duration.inSeconds.remainder(60)}s';
  }

  String calculatePace(double distance, int seconds) {
    if (distance == 0) {
      return 'N/A';
    }
    double pace = seconds / (distance / 1000);
    int paceMinutes = pace.toInt() ~/ 60;
    int paceSeconds = (pace % 60).toInt();
    return '$paceMinutes:${paceSeconds.toString().padLeft(2, '0')} min/km';
  }

  Future<void> storeRunningLog() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('running_log', jsonEncode(runningLog));
  }

  Future<void> retrieveRunningLog() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedRunningLog = prefs.getString('running_log');
    if (storedRunningLog != null) {
      setState(() {
        runningLog = jsonDecode(storedRunningLog);
      });
    }
  }

  Future<void> fetchAndSetRunningSummary() async {
    final accessToken = await getStoredAccessToken();
    final result = await fetchUserActivitySummary(accessToken!, selectedRunningSummaryPeriod);
    if (result['success']) {
      final totalActiveSeconds = result['totalActiveTime']?.toDouble() ?? 0;
      final activeDuration = Duration(seconds: totalActiveSeconds.toInt());

      setState(() {
        runningSummaryActiveTime = activeDuration;
      });
    } else {
      setState(() {
        runningSummaryActiveTime = null;
      });
      print('Error: ${result['error']}');
    }
  }

  void refreshRunningLog() {
    currentPage = 1;
    runningLog.clear();
    fetchAndSetRunningLog();
    fetchAndSetRunningSummary();
  }

  Widget buildRunningSummaryInfo() {
    if (runningSummaryActiveTime != null) {
      final hours = runningSummaryActiveTime!.inHours;
      final minutes = (runningSummaryActiveTime!.inMinutes % 60);
      final formattedTime = hours > 0 ? '${hours}h ${minutes}m' : '${minutes}m';

      return buildProfileInfo('Active Time ($selectedRunningSummaryPeriod)', formattedTime);
    } else {
      return buildProfileInfo(
        'Active Time ($selectedRunningSummaryPeriod)',
        'No activities recorded for the selected period.',
      );
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

  @override
  void initState() {
    super.initState();
    retrieveRunningLog();
    fetchAndSetRunningLog();
    fetchAndSetRunningSummary();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Running Activity'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: refreshRunningLog,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            DropdownButton<String>(
              value: selectedRunningSummaryPeriod,
              onChanged: (String? value) {
                setState(() {
                  selectedRunningSummaryPeriod = value!;
                  fetchAndSetRunningSummary();
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

            buildRunningSummaryInfo(),

            const SizedBox(height: 20),

            DropdownButton<String>(
              value: selectedRunningLog,
              onChanged: (String? value) {
                setState(() {
                  selectedRunningLog = value!;
                });
              },
              items: <String>['Show Running Log', 'Hide Running Log']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            if (selectedRunningLog == 'Show Running Log' && runningLog.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: runningLog.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(runningLog[index]['name']),
                      subtitle: Text(
                        'Distance: ${runningLog[index]['distance']} meters\n'
                        'Moving Time: ${formatDuration(runningLog[index]['movingTime'])}\n'
                        'Pace: ${calculatePace(runningLog[index]['distance'], runningLog[index]['movingTime'])}',
                      ),
                    );
                  },
                ),
              ),
            if (runningLog.isEmpty)
              const Text(
                'No running activities found.',
                style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
              ),
          ],
        ),
      ),
    );
  }
}