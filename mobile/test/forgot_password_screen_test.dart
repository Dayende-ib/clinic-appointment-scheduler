import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:caretime/screens/login/forgot_password_screen.dart';

void main() {
  testWidgets('ForgotPasswordScreen s\'affiche et contient le champ email', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: ForgotPasswordScreen()));
    expect(find.text('Email'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
  });
}
