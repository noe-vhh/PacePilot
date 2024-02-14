// running_activity.dart
// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RunningActivityPage extends StatefulWidget {
  final String accessToken;

  const RunningActivityPage({Key? key, required this.accessToken}) : super(key: key);

  @override
  RunningActivityPageState createState() => RunningActivityPageState();
}

class RunningActivityPageState extends State<RunningActivityPage> {
  // Summary variables
  String selectedRunningSummaryPeriod = 'Week';
  Duration? runningSummaryActiveTime;
  double runningSummaryTotalDistance = 0.0;
  double runningSummaryAveragePace = 0.0;

  @override
  void initState() {
    super.initState();
    // Fetch and set running summary
    fetchAndSetRunningSummary();
  }

  // Calculate running summary based on the selected period
  Future<void> calculateRunningSummary(String period) async {
    try {
      final response = await http.get(
        Uri.https('www.strava.com', '/api/v3/athlete/activities'),
        headers: {'Authorization': 'Bearer ${widget.accessToken}'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> activities = jsonDecode(response.body);

        double totalRunningTime = 0.0;
        double totalRunningDistance = 0.0;

        DateTime now = DateTime.now();
        DateTime startOfCurrentYear = DateTime(now.year);
        DateTime startOfPreviousYear = DateTime(now.year - 1);

        // Calculate totals based on the selected period
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

        // Update the state with the calculated summary
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

  // Fetch and set running summary
  void fetchAndSetRunningSummary() {
    calculateRunningSummary(selectedRunningSummaryPeriod);
  }

  // Widget to display running summary information
  Widget buildRunningSummaryInfo() {
    if (runningSummaryActiveTime != null) {
      final hours = runningSummaryActiveTime!.inHours;
      final minutes = (runningSummaryActiveTime!.inMinutes % 60);
      final formattedTime = hours > 0 ? '${hours}h ${minutes}m' : '${minutes}m';

      final averagePaceMinutes = runningSummaryAveragePace.floor();
      final averagePaceSeconds = ((runningSummaryAveragePace * 60) % 60).floor();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Running Summary ($selectedRunningSummaryPeriod)', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text('Total Distance: ${runningSummaryTotalDistance.toStringAsFixed(2)} km', style: const TextStyle(fontSize: 16)),
          Text('Average Pace: $averagePaceMinutes:${averagePaceSeconds.toString().padLeft(2, '0')} min/km', style: const TextStyle(fontSize: 16)),
          Text('Total Time: $formattedTime', style: const TextStyle(fontSize: 16)),
        ],
      );
    } else {
      return Text(
        'Running Summary ($selectedRunningSummaryPeriod): No activities recorded for the selected period.',
        style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Running Dashboard'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Select Period',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
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
              ],
            ),
            const SizedBox(height: 20),
            buildRunningSummaryInfo(),
            const SizedBox(height: 20),
            const Divider(),
          ],
        ),
      ),
    );
  }
}