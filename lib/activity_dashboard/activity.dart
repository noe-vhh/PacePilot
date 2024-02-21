// activity.dart
// ignore_for_file: avoid_print

// Importing necessary libraries
import 'package:flutter/material.dart';

// Importing the ActivityService for fetching and calculating running summaries
import 'activity_service.dart';

// A StatefulWidget for the RunningActivityPage
class ActivityPage extends StatefulWidget {
  final String accessToken;

  const ActivityPage({Key? key, required this.accessToken}) : super(key: key);

  @override
  ActivityPageState createState() => ActivityPageState();
}

// State class for the RunningActivityPage
class ActivityPageState extends State<ActivityPage> {
  // Summary variables
  String selectedRunningSummaryPeriod = 'Week';
  Duration? runningSummaryActiveTime;
  double runningSummaryTotalDistance = 0.0;
  double runningSummaryAveragePace = 0.0;

  @override
  void initState() {
    super.initState();
    // Fetch and set running summary when the page is initialized
    fetchAndSetRunningSummary();
  }

  // Fetch and set running summary
  void fetchAndSetRunningSummary() async {
    try {
      // Fetching running activities using the ActivityService
      final result = await ActivityService.fetchRunningActivities(widget.accessToken);

      // Checking the success of the fetch operation
      if (result['success']) {
        final activities = result['data'];
        // Calculating and setting the running summary
        calculateAndSetRunningSummary(activities, selectedRunningSummaryPeriod);
      } else {
        // Printing the error message if fetch operation fails
        print(result['error']);
      }
    } catch (e) {
      // Printing the error if an exception occurs
      print('Error: $e');
    }
  }

  // Calculating and setting the running summary
  void calculateAndSetRunningSummary(List<dynamic> activities, String period) {
    // Using the ActivityService to calculate the running summary
    final summary = ActivityService.calculateRunningSummary(activities, period);

    // Setting the state with the calculated summary
    setState(() {
      runningSummaryActiveTime = summary['runningTime'];
      runningSummaryTotalDistance = summary['totalDistance'];
      runningSummaryAveragePace = summary['averagePace'];
    });
  }

  // Widget for displaying the running summary information
  Widget buildRunningSummaryInfo() {
    if (runningSummaryActiveTime != null) {
      // Formatting the time values
      final hours = runningSummaryActiveTime!.inHours;
      final minutes = (runningSummaryActiveTime!.inMinutes % 60);
      final formattedTime = hours > 0 ? '${hours}h ${minutes}m' : '${minutes}m';

      // Formatting the average pace values
      final averagePaceMinutes = runningSummaryAveragePace.floor();
      final averagePaceSeconds = ((runningSummaryAveragePace * 60) % 60).floor();

      // Returning a Column with running summary information
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
      // Returning a Text widget with a message if no activities are recorded
      return Text(
        'Running Summary ($selectedRunningSummaryPeriod): No activities recorded for the selected period.',
        style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
      );
    }
  }

  // Build method for constructing the UI of the RunningActivityPage
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