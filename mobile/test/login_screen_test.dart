import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:caretime/screens/login/login_screen.dart';

void main() {
  testWidgets('LoginScreen s\'affiche et contient le champ email', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));
    expect(find.text('Email'), findsOneWidget);
    expect(find.byType(TextField), findsWidgets);
  });
}
