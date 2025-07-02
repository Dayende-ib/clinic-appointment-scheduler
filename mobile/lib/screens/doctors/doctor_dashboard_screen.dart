import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/doctor_service.dart';
import '../../services/doctor_appointment_service.dart';

class DoctorDashboardScreen extends StatefulWidget {
  const DoctorDashboardScreen({super.key});

  @override
  State<DoctorDashboardScreen> createState() => _DoctorDashboardScreenState();
}

class _DoctorDashboardScreenState extends State<DoctorDashboardScreen> {
  Map<String, dynamic>? doctorProfile;
  bool isLoading = true;
  String? error;
  List<Map<String, dynamic>> todayAppointments = [];
  int completedCount = 0;
  int upcomingCount = 0;
  List<Map<String, dynamic>> upcomingAppointments = [];

  @override
  void initState() {
    super.initState();
    _checkAuth();
    _loadProfile();
    _loadTodayAppointments();
    _loadUpcomingAppointments();
  }

  Future<void> _checkAuth() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null || token.isEmpty) {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  Future<void> _loadProfile() async {
    setState(() {
      isLoading = true;
      error = null;
    });
    try {
      final data = await DoctorService.fetchDoctorProfile();
      setState(() {
        doctorProfile = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> _loadTodayAppointments() async {
    try {
      final data = await DoctorAppointmentService.fetchTodayAppointments();
      setState(() {
        todayAppointments = data;
        completedCount = data.where((a) => a['status'] == 'Completed').length;
        upcomingCount = data.where((a) => a['status'] == 'Upcoming').length;
      });
    } catch (e) {
      // ignore erreur pour l'instant
    }
  }

  Future<void> _loadUpcomingAppointments() async {
    try {
      final data = await DoctorAppointmentService.fetchUpcomingAppointments();
      setState(() {
        upcomingAppointments = data;
      });
    } catch (e) {
      // ignore erreur pour l'instant
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (error != null) {
      return Center(child: Text('Erreur: $error'));
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Card(
                  color: Colors.teal.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        Text(
                          'Total',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${todayAppointments.length}',
                          style: TextStyle(fontSize: 20),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Card(
                  color: Colors.green.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        Text(
                          'Completed',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text('$completedCount', style: TextStyle(fontSize: 20)),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Card(
                  color: Colors.blue.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        Text(
                          'Upcoming',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text('$upcomingCount', style: TextStyle(fontSize: 20)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            "Today's appointments",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          if (todayAppointments.isEmpty) const Text('No appointments today.'),
          ...todayAppointments.map(
            (rdv) => Card(
              child: ListTile(
                title: Text(rdv['patient'] ?? ''),
                subtitle: Text(rdv['reason'] ?? ''),
                trailing: Text(rdv['status'] ?? ''),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "Upcoming appointments",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          if (upcomingAppointments.isEmpty)
            const Text('No upcoming appointments.'),
          ...upcomingAppointments
              .take(5)
              .map(
                (rdv) => Card(
                  child: ListTile(
                    title: Text(rdv['patient'] ?? ''),
                    subtitle: Text(rdv['reason'] ?? ''),
                    trailing: Text(
                      (rdv['date'] as DateTime).toString().substring(0, 16),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ),
              ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ...autres classes de cartes (si nécessaire)...
