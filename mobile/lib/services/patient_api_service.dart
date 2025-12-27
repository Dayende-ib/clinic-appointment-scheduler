import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:caretime/api_config.dart';

class PatientApiService {
  // Routes backend: /api/appointments, /api/availability, etc (pas de /patients)
  static final String appointmentsUrl = '$apiBaseUrl/api/appointments';
  static final String availabilityUrl = '$apiBaseUrl/api/availability';

  // Cache simple pour les données
  static final Map<String, dynamic> _cache = {};
  static const Duration _cacheDuration = Duration(minutes: 5);
  static final Map<String, DateTime> _cacheTimestamps = {};

  // Méthode pour ajouter au cache
  static void _addToCache(String key, dynamic value) {
    _cache[key] = value;
    _cacheTimestamps[key] = DateTime.now();
  }

  // Méthode pour vérifier si le cache est valide
  static bool _isCacheValid(String key) {
    final timestamp = _cacheTimestamps[key];
    if (timestamp == null) return false;
    return DateTime.now().difference(timestamp) < _cacheDuration;
  }

  // Méthode pour nettoyer le cache expiré
  static void _cleanExpiredCache() {
    final now = DateTime.now();
    _cacheTimestamps.removeWhere((key, timestamp) {
      return now.difference(timestamp) >= _cacheDuration;
    });
    _cache.removeWhere((key, value) => !_cacheTimestamps.containsKey(key));
  }

  static Future<List<Map<String, dynamic>>> getDoctorsList() async {
    const cacheKey = 'doctors_list';

    // Vérifier le cache d'abord
    if (_isCacheValid(cacheKey)) {
      return _cache[cacheKey] as List<Map<String, dynamic>>;
    }

    _cleanExpiredCache();

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    final response = await http.get(
      Uri.parse('$apiBaseUrl/api/users/doctors'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final data = List<Map<String, dynamic>>.from(json.decode(response.body));

      // Mettre en cache
      _addToCache(cacheKey, data);

      return data;
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
      Uri.parse('$availabilityUrl/$doctorId?date=$date'),
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
      Uri.parse('$appointmentsUrl/me'),
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
      Uri.parse('$appointmentsUrl'),
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
      Uri.parse('$appointmentsUrl/$appointmentId/status'),
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
      Uri.parse('$appointmentsUrl/$appointmentId/reschedule'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'datetime': newDatetime}),
    );
    return response.statusCode == 200;
  }
}
