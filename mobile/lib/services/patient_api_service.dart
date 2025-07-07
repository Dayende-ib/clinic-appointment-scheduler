import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:caretime/api_config.dart';
import 'package:caretime/utils/error_handler.dart';

// Classe pour représenter un docteur
class DoctorModel {
  final String id;
  final String firstname;
  final String lastname;
  final String email;
  final String phone;
  final String specialty;
  final String licenseNumber;
  final String country;
  final String city;
  final String gender;
  final bool isActive;
  final double rating;
  final int experience;
  final double consultationFee;

  DoctorModel({
    required this.id,
    required this.firstname,
    required this.lastname,
    required this.email,
    required this.phone,
    required this.specialty,
    required this.licenseNumber,
    required this.country,
    required this.city,
    required this.gender,
    required this.isActive,
    required this.rating,
    required this.experience,
    required this.consultationFee,
  });

  String get fullName => '$firstname $lastname'.trim();
  String get displayName => fullName.isNotEmpty ? fullName : 'Dr. $specialty';
  String get location => '$city, $country'.trim();

  factory DoctorModel.fromMap(Map<String, dynamic> map) {
    return DoctorModel(
      id: map['_id'] ?? '',
      firstname: map['firstname'] ?? '',
      lastname: map['lastname'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      specialty: map['specialty'] ?? 'General Medicine',
      licenseNumber: map['licenseNumber'] ?? '',
      country: map['country'] ?? '',
      city: map['city'] ?? '',
      gender: map['gender'] ?? '',
      isActive: map['isActive'] ?? true,
      rating: (map['rating'] ?? 0.0).toDouble(),
      experience: map['experience'] ?? 0,
      consultationFee: (map['consultationFee'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'firstname': firstname,
      'lastname': lastname,
      'email': email,
      'phone': phone,
      'specialty': specialty,
      'licenseNumber': licenseNumber,
      'country': country,
      'city': city,
      'gender': gender,
      'isActive': isActive,
      'rating': rating,
      'experience': experience,
      'consultationFee': consultationFee,
    };
  }
}

class PatientApiService {
  static Future<String> get _baseUrl async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('custom_api_url') ?? apiBaseUrl;
    } catch (e) {
      return apiBaseUrl;
    }
  }

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
      print('📋 Using cached doctors list');
      return _cache[cacheKey] as List<Map<String, dynamic>>;
    }

    _cleanExpiredCache();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      if (token.isEmpty) {
        throw const AppError(
          message: 'Token not found. Please login again.',
          code: 'AUTH_ERROR',
        );
      }

      final baseUrl = await _baseUrl;
      final url = '$baseUrl/api/users/doctors';
      print('🔍 Fetching doctors from: $url');
      print('🔑 Token: ${token.substring(0, 10)}...');

