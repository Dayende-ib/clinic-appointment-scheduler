import 'package:flutter/material.dart';
import 'package:caretime/app_colors.dart';
import 'doctor_directory_screen.dart'; // Import pour accéder à la classe Doctor
import 'appointments_page.dart'; // Import pour accéder à la page de rendez-vous
import 'doctor_profile_header.dart';
import 'doctor_profile_calendar.dart';
import 'doctor_profile_availability.dart';
import 'doctor_profile_bottom_sheet.dart';

class DoctorProfileScreen extends StatefulWidget {
  final Doctor doctor;

  const DoctorProfileScreen({super.key, required this.doctor});

  @override
  State<DoctorProfileScreen> createState() => _DoctorProfileScreenState();
}

class _DoctorProfileScreenState extends State<DoctorProfileScreen> {
  int _selectedIndex = 2; // 2 = Médecins
  int selectedDay = 15;
  String selectedMonth = 'January 2025';
  List<String> availableTimes = [
    '04:30 PM',
    '05:00 PM',
    '06:30 PM',
    '07:00 PM',
    '07:45 PM',
    '08:30 PM',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // --- Déclaration des méthodes privées AVANT le build ---
  Widget _doctorProfileBody(Doctor doctor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DoctorProfileHeader(
            image: doctor.image,
            specialty: doctor.specialty,
            name: doctor.name,
            rating: doctor.rating,
          ),
          const SizedBox(height: 30),
          DoctorProfileCalendar(
            selectedMonth: selectedMonth,
            selectedDay: selectedDay,
            onDaySelected: (day) => setState(() => selectedDay = day),
          ),
          const SizedBox(height: 30),
          DoctorProfileAvailability(
            slots: availableTimes.length,
            onBookPressed: _showTimeSlotBottomSheet,
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  void _showTimeSlotBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder:
          (context) => DoctorProfileBottomSheet(
            availableTimes: availableTimes,
            onTimeSelected: _showAppointmentConfirmation,
          ),
    );
  }

  void _showAppointmentConfirmation(String time) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text('Rendez-vous confirmé'),
            content: Text(
              'Votre rendez-vous avec ${widget.doctor.name} à $time a été réservé avec succès.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final doctor = widget.doctor;
    Widget body;
    switch (_selectedIndex) {
      case 0:
        body = Center(child: Text('Accueil patient (à personnaliser)'));
        break;
      case 1:
        body = AppointmentsScreen();
        break;
      case 2:
        body = _doctorProfileBody(doctor);
        break;
      case 3:
        body = Center(child: Text('Profil patient (à personnaliser)'));
        break;
      default:
        body = _doctorProfileBody(doctor);
    }
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.grey[600]),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.more_horiz, color: Colors.grey[600]),
            onPressed: () {},
          ),
        ],
      ),
      body: body,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: Colors.grey[400],
            selectedLabelStyle: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
            elevation: 0,
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Accueil',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.calendar_today_outlined),
                activeIcon: Icon(Icons.calendar_today),
                label: 'RDV',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.medical_services_outlined),
                activeIcon: Icon(Icons.medical_services),
                label: 'Médecins',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'Profil',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
