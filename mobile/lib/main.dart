import 'package:flutter/material.dart';
import 'package:caretime/app_colors.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:caretime/screens/doctors/home_page.dart';
import 'package:caretime/screens/doctors/doctor_dashboard_screen.dart';
import 'package:caretime/screens/doctors/doctor_appointments_screen.dart';
import 'package:caretime/screens/doctors/doctor_quick_availability_page.dart';
import 'package:caretime/screens/patients/patient_dashboard_page.dart';
import 'package:caretime/screens/patients/doctor_list_page.dart';
import 'package:caretime/screens/patients/appointments_page.dart';
import 'package:caretime/screens/login/login_screen.dart';
import 'package:caretime/screens/login/register_screen.dart';
import 'package:caretime/screens/splash_screen.dart';
import 'package:caretime/screens/profile_page.dart';
import 'screens/admin/admin_dashboard_new.dart' as admin_new;
import 'screens/admin/admin_doctors_screen.dart';
import 'screens/admin/admin_patients_screen.dart';
import 'screens/admin/admin_appointments_screen.dart';
import 'screens/admin/all_doctor_schedules_screen.dart';
import 'screens/welcome_page.dart';

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
        textTheme: GoogleFonts.nunitoTextTheme(textTheme).copyWith(
          headlineLarge: GoogleFonts.nunito(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1F2937),
          ),
          headlineMedium: GoogleFonts.nunito(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1F2937),
          ),
          titleLarge: GoogleFonts.nunito(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF0891B2),
          ),
          bodyLarge: GoogleFonts.nunito(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF374151),
          ),
          bodyMedium: GoogleFonts.nunito(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF374151),
          ),
          labelLarge: GoogleFonts.nunito(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF0891B2),
          ),
        ),
      ),
      home: const SplashScreen(),
      // Define routes for navigation
      routes: {
        '/welcome': (context) => const WelcomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/doctor': (context) => DoctorHomeScreen(),
        '/doctor/dashboard': (context) => const DoctorDashboardScreen(),
        '/doctor/appointments': (context) {
          final args =
              ModalRoute.of(context)?.settings.arguments
                  as Map<String, dynamic>?;
          return DoctorAppointmentsScreen(arguments: args);
        },
        '/doctor/availability':
            (context) => const DoctorQuickAvailabilityPage(),
        '/patient': (context) => PatientDashboardScreen(),
        '/patient/doctors': (context) => const DoctorsListScreen(),
        '/patient/appointments': (context) => const AppointmentsScreen(),
        '/admin': (context) => admin_new.AdminDashboardScreen(),
        '/admin/dashboard': (context) => admin_new.AdminDashboardScreen(),
        '/admin/doctors': (context) => AdminDoctorsScreen(),
        '/admin/patients': (context) => AdminPatientsScreen(),
        '/admin/appointments': (context) => AdminAppointmentsScreen(),
        '/admin/appointments/today':
            (context) =>
                AdminAppointmentsScreen(arguments: {'filter': 'today'}),
        '/admin/appointments/pending':
            (context) =>
                AdminAppointmentsScreen(arguments: {'filter': 'pending'}),
        '/admin/schedules': (context) {
          final args =
              ModalRoute.of(context)?.settings.arguments
                  as Map<String, dynamic>?;
          final doctors = args?['doctors'] as List<Map<String, dynamic>>? ?? [];
          return AllDoctorSchedulesScreen(doctors: doctors);
        },
        '/admin/doctors/appointments': (context) {
          final args =
              ModalRoute.of(context)?.settings.arguments
                  as Map<String, dynamic>?;
          final doctorId = args?['doctorId'];
          return AdminAppointmentsScreen(arguments: {'doctorId': doctorId});
        },
        '/admin/doctors/schedule': (context) {
          final args =
              ModalRoute.of(context)?.settings.arguments
                  as Map<String, dynamic>?;
          final doctorId = args?['doctorId'];
          // On passe la liste des docteurs avec uniquement ce docteur
          return AllDoctorSchedulesScreen(
            doctors: [
              if (doctorId != null) {'id': doctorId},
            ],
          );
        },
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}
