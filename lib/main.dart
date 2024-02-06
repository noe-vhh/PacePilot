import 'package:flutter/material.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'dart:convert' show jsonDecode;
import 'package:http/http.dart' as http;

// Strava specific variables
final stravaClientId = '120493';

final callbackUrlScheme = 'pacepilot';
final callbackUrlPath = 'redirect';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String? accessToken;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Strava Authentication Demo'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                authenticateWithStrava();
              },
              child: Text('Authenticate with Strava'),
            ),
            SizedBox(height: 20),
            if (accessToken != null)
              ElevatedButton(
                onPressed: () {
                  fetchStravaData(accessToken!);
                },
                child: Text('Fetch Strava Data'),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> authenticateWithStrava() async {
    print('Starting Strava authentication...');

    // Construct the URL
    final authorizationUrl = Uri.https('www.strava.com', '/oauth/authorize', {
      'client_id': stravaClientId,
      'redirect_uri': '$callbackUrlScheme://$callbackUrlPath',
      'response_type': 'code',
      'scope': 'activity:read', // Add your required scopes
    });

    print('Authorization URL: $authorizationUrl');

    try {
      // Authenticate and get the result URL
      final result = await FlutterWebAuth2.authenticate(
        url: authorizationUrl.toString(),
        callbackUrlScheme: '$callbackUrlScheme',
      );

      print('Result URL: $result');

      // Extract the authorization code from the result URL
      final code = Uri.parse(result).queryParameters['code'];

      print('Authorization Code: $code');

      // Construct the token request URL
      final tokenUrl = Uri.https('www.strava.com', '/oauth/token');

      // Use the authorization code to get an access token
      final response = await http.post(tokenUrl, body: {
        'client_id': stravaClientId,
        'client_secret': 'dea1b26c6ec474eec8e160d2b828a1ab7f07f29f',
        'redirect_uri': '$callbackUrlScheme://$callbackUrlPath',
        'grant_type': 'authorization_code',
        'code': code,
      });

      print('Token Response: $response');

      // Get the access token from the response
      final accessToken = jsonDecode(response.body)['access_token'] as String;

      print('Authentication successful. Access Token: $accessToken');

      setState(() {
        this.accessToken = accessToken;
      });
    } catch (e) {
      print('Authentication failed. Error: $e');
    }
  }

Future<void> fetchStravaData(String accessToken) async {
  try {
    int page = 1;
    const int perPage = 10; // Adjust as needed

    while (true) {
      // Construct the API endpoint URL for fetching activities with pagination
      final apiUrl = Uri.https(
        'www.strava.com',
        '/api/v3/athlete/activities',
        {'page': '$page', 'per_page': '$perPage'},
      );

      // Make the API request with the access token
      final response = await http.get(
        apiUrl,
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      if (response.statusCode == 200) {
        // Parse the response JSON
        final List<dynamic> activities = jsonDecode(response.body);

        if (activities.isEmpty) {
          // No more activities, break out of the loop
          break;
        }

        // Process the retrieved activities
        for (var activity in activities) {
          print('Activity ID: ${activity['id']}');
          print('Name: ${activity['name']}');
          print('Type: ${activity['type']}');
          print('Distance: ${activity['distance']} meters');
          print('---');
        }

        // Move to the next page
        page++;
      } else {
        print('Failed to fetch activities. Status code: ${response.statusCode}');
        break; // Break out of the loop on error
      }
    }
  } catch (e) {
    print('Error fetching activities: $e');
  }
}
}