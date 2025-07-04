import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:caretime/screens/login/register_screen.dart';

void main() {
  testWidgets('RegisterScreen s\'affiche et contient le champ prénom', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: RegisterScreen()));
    expect(find.text('First name'), findsOneWidget);
    expect(find.byType(TextFormField), findsWidgets);
  });
}
