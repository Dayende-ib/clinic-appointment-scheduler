import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:caretime/api_config.dart';

class DoctorAvailabilityService {
  static final String baseUrl = '$apiBaseUrl/api/availability';

  static Future<bool> addAvailability({
    required DateTime date,
    required List<Map<String, String>> slots,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    // Adapter le format des slots pour le backend
    final slotList =
        slots
            .map(
              (slot) => {
                'time': '${slot['start']}-${slot['end']}',
                'available': true,
              },
            )
            .toList();

    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'date': date.toIso8601String().split('T')[0],
        'slots': slotList,
      }),
    );
    return response.statusCode == 200;
  }

  static Future<List<Map<String, String>>> getAvailabilityForDate(
    DateTime date, {
    String? doctorId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    final id = doctorId ?? prefs.getString('userId') ?? '';
    final url = Uri.parse(
      '$baseUrl/all/$id?date=${date.toIso8601String().split('T')[0]}',
    );
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List slots = data['slots'] ?? [];
      return slots.map<Map<String, String>>((slot) {
        final time = slot['time'] as String;
        final parts = time.split('-');
        return {
          'start': parts[0],
          'end': parts.length > 1 ? parts[1] : parts[0],
        };
      }).toList();
    } else {
      return [];
    }
  }

  static Future<bool> addAvailabilityV2({
    required DateTime date,
    required List<Map<String, dynamic>> slots,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'date': date.toIso8601String().split('T')[0],
        'slots': slots,
      }),
    );
    return response.statusCode == 200;
  }

  static Future<bool> deleteAvailabilityForDate(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    final response = await http.delete(
      Uri.parse('$baseUrl?date=${date.toIso8601String().split('T')[0]}'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    return response.statusCode == 200;
  }
}
