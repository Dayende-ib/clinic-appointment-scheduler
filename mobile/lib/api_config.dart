import 'package:shared_preferences/shared_preferences.dart';

// URL de base de l'API
const String apiBaseUrl = 'http://localhost:5000';

// Fonction pour obtenir l'URL personnalisée
Future<String> getCustomApiUrl() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('custom_api_url') ?? apiBaseUrl;
  } catch (e) {
    return apiBaseUrl;
  }
}
