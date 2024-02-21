// authentication.dart
// ignore_for_file: avoid_print

import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'dart:convert' show jsonDecode;
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'strava_variables.dart';

const FlutterSecureStorage _storage = FlutterSecureStorage();

// Modify the function signature to return the access token directly
Future<String?> authenticateWithStrava() async {
  print('Starting Strava authentication...');

  // Construct the URL
  final authorizationUrl = Uri.https('www.strava.com', '/oauth/authorize', {
    'client_id': stravaClientId,
    'redirect_uri': redirectUri,
    'response_type': 'code',
    'scope': scope,
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
      'client_secret': stravaClientSecret,
      'redirect_uri': redirectUri,
      'grant_type': 'authorization_code',
      'code': code,
    });

    // Get the access token from the response
    final accessToken = jsonDecode(response.body)['access_token'] as String;

    print('Authentication successful.');

    // Store the access token securely
    await _storage.write(key: 'access_token', value: accessToken);
    print('Access Token stored successfully.');

    // Return the access token directly
    return accessToken;

  } catch (e) {
    print('Authentication failed. Error: $e');
    // Return null in case of failure
    return null;
  }
}

// Function to get the stored access token
Future<String?> getStoredAccessToken() async {
  print('Attempting to retrieve Access Token...');
  String? accessToken = await _storage.read(key: 'access_token');
  print('Access Token retrieved: $accessToken');
  return accessToken;
}

// Function to delete the stored access token
Future<void> deleteStoredAccessToken() async {
  await _storage.delete(key: 'access_token');
  print('Access Token deleted.');
}