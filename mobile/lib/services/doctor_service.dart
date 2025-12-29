import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:caretime/api_client.dart';

class DoctorService {
  static Future<Map<String, dynamic>?> fetchDoctorProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    final response = await ApiClient.get(
      '/api/users/me',
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return null;
    }
  }
}
