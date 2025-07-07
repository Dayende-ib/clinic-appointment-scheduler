import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AppError {
  final String message;
  final String? code;
  final dynamic originalError;

  const AppError({required this.message, this.code, this.originalError});

  @override
  String toString() => message;
}

class ErrorHandler {
  static AppError handleHttpError(http.Response response) {
    switch (response.statusCode) {
      case 400:
        return const AppError(
          message: 'Requête invalide. Vérifiez vos données.',
          code: 'BAD_REQUEST',
        );
      case 401:
        return const AppError(
          message: 'Non autorisé. Veuillez vous reconnecter.',
          code: 'UNAUTHORIZED',
        );
      case 403:
        return const AppError(message: 'Accès interdit.', code: 'FORBIDDEN');
      case 404:
        return const AppError(
          message: 'Ressource non trouvée.',
          code: 'NOT_FOUND',
        );
      case 500:
        return const AppError(
          message: 'Erreur serveur. Veuillez réessayer plus tard.',
          code: 'SERVER_ERROR',
        );
      case 502:
        return const AppError(
          message: 'Serveur temporairement indisponible.',
          code: 'BAD_GATEWAY',
        );
      case 503:
        return const AppError(
          message: 'Service temporairement indisponible.',
          code: 'SERVICE_UNAVAILABLE',
        );
      default:
        return AppError(
          message: 'Erreur inattendue (${response.statusCode})',
          code: 'UNKNOWN_ERROR',
        );
    }
  }

  static AppError handleNetworkError(dynamic error) {
    if (error.toString().contains('SocketException')) {
      return const AppError(
        message: 'Pas de connexion internet. Vérifiez votre connexion.',
        code: 'NO_INTERNET',
      );
    }
    if (error.toString().contains('TimeoutException')) {
      return const AppError(
        message: 'Délai d\'attente dépassé. Vérifiez votre connexion.',
        code: 'TIMEOUT',
      );
    }
    return AppError(
      message: 'Erreur de connexion: ${error.toString()}',
      code: 'NETWORK_ERROR',
      originalError: error,
    );
  }

  static AppError handleValidationError(String field, String message) {
    return AppError(
      message: 'Erreur de validation pour $field: $message',
      code: 'VALIDATION_ERROR',
    );
  }

  static void showErrorSnackBar(BuildContext context, AppError error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                error.message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  static void showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(message, style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  static void showInfoSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(message, style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
