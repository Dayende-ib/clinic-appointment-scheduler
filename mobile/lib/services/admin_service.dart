import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:caretime/api_client.dart';

class AdminService {
  static Future<Map<String, dynamic>> getDashboardStats() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final response = await ApiClient.get(
      '/api/admin/stats',
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load dashboard stats');
    }
  }

  static Future<List<Map<String, dynamic>>> getAllDoctors() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final response = await ApiClient.get(
      '/api/admin/doctors',
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map<Map<String, dynamic>>((item) => item).toList();
    } else {
      throw Exception('Failed to load doctors');
    }
  }

  static Future<List<Map<String, dynamic>>> getAllPatients() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final response = await ApiClient.get(
      '/api/admin/patients',
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map<Map<String, dynamic>>((item) => item).toList();
    } else {
      throw Exception('Failed to load patients');
    }
  }

  static Future<List<Map<String, dynamic>>> getAllAppointments() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final response = await ApiClient.get(
      '/api/admin/appointments',
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map<Map<String, dynamic>>((item) => item).toList();
    } else {
      throw Exception('Failed to load appointments');
    }
  }

  static Future<bool> toggleDoctorStatus(String doctorId, bool active) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final response = await ApiClient.patch(
      '/api/admin/users/$doctorId/disable',
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    return response.statusCode == 200;
  }

  static Future<bool> togglePatientStatus(String patientId, bool active) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final response = await ApiClient.patch(
      '/api/admin/users/$patientId/disable',
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    return response.statusCode == 200;
  }

  static Future<bool> deleteDoctor(String doctorId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final response = await ApiClient.delete(
      '/api/admin/users/$doctorId',
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    return response.statusCode == 200;
  }

  static Future<bool> deletePatient(String patientId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final response = await ApiClient.delete(
      '/api/admin/users/$patientId',
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    return response.statusCode == 200;
  }

  static Future<bool> deleteAppointment(String appointmentId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final response = await ApiClient.delete(
      '/api/admin/appointments/$appointmentId',
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    return response.statusCode == 200;
  }

  static Future<bool> enableUser(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    final response = await ApiClient.patch(
      '/api/admin/users/$userId/enable',
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    return response.statusCode == 200;
  }
}
