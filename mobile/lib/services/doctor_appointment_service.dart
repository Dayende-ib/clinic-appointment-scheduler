import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:caretime/api_client.dart';

class DoctorAppointmentService {
  static Future<List<Map<String, dynamic>>> fetchDoctorAppointments() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final response = await ApiClient.get(
      '/api/appointments/me',
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map<Map<String, dynamic>>((item) {
        final patient = item['patientId'] ?? {};
        return {
          'patient': "${patient['firstname']} ${patient['lastname']}",
          'patientDetails': patient,
          'date': DateTime.parse(item['datetime']),
          'status': _mapStatus(item['status']),
          'originalStatus': item['status'],
          'reason': item['reason'],
          'notes': item['notes'] ?? {},
          'id': item['_id'],
          'datetime': item['datetime'],
        };
      }).toList();
    } else {
      throw Exception('Failed to load appointments');
    }
  }

  static String _mapStatus(String status) {
    switch (status) {
      case 'completed':
        return 'Completed';
      case 'canceled':
        return 'Cancelled';
      case 'booked':
      case 'confirmed':
      case 'pending':
        return 'Upcoming';
      default:
        return 'Unknown';
    }
  }

  static Future<bool> confirmAppointment(String appointmentId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final response = await ApiClient.patch(
      '/api/appointments/$appointmentId/status',
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({'status': 'confirmed'}),
    );

    return response.statusCode == 200;
  }

  static Future<bool> rejectAppointment(String appointmentId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final response = await ApiClient.patch(
      '/api/appointments/$appointmentId/status',
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({'status': 'canceled'}),
    );

    return response.statusCode == 200;
  }
}
