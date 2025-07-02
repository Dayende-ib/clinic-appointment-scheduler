import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class DoctorAppointmentService {
  static const String baseUrl = 'http://localhost:5000/api/appointments/me';

  static Future<List<Map<String, dynamic>>> fetchDoctorAppointments() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map<Map<String, dynamic>>((item) {
        return {
          'patient':
              "${item['patientId']['firstname']} ${item['patientId']['lastname']}",
          'date': DateTime.parse(item['datetime']),
          'status': _mapStatus(item['status']),
          'reason': item['reason'],
          'id': item['_id'],
        };
      }).toList();
    } else {
      throw Exception('Erreur lors du chargement des rendez-vous');
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

  static Future<List<Map<String, dynamic>>> fetchTodayAppointments() async {
    final all = await fetchDoctorAppointments();
    final today = DateTime.now();
    return all.where((rdv) {
      final date = rdv['date'] as DateTime;
      return date.year == today.year &&
          date.month == today.month &&
          date.day == today.day;
    }).toList();
  }

  static Future<List<Map<String, dynamic>>> fetchUpcomingAppointments() async {
    final all = await fetchDoctorAppointments();
    final now = DateTime.now();
    return all.where((rdv) {
      final date = rdv['date'] as DateTime;
      return date.isAfter(now);
    }).toList();
  }
}