      final response = await http
          .get(
            Uri.parse(url),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 15));

      print('📡 Response status: ${response.statusCode}');
      print('📄 Response body length: ${response.body.length}');

      if (response.statusCode == 200) {
        final List<dynamic> rawData = json.decode(response.body);

        // Validation et nettoyage des données
        final List<Map<String, dynamic>> validatedData = [];

        for (final doctor in rawData) {
          if (doctor is Map<String, dynamic>) {
            // Vérifier que c'est bien un docteur
            if (doctor['role'] == 'doctor' && doctor['isActive'] == true) {
              // Nettoyer et valider les données
              final validatedDoctor = {
                '_id': doctor['_id'] ?? '',
                'firstname': doctor['firstname'] ?? '',
                'lastname': doctor['lastname'] ?? '',
                'email': doctor['email'] ?? '',
                'phone': doctor['phone'] ?? '',
                'specialty': doctor['specialty'] ?? 'General Medicine',
                'licenseNumber': doctor['licenseNumber'] ?? '',
                'country': doctor['country'] ?? '',
                'city': doctor['city'] ?? '',
                'gender': doctor['gender'] ?? '',
                'isActive': doctor['isActive'] ?? true,
                'rating': doctor['rating'] ?? 0.0,
                'experience': doctor['experience'] ?? 0,
                'consultationFee': doctor['consultationFee'] ?? 0.0,
              };

              // Vérifier que le docteur a au moins un nom
              if (validatedDoctor['firstname'].isNotEmpty ||
                  validatedDoctor['lastname'].isNotEmpty) {
                validatedData.add(validatedDoctor);
              }
            }
          }
        }

        print('✅ Loaded ${validatedData.length} valid doctors');

        // Mettre en cache seulement si on a des données valides
        if (validatedData.isNotEmpty) {
          _addToCache(cacheKey, validatedData);
        }

        return validatedData;
      } else if (response.statusCode == 401) {
        throw const AppError(
          message: 'Unauthorized access. Please login again.',
          code: 'UNAUTHORIZED',
        );
      } else if (response.statusCode == 404) {
        throw const AppError(
          message: 'Doctors endpoint not found.',
          code: 'NOT_FOUND',
        );
      } else {
        print('❌ HTTP Error: ${response.statusCode} - ${response.body}');
        throw ErrorHandler.handleHttpError(response);
      }
    } catch (e) {
      print('💥 Exception in getDoctorsList: $e');
      if (e is AppError) {
        rethrow;
      }
      throw ErrorHandler.handleNetworkError(e);
    }
  }

  static Future<List<Map<String, dynamic>>> getDoctorAvailabilities(
    String doctorId,
    String date,
  ) async {
    // date format: yyyy-MM-dd
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    final baseUrl = await _baseUrl;
    final response = await http.get(
      Uri.parse('$baseUrl/api/availability/$doctorId?date=$date'),
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
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      if (token.isEmpty) {
        throw const AppError(
          message: 'Token not found. Please login again.',
          code: 'AUTH_ERROR',
        );
      }

      final baseUrl = await _baseUrl;
      final url = '$baseUrl/api/appointments/me';
      print('🔍 Fetching appointments from: $url');
      print('🔑 Token: ${token.substring(0, 10)}...');

      final response = await http
          .get(Uri.parse(url), headers: {'Authorization': 'Bearer $token'})
          .timeout(const Duration(seconds: 10));

      print('📡 Response status: ${response.statusCode}');
      print('📄 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        print('✅ Loaded ${data.length} appointments');
        return data.cast<Map<String, dynamic>>();
      } else {
        print('❌ HTTP Error: ${response.statusCode} - ${response.body}');
        throw ErrorHandler.handleHttpError(response);
      }
    } catch (e) {
      print('💥 Exception in getMyAppointments: $e');
      if (e is AppError) {
        rethrow;
      }
      throw ErrorHandler.handleNetworkError(e);
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
    final baseUrl = await _baseUrl;
    final response = await http.post(
      Uri.parse('$baseUrl/api/appointments'),
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
    final baseUrl = await _baseUrl;
    final response = await http.patch(
      Uri.parse('$baseUrl/api/appointments/$appointmentId/status'),
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
    final baseUrl = await _baseUrl;
    final response = await http.patch(
      Uri.parse('$baseUrl/api/appointments/$appointmentId/reschedule'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'datetime': newDatetime}),
    );
    return response.statusCode == 200;
  }

  // Méthode pour forcer le rafraîchissement du cache des docteurs
  static Future<List<Map<String, dynamic>>> refreshDoctorsList() async {
    const cacheKey = 'doctors_list';

    // Supprimer le cache existant
    _cache.remove(cacheKey);
    _cacheTimestamps.remove(cacheKey);

    print('🔄 Forcing refresh of doctors list');
    return await getDoctorsList();
  }

  // Méthode pour obtenir les docteurs avec gestion d'erreur améliorée
  static Future<List<Map<String, dynamic>>> getDoctorsListWithRetry({
    int maxRetries = 3,
    Duration retryDelay = const Duration(seconds: 2),
  }) async {
    int attempts = 0;

    while (attempts < maxRetries) {
      try {
        return await getDoctorsList();
      } catch (e) {
        attempts++;
        print('⚠️ Attempt $attempts failed: $e');

        if (attempts >= maxRetries) {
          rethrow;
        }

        // Attendre avant de réessayer
        await Future.delayed(retryDelay * attempts);
      }
    }

    throw const AppError(
      message: 'Failed to load doctors after multiple attempts',
      code: 'MAX_RETRIES_EXCEEDED',
    );
  }

  // Méthode pour obtenir les docteurs sous forme d'objets Doctor
  static Future<List<DoctorModel>> getDoctorsAsObjects() async {
    final doctorsData = await getDoctorsList();
    return doctorsData.map((data) => DoctorModel.fromMap(data)).toList();
  }

  // Méthode pour filtrer les docteurs par spécialité
  static Future<List<DoctorModel>> getDoctorsBySpecialty(
    String specialty,
  ) async {
    final doctors = await getDoctorsAsObjects();
    return doctors
        .where(
          (doctor) =>
              doctor.specialty.toLowerCase().contains(specialty.toLowerCase()),
        )
        .toList();
  }

  // Méthode pour rechercher les docteurs par nom
  static Future<List<DoctorModel>> searchDoctors(String query) async {
    final doctors = await getDoctorsAsObjects();
    final queryLower = query.toLowerCase();

    return doctors
        .where(
          (doctor) =>
              doctor.fullName.toLowerCase().contains(queryLower) ||
              doctor.specialty.toLowerCase().contains(queryLower) ||
              doctor.city.toLowerCase().contains(queryLower),
        )
        .toList();
  }

  // Méthode pour trier les docteurs par note
  static Future<List<DoctorModel>> getDoctorsSortedByRating() async {
    final doctors = await getDoctorsAsObjects();
    doctors.sort((a, b) => b.rating.compareTo(a.rating));
    return doctors;
  }

  // Méthode pour obtenir les spécialités disponibles
  static Future<List<String>> getAvailableSpecialties() async {
    final doctors = await getDoctorsAsObjects();
    final specialties = doctors.map((d) => d.specialty).toSet().toList();
    specialties.sort();
    return specialties;
  }

  // Méthode pour obtenir un docteur par ID
  static Future<DoctorModel?> getDoctorById(String doctorId) async {
    final doctors = await getDoctorsAsObjects();
    try {
      return doctors.firstWhere((doctor) => doctor.id == doctorId);
    } catch (e) {
      return null;
    }
  }

  // Méthode pour obtenir les statistiques des docteurs
  static Future<Map<String, dynamic>> getDoctorsStats() async {
    final doctors = await getDoctorsAsObjects();

    final totalDoctors = doctors.length;
    final activeDoctors = doctors.where((d) => d.isActive).length;
    final specialties = doctors.map((d) => d.specialty).toSet().length;
    final avgRating =
        doctors.isNotEmpty
            ? doctors.map((d) => d.rating).reduce((a, b) => a + b) /
                doctors.length
            : 0.0;

    return {
      'totalDoctors': totalDoctors,
      'activeDoctors': activeDoctors,
      'specialties': specialties,
      'averageRating': avgRating,
    };
  }

  // Méthode pour obtenir les docteurs recommandés (par note)
  static Future<List<DoctorModel>> getRecommendedDoctors({
    int limit = 5,
  }) async {
    final doctors = await getDoctorsSortedByRating();
    return doctors.take(limit).toList();
  }

  // Méthode pour vérifier la disponibilité d'un docteur
  static Future<bool> isDoctorAvailable(String doctorId) async {
    final doctor = await getDoctorById(doctorId);
    return doctor != null && doctor.isActive;
  }

  // Méthode pour obtenir les docteurs par localisation
  static Future<List<DoctorModel>> getDoctorsByLocation(String city) async {
    final doctors = await getDoctorsAsObjects();
    return doctors
        .where(
          (doctor) => doctor.city.toLowerCase().contains(city.toLowerCase()),
        )
        .toList();
  }

  // Méthode pour obtenir les docteurs par fourchette de prix
  static Future<List<DoctorModel>> getDoctorsByPriceRange({
    double? minPrice,
    double? maxPrice,
  }) async {
    final doctors = await getDoctorsAsObjects();

    return doctors.where((doctor) {
      if (minPrice != null && doctor.consultationFee < minPrice) return false;
      if (maxPrice != null && doctor.consultationFee > maxPrice) return false;
      return true;
    }).toList();
  }
}
