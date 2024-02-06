import 'package:flutter/material.dart';
import 'authorisation.dart';
import 'data_calling.dart';
import 'dart:async'; // Import async library for Future and StreamController

// ignore: library_private_types_in_public_api
final GlobalKey<_MyHomePageState> homeKey = GlobalKey<_MyHomePageState>();

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String? accessToken;

  @override
  void initState() {
    super.initState();
    // Check for a stored access token when the widget is initialized
    checkAccessToken();
  }

  // Function to check for a stored access token
  Future<void> checkAccessToken() async {
    String? storedToken = await getStoredAccessToken();
    if (storedToken != null) {
      setAccessToken(storedToken);
    }
  }

  void setAccessToken(String? token) {
    setState(() {
      accessToken = token;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Strava Authentication Demo'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (accessToken == null)
              ElevatedButton(
                onPressed: () async {
                  await authenticateWithStrava();
                  // No need to setAccessToken here; it will be done in checkAccessToken
                },
                child: const Text('Authenticate with Strava'),
              ),
            const SizedBox(height: 20),
            if (accessToken != null)
              ElevatedButton(
                onPressed: () {
                  fetchStravaData(accessToken!);
                },
                child: const Text('Fetch Strava Data'),
              ),
          ],
        ),
      ),
    );
  }
}