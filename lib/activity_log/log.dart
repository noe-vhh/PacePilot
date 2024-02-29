// Importing necessary files
import 'package:flutter/material.dart';

import 'log_service.dart';

import '/../assets/theme.dart';

class Log extends StatefulWidget {
  final String accessToken;

  const Log({Key? key, required this.accessToken}) : super(key: key);

  @override
  LogState createState() => LogState();
}

class LogState extends State<Log> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  List<Map<String, dynamic>> runningLog = [];

  String get accessToken => widget.accessToken;

  @override
  void initState() {
    super.initState();
    initializeRunningLog();
  }

  // Initialize running log data
  void initializeRunningLog() {
    LogService.fetchAndSetRunningLog(accessToken).then((log) {
      setState(() {
        runningLog = log;
      });
    });
  }

  // Toggle favorite status of a running log entry
  void toggleFavorite(int index) {
    setState(() {
      runningLog[index]['isFavorite'] = !runningLog[index]['isFavorite'];

      // Get a list of IDs for favorite entries
      List<String> favorites = runningLog
          .where((entry) => entry['isFavorite'])
          .map<String>((entry) => entry['id'].toString())
          .toList();

      // Store favorite runs
      LogService.storeFavoriteRuns(runningLog, favorites);
    });
  }

  // Fetch and show details of a running log entry
  Future<void> fetchAndShowDetails(int? activityId, BuildContext context) async {
    if (activityId == null) {
      return;
    }

    LogService.fetchAndShowDetails(activityId, context, accessToken);
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.themeData,
      child: Scaffold(
        key: scaffoldKey,
        appBar: AppBar(
          title: const Text(
            'Running Log',
            style: AppTheme.heading3,
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: AppTheme.backgroundGradient,
          ),
          child: Stack(
            children: <Widget>[
              Positioned(
                top: 60,
                left: 0,
                right: 0,
                bottom: -30,
                child: Container(
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(40)),
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
              Positioned(
                top: 90,
                left: 10,
                right: 10,
                bottom: -30,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _buildRunningLogContent(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Build the content of the running log
  Widget _buildRunningLogContent() {
    if (runningLog.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Scrollbar(
          thumbVisibility: true,
          child: SingleChildScrollView(
            child: Column(
              children: [
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: runningLog.length,
                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        InkWell(
                          onTap: () {
                            fetchAndShowDetails(runningLog[index]['id'], context);
                          },
                          child: RunDetailsWidget(
                            runDetails: runningLog[index],
                            onStarTap: () {
                              toggleFavorite(index);
                            },
                          ),
                        ),
                        if (index < runningLog.length - 1)
                          const Divider(),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Widget to display details of a single run
class RunDetailsWidget extends StatelessWidget {
  final Map<String, dynamic> runDetails;
  final VoidCallback onStarTap;

  const RunDetailsWidget({Key? key, required this.runDetails, required this.onStarTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(runDetails['name'], style: AppTheme.labelText3),
          LogService.buildStarIcon(runDetails['isFavorite'], onStarTap),
        ],
      ),
      subtitle: Text(
        'Distance: ${(runDetails['distance'] / 1000.0).toStringAsFixed(2)} km\n'
        'Moving Time: ${LogService.formatDuration(runDetails['movingTime'])}\n'
        'Pace: ${LogService.calculatePace(runDetails['distance'], runDetails['movingTime'])}',
        style: AppTheme.bodyText,
      ),
    );
  }
}