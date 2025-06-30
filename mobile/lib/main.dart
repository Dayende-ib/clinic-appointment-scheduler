import 'package:flutter/material.dart';
import 'package:caretime/app_colors.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:caretime/screens/welcome_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('en_US', null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Caretime - Your Clinic Appointment Scheduler',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        fontFamily:
            'Roboto', // Police par défaut pour éviter les erreurs de police
      ),
      home: const WelcomeScreen(),
    );
  }
}
