// summary.dart
// ignore_for_file: avoid_print

import 'package:flutter/material.dart';

import 'summary_service.dart';

import '/../assets/theme.dart';

class ActivitySummaryCard extends StatefulWidget {
  final String accessToken;

  // Constructor with required parameters
  const ActivitySummaryCard({Key? key, required this.accessToken}) : super(key: key);

  @override
  ActivitySummaryCardState createState() => ActivitySummaryCardState();
}

class ActivitySummaryCardState extends State<ActivitySummaryCard> {
  // State variables
  String selectedRunningSummaryPeriod = 'Week';
  Duration? runningSummaryActiveTime;
  double runningSummaryTotalDistance = 0.0;
  double runningSummaryAveragePace = 0.0;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchAndSetRunningSummary();
  }

  // Fetch running summary data
  Future<void> fetchAndSetRunningSummary() async {
    try {
      setState(() {
        isLoading = true;
      });

      final result = await SummaryService.fetchRunningActivities(widget.accessToken);

      if (result['success']) {
        final activities = result['data'];
        calculateAndSetRunningSummary(activities, selectedRunningSummaryPeriod);
      } else {
        print(result['error']);
      }
    } catch (e) {
      print('Error: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Calculate and set running summary data
  void calculateAndSetRunningSummary(List<dynamic> activities, String period) {
    final summary = SummaryService.calculateRunningSummary(activities, period);

    setState(() {
      runningSummaryActiveTime = summary['runningTime'];
      runningSummaryTotalDistance = summary['totalDistance'];
      runningSummaryAveragePace = summary['averagePace'];
    });
  }

  // Build the running summary information widget
  Widget buildRunningSummaryInfo() {
    if (isLoading) {
      return Container(
        alignment: Alignment.center,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width / 2 - 80),
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    if (runningSummaryActiveTime != null) {
      final hours = runningSummaryActiveTime!.inHours;
      final minutes = (runningSummaryActiveTime!.inMinutes % 60);
      final formattedTime = hours > 0 ? '${hours}h ${minutes}m' : '${minutes}m';

      final averagePaceMinutes = runningSummaryAveragePace.floor();
      final averagePaceSeconds = ((runningSummaryAveragePace * 60) % 60).floor();

      return Container(
        alignment: Alignment.center,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Running Summary ($selectedRunningSummaryPeriod)',
                style: AppTheme.labelText3,
              ),
              Text(
                'Total Distance: ${runningSummaryTotalDistance.toStringAsFixed(2)} km',
                style: AppTheme.bodyText,
              ),
              Text(
                'Average Pace: $averagePaceMinutes:${averagePaceSeconds.toString().padLeft(2, '0')} min/km',
                style: AppTheme.bodyText,
              ),
              Text(
                'Total Time: $formattedTime',
                style: AppTheme.bodyText,
              ),
            ],
          ),
        ),
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
    return Card(
      elevation: 4,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                buildPeriodButton('Week', year: 0),
                buildPeriodButton('Month', year: 0),
                buildPeriodButton('Year', year: DateTime.now().year),
                buildPeriodButton('Previous Year', year: DateTime.now().year),
              ],
            ),
            const SizedBox(height: 10),
            buildRunningSummaryInfo(),
          ],
        ),
      ),
    );
  }

  // Build period button with elevated style
  Widget buildPeriodButton(String period, {required int year}) {
    return ElevatedButton(
      onPressed: () => switchPeriod(period),
      style: ElevatedButton.styleFrom(
        backgroundColor: selectedRunningSummaryPeriod == period ? AppTheme.selectedButtonColor : AppTheme.unselectedButtonColor,
        minimumSize: const Size(30, 30),
      ),
      child: Text(
        period == 'Year' ? '$year' : period == 'Previous Year' ? '${year - 1}' : period,
        style: const TextStyle(
          fontSize: 10,
          color: AppTheme.fontColor,
        ),
      ),
    );
  }

  // Switch the selected running summary period
  void switchPeriod(String newPeriod) async {
    setState(() {
      isLoading = true;
      selectedRunningSummaryPeriod = newPeriod;
    });

    await fetchAndSetRunningSummary();

    setState(() {
      isLoading = false;
    });
  }
}