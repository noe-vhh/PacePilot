// running_activity.dart
// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class RunningActivityPage extends StatefulWidget {
  final String accessToken;

  const RunningActivityPage({Key? key, required this.accessToken}) : super(key: key);

  @override
  RunningActivityPageState createState() => RunningActivityPageState();
}

class RunningActivityPageState extends State<RunningActivityPage> {
  // List to store running log data
  List<Map<String, dynamic>> runningLog = [];
  int currentPage = 1;
  int perPage = 50;

  // Summary variables
  String selectedRunningSummaryPeriod = 'Week';
  Duration? runningSummaryActiveTime;
  double runningSummaryTotalDistance = 0.0;
  double runningSummaryAveragePace = 0.0;

  // Variable to control whether to show or hide running log
  String selectedRunningLog = 'Show Running Log';
  String get accessToken => widget.accessToken;

  @override
  void initState() {
    super.initState();
    initializeData();
  }

  // Initialize data when the widget is created
  Future<void> initializeData() async {
    await retrieveRunningLog();
    fetchAndSetRunningLog();
    fetchAndSetRunningSummary();
  }

  // Fetch and set running log data
  Future<void> fetchAndSetRunningLog() async {
    try {
      // Function to fetch a page of running activities
      Future<void> fetchPage(int page) async {
        final apiUrl = Uri.https(
          'www.strava.com',
          '/api/v3/athlete/activities',
          {'page': '$page', 'per_page': '$perPage'},
        );

        final activityResponse = await http.get(
          apiUrl,
          headers: {'Authorization': 'Bearer ${widget.accessToken}'},
        );

        if (activityResponse.statusCode == 200) {
          final List<dynamic> activities = jsonDecode(activityResponse.body);

          setState(() {
            runningLog.clear();
          });

          // Process each activity and add it to the running log if it's a run
          for (var activity in activities) {
            if (activity['type'] == 'Run') {
              setState(() {
                runningLog.add({
                  'id': activity['id'],
                  'name': activity['name'],
                  'distance': activity['distance'],
                  'movingTime': activity['moving_time'],
                  'startDate': activity['start_date'],
                  'isFavorite': false, // Default to not favorited
                });
              });
            }
          }
        } else {
          print('Failed to fetch running log. Status code: ${activityResponse.statusCode}');
        }
      }

      // Fetch pages until all data is retrieved
      while (true) {
        int initialLength = runningLog.length;

        await fetchPage(currentPage);

        if (runningLog.length - initialLength < perPage) {
          break;
        }

        currentPage++;
      }

      // Load and apply favorited runs
      await retrieveFavoriteRuns();
    } catch (e) {
      print('Error fetching and setting running log: $e');
    }
  }

