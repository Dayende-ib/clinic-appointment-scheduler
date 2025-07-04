import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:caretime/screens/profile_page.dart';

void main() {
  testWidgets('ProfileScreen affiche le chargement', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: ProfileScreen()));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
