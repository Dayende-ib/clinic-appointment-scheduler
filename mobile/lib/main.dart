import 'package:flutter/material.dart';
import 'package:caretime/app_colors.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:caretime/screens/doctors/home_page.dart';
import 'package:caretime/screens/patients/patient_dashboard_page.dart';
import 'package:caretime/screens/admin/admin_dashboard_screen.dart';
import 'package:caretime/screens/login/login_screen.dart';
import 'package:caretime/screens/login/register_screen.dart';
import 'package:caretime/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('en_US', null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Caretime - Your Clinic Appointment Scheduler',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        textTheme: GoogleFonts.poppinsTextTheme(textTheme),
      ),
      home: const SplashScreen(),
      // Define routes for navigation
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/doctor': (context) => DoctorHomeScreen(),
        '/patient': (context) => PatientDashboardScreen(),
        '/admin': (context) => AdminDashboardScreen(),
      },
    );
  }
}
