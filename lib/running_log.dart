// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class RunningLog extends StatefulWidget {
  final String accessToken;

  const RunningLog({Key? key, required this.accessToken}) : super(key: key);

  @override
  RunningLogState createState() => RunningLogState();
}

class RunningLogState extends State<RunningLog> {
  // Key for scaffold state
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  // List to store running log entries
  List<Map<String, dynamic>> runningLog = [];

  // Pagination parameters
  int currentPage = 1;
  int perPage = 50;

  // Selected running log option
  String selectedRunningLog = 'Show Running Log';

  // Getter for access token
  String get accessToken => widget.accessToken;

  @override
  void initState() {
    super.initState();
    // Fetch and set running log data
    fetchAndSetRunningLog();
  }

  // Fetch and set running log data
  Future<void> fetchAndSetRunningLog() async {
    try {
      // Function to fetch a page of running activities
      Future<void> fetchPage(int page) async {
        final apiUrl = Uri.https(
          'www.strava.com',
          '/api/v3/athlete/activities',
          {'page': '$page', 'per_page': '50'},
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

          for (var activity in activities) {
            if (activity['type'] == 'Run') {
              setState(() {
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
              });
            }
          }
        } else {
          print('Failed to fetch running log. Status code: ${activityResponse.statusCode}');
        }
      }

      // Fetch pages until no more results
      while (true) {
        int initialLength = runningLog.length;

        await fetchPage(runningLog.length ~/ 50 + 1);

        if (runningLog.length - initialLength < 50) {
          break;
        }
      }

      // Retrieve and update favorite runs
      await retrieveFavoriteRuns();
    } catch (e) {
      print('Error fetching and setting running log: $e');
    }
  }

  // Retrieve and update favorite runs
  Future<void> retrieveFavoriteRuns() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? storedFavorites = prefs.getStringList('favorite_runs');
    if (storedFavorites != null) {
      setState(() {
        for (var runId in storedFavorites) {
          for (var entry in runningLog) {
            if (entry['id'].toString() == runId) {
              entry['isFavorite'] = true;
              break;
            }
          }
        }

        runningLog.sort((a, b) {
          if (b['isFavorite'] == a['isFavorite']) {
            return DateTime.parse(b['startDate']).compareTo(DateTime.parse(a['startDate']));
          }
          return b['isFavorite'] ? 1 : -1;
        });
      });
    }
  }

  // Store favorite runs
  Future<void> storeFavoriteRuns(List<String> favorites) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList('favorite_runs', favorites);

    // Update favorite runs
    updateFavoriteRuns(favorites);
  }

  // Update favorite runs
  Future<void> updateFavoriteRuns(List<String> favoritedRuns) async {
    setState(() {
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

  // Store running log to shared preferences
  Future<void> storeRunningLog(List<Map<String, dynamic>> log) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('running_log', jsonEncode(log));
  }

  // Retrieve running log from shared preferences
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
  String calculatePace(double? distance, int? seconds) {
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

  // Build star icon for favorite button
  Widget buildStarIcon(bool isFavorite, int index) {
    return IconButton(
      icon: Icon(
        isFavorite ? Icons.star : Icons.star_border,
        color: isFavorite ? Colors.amber : null,
      ),
      onPressed: () {
        toggleFavorite(index);
      },
    );
  }

  // Toggle favorite status
  void toggleFavorite(int index) {
    setState(() {
      runningLog[index]['isFavorite'] = !runningLog[index]['isFavorite'];

      List<String> favorites = runningLog
          .where((entry) => entry['isFavorite'])
          .map<String>((entry) => entry['id'].toString())
          .toList();

      // Store updated favorite runs
      storeFavoriteRuns(favorites);
    });
  }

  // Fetch and show detailed activity information
  Future<void> fetchAndShowDetails(int? activityId, BuildContext context) async {
    if (activityId == null) {
      return; // Do nothing if activityId is null
    }

    final apiUrl = Uri.https(
      'www.strava.com',
      '/api/v3/activities/$activityId',
    );

    try {
      final activityResponse = await http.get(
        apiUrl,
        headers: {'Authorization': 'Bearer ${widget.accessToken}'},
      );

      if (activityResponse.statusCode == 200) {
        final Map<String, dynamic>? detailedActivity = jsonDecode(activityResponse.body);

        if (detailedActivity != null) {
          // ignore: use_build_context_synchronously
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                backgroundColor: const Color(0xFF99BD9C),
                content: SingleChildScrollView(
                  child: buildRunDetailsPage(detailedActivity),
                ),
                actions: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Close'),
                  ),
                ],
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

  // Build widget for detailed run details page
  Widget buildRunDetailsPage(Map<String, dynamic> runDetails) {
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

  // Build a row with label and value
  Widget buildDetailRow(String label, String value) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: const Text('Running Log'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Check if running log is not empty
            if (runningLog.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: runningLog.length,
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () {
                        fetchAndShowDetails(runningLog[index]['id'], context);
                      },
                      child: RunDetailsWidget(
                        runDetails: runningLog[index],
                        onStarTap: () {
                          toggleFavorite(index);
                        },
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

// Widget for displaying run details in a ListTile
class RunDetailsWidget extends StatelessWidget {
  final Map<String, dynamic> runDetails;
  final VoidCallback onStarTap;

  const RunDetailsWidget({Key? key, required this.runDetails, required this.onStarTap}) : super(key: key);

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

  // Build star icon for favorite button
  Widget buildStarIcon() {
    return IconButton(
      icon: Icon(
        runDetails['isFavorite'] ? Icons.star : Icons.star_border,
        color: runDetails['isFavorite'] ? Colors.amber : null,
      ),
      onPressed: onStarTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(runDetails['name']),
          buildStarIcon(),
        ],
      ),
      subtitle: Text(
        'Distance: ${(runDetails['distance'] / 1000.0).toStringAsFixed(2)} km\n'
        'Moving Time: ${formatDuration(runDetails['movingTime'])}\n'
        'Pace: ${calculatePace(runDetails['distance'], runDetails['movingTime'])}',
      ),
    );
  }
}
