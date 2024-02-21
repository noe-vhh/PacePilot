// log.dart

// Importing necessary libraries
import 'package:flutter/material.dart';

// Importing the LogService for fetching and managing running logs
import 'log_service.dart';

// A StatefulWidget for the RunningLog
class Log extends StatefulWidget {
  final String accessToken;

  const Log({Key? key, required this.accessToken}) : super(key: key);

  @override
  LogState createState() => LogState();
}

// State class for the RunningLog
class LogState extends State<Log> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  List<Map<String, dynamic>> runningLog = [];
  int currentPage = 1;
  int perPage = 50;
  String selectedRunningLog = 'Show Running Log';

  String get accessToken => widget.accessToken;

  @override
  void initState() {
    super.initState();
    // Initializing the running log when the page is initialized
    initializeRunningLog();
  }

  // Initializing the running log
  void initializeRunningLog() {
    LogService.fetchAndSetRunningLog(accessToken).then((log) {
      setState(() {
        runningLog = log;
      });
    });
  }

  // Toggling favorite status of a running log entry
  void toggleFavorite(int index) {
    setState(() {
      runningLog[index]['isFavorite'] = !runningLog[index]['isFavorite'];

      // Extracting the IDs of favorite runs
      List<String> favorites = runningLog
          .where((entry) => entry['isFavorite'])
          .map<String>((entry) => entry['id'].toString())
          .toList();

      // Storing favorite runs
      LogService.storeFavoriteRuns(runningLog, favorites);
    });
  }

  // Fetching and showing details of a running activity
  Future<void> fetchAndShowDetails(int? activityId, BuildContext context) async {
    if (activityId == null) {
      return;
    }

    // Using the LogService to fetch and show details
    LogService.fetchAndShowDetails(activityId, context, accessToken);
  }

  // Build method for constructing the UI of the RunningLog
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

// Widget for displaying details of a running activity
class RunDetailsWidget extends StatelessWidget {
  final Map<String, dynamic> runDetails;
  final VoidCallback onStarTap;

  const RunDetailsWidget({Key? key, required this.runDetails, required this.onStarTap}) : super(key: key);

  // Build method for constructing the UI of the RunDetailsWidget
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(runDetails['name']),
          LogService.buildStarIcon(runDetails['isFavorite'], onStarTap),
        ],
      ),
      subtitle: Text(
        'Distance: ${(runDetails['distance'] / 1000.0).toStringAsFixed(2)} km\n'
        'Moving Time: ${LogService.formatDuration(runDetails['movingTime'])}\n'
        'Pace: ${LogService.calculatePace(runDetails['distance'], runDetails['movingTime'])}',
      ),
    );
  }
}