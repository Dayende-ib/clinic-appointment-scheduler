import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:caretime/api_config.dart';

class ApiClient {
  static const String _debugModeKey = 'debug_mode';
  static const String _debugLogsKey = 'debug_http_logs';
  static const int _maxLogs = 100;

  static Future<bool> isDebugModeEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_debugModeKey) ?? false;
  }

  static Future<void> setDebugModeEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_debugModeKey, enabled);
  }

  static Future<List<Map<String, dynamic>>> getLogs() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_debugLogsKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .where((entry) => entry is Map)
          .map((entry) => Map<String, dynamic>.from(entry as Map))
          .toList(growable: false);
    } catch (_) {
      return [];
    }
  }

  static Future<void> clearLogs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_debugLogsKey);
  }

  static Future<Uri> _buildUri(String pathOrUrl) async {
    final trimmed = pathOrUrl.trim();
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return Uri.parse(trimmed);
    }
    final base = await getCustomApiUrl();
    final baseUri = Uri.parse(base);
    return baseUri.resolve(trimmed);
  }

  static Future<void> _log({
    required String method,
    required Uri uri,
    int? statusCode,
    String? error,
  }) async {
    if (!await isDebugModeEnabled()) return;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_debugLogsKey);
    List<dynamic> entries = [];
    if (raw != null && raw.isNotEmpty) {
      try {
        entries = jsonDecode(raw) as List<dynamic>;
      } catch (_) {
        entries = [];
      }
    }
    final entry = <String, dynamic>{
      'ts': DateTime.now().toIso8601String(),
      'method': method,
      'url': uri.toString(),
      'status': statusCode,
      if (error != null) 'error': error,
    };
    entries.add(entry);
    if (entries.length > _maxLogs) {
      entries = entries.sublist(entries.length - _maxLogs);
    }
    await prefs.setString(_debugLogsKey, jsonEncode(entries));
  }

  static Future<http.Response> get(
    String pathOrUrl, {
    Map<String, String>? headers,
  }) async {
    final uri = await _buildUri(pathOrUrl);
    try {
      final response = await http.get(uri, headers: headers);
      await _log(method: 'GET', uri: uri, statusCode: response.statusCode);
      return response;
    } catch (e) {
      await _log(method: 'GET', uri: uri, error: e.toString());
      rethrow;
    }
  }

  static Future<http.Response> post(
    String pathOrUrl, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) async {
    final uri = await _buildUri(pathOrUrl);
    try {
      final response = await http.post(
        uri,
        headers: headers,
        body: body,
        encoding: encoding,
      );
      await _log(method: 'POST', uri: uri, statusCode: response.statusCode);
      return response;
    } catch (e) {
      await _log(method: 'POST', uri: uri, error: e.toString());
      rethrow;
    }
  }

  static Future<http.Response> put(
    String pathOrUrl, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) async {
    final uri = await _buildUri(pathOrUrl);
    try {
      final response = await http.put(
        uri,
        headers: headers,
        body: body,
        encoding: encoding,
      );
      await _log(method: 'PUT', uri: uri, statusCode: response.statusCode);
      return response;
    } catch (e) {
      await _log(method: 'PUT', uri: uri, error: e.toString());
      rethrow;
    }
  }

  static Future<http.Response> patch(
    String pathOrUrl, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) async {
    final uri = await _buildUri(pathOrUrl);
    try {
      final response = await http.patch(
        uri,
        headers: headers,
        body: body,
        encoding: encoding,
      );
      await _log(method: 'PATCH', uri: uri, statusCode: response.statusCode);
      return response;
    } catch (e) {
      await _log(method: 'PATCH', uri: uri, error: e.toString());
      rethrow;
    }
  }

  static Future<http.Response> delete(
    String pathOrUrl, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) async {
    final uri = await _buildUri(pathOrUrl);
    try {
      final response = await http.delete(
        uri,
        headers: headers,
        body: body,
        encoding: encoding,
      );
      await _log(method: 'DELETE', uri: uri, statusCode: response.statusCode);
      return response;
    } catch (e) {
      await _log(method: 'DELETE', uri: uri, error: e.toString());
      rethrow;
    }
  }
}
