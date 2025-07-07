import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:caretime/providers/auth_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('AuthProvider Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state should be unauthenticated', () {
      final authState = container.read(authProvider);
      expect(authState.isAuthenticated, false);
      expect(authState.token, null);
      expect(authState.role, null);
      expect(authState.isLoading, false);
    });

    test('login should update state correctly', () async {
      final notifier = container.read(authProvider.notifier);

      await notifier.login(
        token: 'test_token',
        role: 'patient',
        userId: 'user123',
      );

      final authState = container.read(authProvider);
      expect(authState.isAuthenticated, true);
      expect(authState.token, 'test_token');
      expect(authState.role, 'patient');
      expect(authState.userId, 'user123');
    });

    test('logout should clear state', () async {
      final notifier = container.read(authProvider.notifier);

      // First login
      await notifier.login(
        token: 'test_token',
        role: 'patient',
        userId: 'user123',
      );

      // Then logout
      await notifier.logout();

      final authState = container.read(authProvider);
      expect(authState.isAuthenticated, false);
      expect(authState.token, null);
      expect(authState.role, null);
      expect(authState.userId, null);
    });

    test('isAuthenticatedProvider should return correct value', () {
      // Initially false
      expect(container.read(isAuthenticatedProvider), false);

      // After login
      container
          .read(authProvider.notifier)
          .login(token: 'test_token', role: 'patient', userId: 'user123');

      expect(container.read(isAuthenticatedProvider), true);
    });

    test('userRoleProvider should return correct role', () {
      // Initially null
      expect(container.read(userRoleProvider), null);

      // After login
      container
          .read(authProvider.notifier)
          .login(token: 'test_token', role: 'doctor', userId: 'user123');

      expect(container.read(userRoleProvider), 'doctor');
    });
  });
}
