// home_user_profile_service.dart

import 'package:http/http.dart' as http;
import 'dart:convert' show jsonDecode;

class UserProfileService {
  static Future<Map<String, dynamic>> fetchUserProfile(String accessToken) async {
    try {
      final response = await http.get(
        Uri.https('www.strava.com', '/api/v3/athlete'),
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> userData = jsonDecode(response.body);
        return {'success': true, ...userData};
      } else {
        return {'success': false, 'error': 'Failed to fetch user profile. Status code: ${response.statusCode}'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Error fetching user profile: $e'};
    }
  }
}