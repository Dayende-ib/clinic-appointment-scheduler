import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:caretime/api_config.dart';

class PatientApiService {
  static final String baseUrl = '${apiBaseUrl}/api';

  static Future<List<Map<String, dynamic>>> getDoctorsList() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    final response = await http.get(
      Uri.parse('$baseUrl/users/doctors'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to load doctors');
    }
  }

  static Future<List<Map<String, dynamic>>> getDoctorAvailabilities(
    String doctorId,
    String date,
  ) async {
    // date format: yyyy-MM-dd
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    final response = await http.get(
      Uri.parse('$baseUrl/availability/$doctorId?date=$date'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List slots = data['slots'] ?? [];
      return slots.cast<Map<String, dynamic>>();
    } else {
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> getMyAppointments() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    final response = await http.get(
      Uri.parse('$baseUrl/appointments/me'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to load appointments');
    }
  }

  static Future<bool> bookAppointment({
    required String doctorId,
    required String datetime, // format ISO
    required String reason,
    String? patientNotes,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    final response = await http.post(
      Uri.parse('$baseUrl/appointments'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'doctorId': doctorId,
        'datetime': datetime,
        'reason': reason,
        if (patientNotes != null) 'patientNotes': patientNotes,
      }),
    );
    return response.statusCode == 201;
  }

  static Future<bool> cancelAppointment(String appointmentId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    final response = await http.patch(
      Uri.parse('$baseUrl/appointments/$appointmentId/status'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'status': 'canceled'}),
    );
    return response.statusCode == 200;
  }

  static Future<bool> rescheduleAppointment(
    String appointmentId,
    String newDatetime,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    final response = await http.patch(
      Uri.parse('$baseUrl/appointments/$appointmentId/reschedule'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'datetime': newDatetime}),
    );
    return response.statusCode == 200;
  }
}
