// authentication.dart
// ignore_for_file: avoid_print

import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'dart:convert' show jsonDecode;
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

import 'strava_variables.dart';

const FlutterSecureStorage _storage = FlutterSecureStorage();

Future<String?> authenticateWithStrava() async {
  print('Starting Strava authentication...');

  try {
    String? storedToken = await getStoredAccessToken();

    if (storedToken != null && !isTokenExpired(storedToken)) {
      print('Using stored non-expired token.');
      return storedToken;
    }

    print('Stored token is expired or not available. Initiating Strava authentication...');

    final authorizationUrl = Uri.https('www.strava.com', '/oauth/authorize', {
      'client_id': stravaClientId,
      'redirect_uri': redirectUri,
      'response_type': 'code',
      'scope': scope,
    });

    print('Authorization URL: $authorizationUrl');

    final result = await FlutterWebAuth2.authenticate(
      url: authorizationUrl.toString(),
      callbackUrlScheme: callbackUrlScheme,
    );

    print('Result URL: $result');

    final code = Uri.parse(result).queryParameters['code'];

    print('Authorization Code: $code');

    final tokenUrl = Uri.https('www.strava.com', '/oauth/token');

    final response = await http.post(tokenUrl, body: {
      'client_id': stravaClientId,
      'client_secret': stravaClientSecret,
      'redirect_uri': redirectUri,
      'grant_type': 'authorization_code',
      'code': code,
    });

    final accessToken = jsonDecode(response.body)['access_token'] as String;
    final refreshToken = jsonDecode(response.body)['refresh_token'] as String;

    await _storage.write(key: 'access_token', value: accessToken);
    await _storage.write(key: 'refresh_token', value: refreshToken);
    print('Access Token and Refresh Token stored successfully.');

    return accessToken;
  } catch (e) {
    print('Authentication failed. Error: $e');
    rethrow;
  }
}

bool isTokenExpired(String token) {
  try {
    Map<String, dynamic> decodedToken = JwtDecoder.decode(token);

    if (decodedToken.containsKey('exp')) {
      int expirationTimestamp = decodedToken['exp'];
      int currentTimestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      return expirationTimestamp < currentTimestamp;
    } else {
      return true;
    }
  } catch (e) {
    print('Error decoding token: $e');
    return true;
  }
}

Future<String?> getStoredAccessToken() async {
  print('Attempting to retrieve Access Token...');
  String? accessToken = await _storage.read(key: 'access_token');
  
  if (accessToken != null) {
    print('Access Token retrieved successfully.');
  } else {
    print('No Access Token available.');
  }
  
  return accessToken;
}

Future<void> deleteStoredAccessToken() async {
  await _storage.delete(key: 'access_token');
  await _storage.delete(key: 'refresh_token');
  print('Access Token and Refresh Token deleted.');
}