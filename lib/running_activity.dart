// running_activity.dart
// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'authentication.dart';

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
  double runningSummaryTotalDistance = 0.0;
  double runningSummaryAveragePace = 0.0;

  String selectedRunningLog = 'Show Running Log';
  String? accessToken;

  @override
  void initState() {
    super.initState();
    initializeData();
  }

  Future<void> initializeData() async {
    await retrieveRunningLog();
    accessToken = await getStoredAccessToken();
    fetchAndSetRunningLog();
    fetchAndSetRunningSummary();
  }

  Future<void> fetchAndSetRunningLog() async {
    try {
      // Function to fetch activities for a given page
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

          // Clear the log before adding new activities
          setState(() {
            runningLog.clear();
          });

          // Filter and add running activities to the running log
          for (var activity in activities) {
            if (activity['type'] == 'Run') {
              setState(() {
                runningLog.add({
                  'id': activity['id'],
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

      // Fetch pages until an incomplete page is received
      while (true) {
        // Save the length before fetching the page
        int initialLength = runningLog.length;

        await fetchPage(currentPage);

        // Break if the last page is reached
        if (runningLog.length - initialLength < perPage) {
          break;
        }

        currentPage++;
      }

      await storeRunningLog(runningLog);
    } catch (e) {
      print('Error fetching and setting running log: $e');
    }
  }

  bool isActivityInLog(dynamic activity) {
    // Check if the activity with the same id is already in the log
    return runningLog.any((logEntry) => logEntry['id'] == activity['id']);
  }

  Future<void> storeRunningLog(List<Map<String, dynamic>> log) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('running_log', jsonEncode(log));
  }

  Future<void> retrieveRunningLog() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedRunningLog = prefs.getString('running_log');
    if (storedRunningLog != null) {
      List<dynamic> decodedList = jsonDecode(storedRunningLog);
      List<Map<String, dynamic>> runningLogList = decodedList.cast<Map<String, dynamic>>();

      setState(() {
        runningLog = runningLogList;
      });
    }
  }

  String formatDuration(int seconds) {
    Duration duration = Duration(seconds: seconds);
    return '${duration.inHours}h ${duration.inMinutes.remainder(60)}m ${duration.inSeconds.remainder(60)}s';
  }

  String calculatePace(double distance, int seconds) {
    int paceMinutes = 0;
    int paceSeconds = 0;

    if (distance > 0) {
      double paceInMinutesPerKm = (seconds / 60) / (distance / 1000);

      paceMinutes = paceInMinutesPerKm.toInt();
      paceSeconds = ((paceInMinutesPerKm * 60) % 60).toInt();

      // Ensure seconds are not more than 59
      if (paceSeconds >= 60) {
        paceMinutes += 1;
        paceSeconds = 0;
      }
    }

    return '$paceMinutes:${paceSeconds.toString().padLeft(2, '0')} min/km';
  }

  Future<void> calculateRunningSummary(String period) async {
    try {
      final response = await http.get(
        Uri.https('www.strava.com', '/api/v3/athlete/activities'),
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> activities = jsonDecode(response.body);

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

        double averagePace = totalRunningTime > 0 ? totalRunningTime / (totalRunningDistance / 1000) / 60 : 0;

        setState(() {
          runningSummaryActiveTime = Duration(seconds: totalRunningTime.toInt());
          runningSummaryTotalDistance = totalRunningDistance / 1000;
          runningSummaryAveragePace = averagePace;
        });
      } else {
        print('Failed to fetch activities. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void fetchAndSetRunningSummary() {
    calculateRunningSummary(selectedRunningSummaryPeriod);
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

      // Convert average pace to minutes and seconds
      final averagePaceMinutes = runningSummaryAveragePace.floor();
      final averagePaceSeconds = ((runningSummaryAveragePace * 60) % 60).floor();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Running Summary ($selectedRunningSummaryPeriod)', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text(formattedTime, style: const TextStyle(fontSize: 16)),
          Text('Total Distance: ${runningSummaryTotalDistance.toStringAsFixed(2)} km', style: const TextStyle(fontSize: 16)),
          Text('Average Pace: $averagePaceMinutes:$averagePaceSeconds min/km', style: const TextStyle(fontSize: 16)),
        ],
      );
    } else {
      return Text(
        'Running Summary ($selectedRunningSummaryPeriod): No activities recorded for the selected period.',
        style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
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
