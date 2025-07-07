import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:caretime/screens/patients/doctor_list_page.dart';
import 'package:caretime/providers/doctors_provider.dart';

void main() {
  group('DoctorsListScreen Widget Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    testWidgets('should show loading indicator initially', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          parent: container,
          child: const MaterialApp(home: DoctorsListScreen()),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should show error message when error occurs', (
      WidgetTester tester,
    ) async {
      // Arrange - Set error state
      container.read(doctorsProvider.notifier).state = const DoctorsState(
        error: 'Network error',
        isLoading: false,
      );

      await tester.pumpWidget(
        ProviderScope(
          parent: container,
          child: const MaterialApp(home: DoctorsListScreen()),
        ),
      );

      await tester.pump();

      expect(find.text('Error: Network error'), findsOneWidget);
    });

    testWidgets('should show doctors grid when data is loaded', (
      WidgetTester tester,
    ) async {
      // Arrange - Set doctors data
      container.read(doctorsProvider.notifier).state = const DoctorsState(
        doctors: [
          {
            '_id': '1',
            'firstname': 'John',
            'lastname': 'Doe',
            'specialty': 'Cardiology',
            'country': 'France',
            'city': 'Paris',
          },
          {
            '_id': '2',
            'firstname': 'Jane',
            'lastname': 'Smith',
            'specialty': 'Dermatology',
            'country': 'France',
            'city': 'Lyon',
          },
        ],
        isLoading: false,
      );

      await tester.pumpWidget(
        ProviderScope(
          parent: container,
          child: const MaterialApp(home: DoctorsListScreen()),
        ),
      );

      await tester.pump();

      // Should show doctor cards
      expect(find.text('John Doe'), findsOneWidget);
      expect(find.text('Jane Smith'), findsOneWidget);
      expect(find.text('Cardiology'), findsOneWidget);
      expect(find.text('Dermatology'), findsOneWidget);
    });

    testWidgets('should show search field', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          parent: container,
          child: const MaterialApp(home: DoctorsListScreen()),
        ),
      );

      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Search for a doctor...'), findsOneWidget);
    });

    testWidgets('should filter doctors when searching', (
      WidgetTester tester,
    ) async {
      // Arrange - Set doctors data
      container.read(doctorsProvider.notifier).state = const DoctorsState(
        doctors: [
          {
            '_id': '1',
            'firstname': 'John',
            'lastname': 'Doe',
            'specialty': 'Cardiology',
          },
          {
            '_id': '2',
            'firstname': 'Jane',
            'lastname': 'Smith',
            'specialty': 'Dermatology',
          },
        ],
        isLoading: false,
      );

      await tester.pumpWidget(
        ProviderScope(
          parent: container,
          child: const MaterialApp(home: DoctorsListScreen()),
        ),
      );

      await tester.pump();

      // Initially both doctors should be visible
      expect(find.text('John Doe'), findsOneWidget);
      expect(find.text('Jane Smith'), findsOneWidget);

      // Enter search query
      await tester.enterText(find.byType(TextField), 'John');
      await tester.pump();

      // Only John should be visible
      expect(find.text('John Doe'), findsOneWidget);
      expect(find.text('Jane Smith'), findsNothing);
    });

    testWidgets('should show no doctors message when filtered list is empty', (
      WidgetTester tester,
    ) async {
      // Arrange - Set doctors data
      container.read(doctorsProvider.notifier).state = const DoctorsState(
        doctors: [
          {
            '_id': '1',
            'firstname': 'John',
            'lastname': 'Doe',
            'specialty': 'Cardiology',
          },
        ],
        isLoading: false,
      );

      await tester.pumpWidget(
        ProviderScope(
          parent: container,
          child: const MaterialApp(home: DoctorsListScreen()),
        ),
      );

      await tester.pump();

      // Enter search query that doesn't match
      await tester.enterText(find.byType(TextField), 'NonExistentDoctor');
      await tester.pump();

      // Should show no doctors available message
      expect(find.text('No doctors available'), findsOneWidget);
      expect(find.text('Try adjusting your filters'), findsOneWidget);
    });
  });
}
