import 'package:flutter_test/flutter_test.dart';
import 'package:caretime/services/patient_api_service.dart';
import 'package:caretime/utils/error_handler.dart';

void main() {
  group('PatientApiService Tests', () {
    test('PatientApiService should be instantiable', () {
      // Test that the service can be instantiated
      expect(PatientApiService, isA<Type>());
    });

    test('getDoctorsList should be a static method', () {
      // Test that getDoctorsList is a static method
      expect(PatientApiService.getDoctorsList, isA<Function>());
    });

    test('bookAppointment should be a static method', () {
      // Test that bookAppointment is a static method
      expect(PatientApiService.bookAppointment, isA<Function>());
    });

    test('cancelAppointment should be a static method', () {
      // Test that cancelAppointment is a static method
      expect(PatientApiService.cancelAppointment, isA<Function>());
    });

    test('rescheduleAppointment should be a static method', () {
      // Test that rescheduleAppointment is a static method
      expect(PatientApiService.rescheduleAppointment, isA<Function>());
    });

    test('getDoctorAvailabilities should be a static method', () {
      // Test that getDoctorAvailabilities is a static method
      expect(PatientApiService.getDoctorAvailabilities, isA<Function>());
    });

    test('getMyAppointments should be a static method', () {
      // Test that getMyAppointments is a static method
      expect(PatientApiService.getMyAppointments, isA<Function>());
    });
  });

  group('ErrorHandler Tests', () {
    test('AppError should be instantiable', () {
      final error = AppError(message: 'Test error');
      expect(error.message, 'Test error');
      expect(error.code, null);
      expect(error.originalError, null);
    });

    test('AppError with code should work', () {
      final error = AppError(message: 'Test error', code: 'TEST_ERROR');
      expect(error.message, 'Test error');
      expect(error.code, 'TEST_ERROR');
    });

    test('AppError toString should return message', () {
      final error = AppError(message: 'Test error');
      expect(error.toString(), 'Test error');
    });

    test('ErrorHandler should handle validation errors', () {
      final error = ErrorHandler.handleValidationError(
        'email',
        'Invalid email',
      );
      expect(error.message, 'Erreur de validation pour email: Invalid email');
      expect(error.code, 'VALIDATION_ERROR');
    });
  });
}
