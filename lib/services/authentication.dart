// authentication.dart
// ignore_for_file: avoid_print

import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'dart:convert' show jsonDecode;
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

import 'strava_variables.dart';

const FlutterSecureStorage _storage = FlutterSecureStorage();

/// Authenticates with Strava, either by using a stored non-expired token
/// or initiating the Strava authentication process.
Future<String?> authenticateWithStrava() async {
  print('Starting Strava authentication...');

  // Attempt to retrieve the stored access token
  String? storedToken = await getStoredAccessToken();

  // Check if a token is stored and not expired
  if (storedToken != null && !isTokenExpired(storedToken)) {
    print('Using stored non-expired token.');
    return storedToken;
  }

  // If the stored token is expired or not available, proceed with authentication
  print('Stored token is expired or not available. Initiating Strava authentication...');

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

    // Get the access token and refresh token from the response
    final accessToken = jsonDecode(response.body)['access_token'] as String;
    final refreshToken = jsonDecode(response.body)['refresh_token'] as String;

    // Store the access token and refresh token securely
    await _storage.write(key: 'access_token', value: accessToken);
    await _storage.write(key: 'refresh_token', value: refreshToken);
    print('Access Token and Refresh Token stored successfully.');

    // Return the access token directly
    return accessToken;
  } catch (e) {
    print('Authentication failed. Error: $e');
    // Return null in case of failure
    return null;
  }
}

/// Checks if a given token is expired based on its 'exp' claim.
bool isTokenExpired(String token) {
  try {
    Map<String, dynamic> decodedToken = JwtDecoder.decode(token);

    // Check if the 'exp' claim is present and not expired
    if (decodedToken.containsKey('exp')) {
      int expirationTimestamp = decodedToken['exp'];
      int currentTimestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      return expirationTimestamp < currentTimestamp;
    } else {
      // If 'exp' claim is not present, consider the token as expired for safety
      return true;
    }
  } catch (e) {
    // If decoding fails, consider the token as expired for safety
    print('Error decoding token: $e');
    return true;
  }
}

/// Retrieves the stored access token from secure storage.
Future<String?> getStoredAccessToken() async {
  print('Attempting to retrieve Access Token...');
  String? accessToken = await _storage.read(key: 'access_token');
  print('Access Token retrieved successfully.');
  return accessToken;
}

/// Deletes both the stored access token and refresh token from secure storage.
Future<void> deleteStoredAccessToken() async {
  await _storage.delete(key: 'access_token');
  await _storage.delete(key: 'refresh_token');
  print('Access Token and Refresh Token deleted.');
}