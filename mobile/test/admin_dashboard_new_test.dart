import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:caretime/screens/admin/admin_dashboard_new.dart';

void main() {
  testWidgets('AdminDashboardScreen affiche le chargement', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: AdminDashboardScreen()));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
