import 'package:shared_preferences/shared_preferences.dart';

// URL de base de l'API
const String apiBaseUrl =
    'https://clinic-appointment-scheduler-backend.onrender.com';

// Fonction pour obtenir l'URL personnalisée
Future<String> getCustomApiUrl() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('custom_api_url') ?? apiBaseUrl;
  } catch (e) {
    return apiBaseUrl;
  }
}