  // Retrieve favorited runs from SharedPreferences
  Future<void> retrieveFavoriteRuns() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? storedFavorites = prefs.getStringList('favorite_runs');
    if (storedFavorites != null) {
      setState(() {
        // Mark activities as favorites based on retrieved data
        for (var runId in storedFavorites) {
          for (var entry in runningLog) {
            if (entry['id'].toString() == runId) {
              entry['isFavorite'] = true;
              break;
            }
          }
        }

        // Sort the running log with favorites at the top
        runningLog.sort((a, b) {
          if (b['isFavorite'] == a['isFavorite']) {
            return DateTime.parse(b['startDate']).compareTo(DateTime.parse(a['startDate']));
          }
          return b['isFavorite'] ? 1 : -1;
        });
      });
    }
  }

  // Store favorited runs to SharedPreferences and update the UI
  Future<void> storeFavoriteRuns(List<String> favorites) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList('favorite_runs', favorites);

    // Call the helper method to update runs based on favorites
    updateFavoriteRuns(favorites);
  }

  // Update the UI based on favorited runs
  Future<void> updateFavoriteRuns(List<String> favoritedRuns) async {
    setState(() {
      // Sort the running log with favorites at the top
      runningLog.sort((a, b) {
        if (b['isFavorite'] == a['isFavorite']) {
          return DateTime.parse(b['startDate']).compareTo(DateTime.parse(a['startDate']));
        }
        return b['isFavorite'] ? 1 : -1;
      });
    });
  }

  // Check if an activity is in the running log
  bool isActivityInLog(dynamic activity) {
    return runningLog.any((logEntry) => logEntry['id'] == activity['id']);
  }

  // Store running log data to SharedPreferences
  Future<void> storeRunningLog(List<Map<String, dynamic>> log) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('running_log', jsonEncode(log));
  }

  // Retrieve running log data from SharedPreferences
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

  // Format duration in HH:mm:ss
  String formatDuration(int seconds) {
    Duration duration = Duration(seconds: seconds);
    return '${duration.inHours}h ${duration.inMinutes.remainder(60)}m ${duration.inSeconds.remainder(60)}s';
  }

  // Calculate pace in min/km
  String calculatePace(double distance, int seconds) {
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

  // Refresh running log by clearing data and fetching again
  void refreshRunningLog() {
    currentPage = 1;
    runningLog.clear();
    fetchAndSetRunningLog();
    fetchAndSetRunningSummary();
  }

  // Toggle favorite status for a run and update the UI
  void markAsFavorite(String runId) {
    setState(() {
      for (var entry in runningLog) {
        if (entry['id'].toString() == runId) {
          entry['isFavorite'] = !entry['isFavorite'];
          break;
        }
      }

      // Extract favorited runs and store them
      List<String> favoritedRuns = [];
      for (var entry in runningLog) {
        if (entry['isFavorite']) {
          favoritedRuns.add(entry['id'].toString());
        }
      }
      storeFavoriteRuns(favoritedRuns);
    });
  }

  // Helper method to build star icon based on favorite status
  Widget buildStarIcon(bool isFavorite) {
    return Icon(
      isFavorite ? Icons.star : Icons.star_border,
      color: isFavorite ? Colors.amber : null,
    );
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

  // Widget for detailed run information
  Widget buildRunDetailsPage(Map<String, dynamic> runDetails) {
    return Scaffold(
      appBar: AppBar(
        title: Text(runDetails['name']),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Distance: ${runDetails['distance'] / 1000.0} km'),
            Text('Moving Time: ${formatDuration(runDetails['movingTime'])}'),
            Text('Start Date: ${runDetails['startDate']}'),
            Text('Average Pace: ${calculatePace(runDetails['distance'], runDetails['movingTime'])}'),
            Text('Elevation Gain: ${runDetails['totalElevationGain'] ?? 0} meters'),
            Text('Calories Burned: ${runDetails['calories'] ?? 0} kcal'),
            Text('Average Heart Rate: ${runDetails['averageHeartrate'] ?? 'N/A'} bpm'),
            Text('Max Heart Rate: ${runDetails['maxHeartrate'] ?? 'N/A'} bpm'),
            // Add more details as needed
          ],
        ),
      ),
    );
  }

  // ... (existing build method)
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Select Period',
                  style: Theme.of(context).textTheme.titleMedium,
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

            const SizedBox(height: 20),

            SwitchListTile(
              title: Text(
                'Show Running Log',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              value: selectedRunningLog == 'Show Running Log',
              onChanged: (bool value) {
                setState(() {
                  selectedRunningLog = value ? 'Show Running Log' : 'Hide Running Log';
                });
              },
            ),
            const SizedBox(height: 20),

            // Display running log if selected and log is not empty
            if (selectedRunningLog == 'Show Running Log' && runningLog.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: runningLog.length,
                  itemBuilder: (context, index) {
                    final distanceInKm = runningLog[index]['distance'] / 1000.0;
                    return ListTile(
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => buildRunDetailsPage(runningLog[index])),
                              );
                            },
                            child: Text(runningLog[index]['name']),
                          ),
                          GestureDetector(
                            onTap: () {
                              markAsFavorite(runningLog[index]['id'].toString());
                            },
                            child: buildStarIcon(runningLog[index]['isFavorite']),
                          ),
                        ],
                      ),
                      subtitle: Text(
                        'Distance: ${distanceInKm.toStringAsFixed(2)} km\n'
                        'Moving Time: ${formatDuration(runningLog[index]['movingTime'])}\n'
                        'Pace: ${calculatePace(runningLog[index]['distance'], runningLog[index]['movingTime'])}',
                      ),
                    );
                  },
                ),
              ),
            // Display message if running log is empty
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
