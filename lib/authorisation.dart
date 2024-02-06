// authorization.dart
// ignore_for_file: avoid_print

import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'dart:convert' show jsonDecode;
import 'package:http/http.dart' as http;
import 'strava_variables.dart';
import 'main.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const FlutterSecureStorage _storage = FlutterSecureStorage();

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
      callbackUrlScheme: callbackUrlScheme,
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
    
    // Set the access token in the state
    if (homeKey.currentState != null) {
      homeKey.currentState!.setAccessToken(accessToken);
    }

    // Store the access token securely
    await _storage.write(key: 'access_token', value: accessToken);

  } catch (e) {
    print('Authentication failed. Error: $e');
  }
}

// Function to get the stored access token
Future<String?> getStoredAccessToken() async {
  return await _storage.read(key: 'access_token');
}

// Function to delete the stored access token
Future<void> deleteStoredAccessToken() async {
  await _storage.delete(key: 'access_token');
}
