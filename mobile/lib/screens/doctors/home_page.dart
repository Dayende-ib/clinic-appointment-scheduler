import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'doctor_appointments_screen.dart';
import 'doctor_availability_page.dart';
import '../profile_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DoctorDashboardScreen extends StatefulWidget {
  const DoctorDashboardScreen({super.key});

  @override
  State<DoctorDashboardScreen> createState() => _DoctorDashboardScreenState();
}

class _DoctorDashboardScreenState extends State<DoctorDashboardScreen> {
  int _selectedIndex = 0;
  List<Map<String, dynamic>> appointments = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkAuth();
    _fetchAppointments();
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

  Future<void> _fetchAppointments() async {
    setState(() {
      isLoading = true;
    });
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) return;
    final response = await http.get(
      Uri.parse('http://localhost:5000/api/appointments/doctor'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        appointments = data.cast<Map<String, dynamic>>();
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur lors du chargement des rendez-vous.'),
        ),
      );
    }
  }

  void showNotificationsSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        final notifications = [
          "Nouveau rendez-vous réservé à 09:00",
          "Fatou Ouédraogo a annulé son rendez-vous",
        ];
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Notifications",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0891B2),
                ),
              ),
              const SizedBox(height: 16),
              ...notifications.map(
                (notif) => ListTile(
                  leading: const Icon(
                    Icons.notifications,
                    color: Color(0xFF03A6A1),
                  ),
                  title: Text(
                    notif,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final today = DateFormat.yMMMMd('en_US').format(DateTime.now());
    String title;
    String? subtitle;
    if (_selectedIndex == 0) {
      title = "Welcome Doctor 👨‍⚕️";
      subtitle = "Today is $today";
    } else if (_selectedIndex == 1) {
      title = "Appointments";
      subtitle = null;
    } else if (_selectedIndex == 2) {
      title = "Availability";
      subtitle = null;
    } else if (_selectedIndex == 3) {
      title = "Profile";
      subtitle = null;
    } else {
      title = "";
      subtitle = null;
    }
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Theme.of(context).colorScheme.surface,
      elevation: 0,
      centerTitle: false,
      title:
          subtitle == null
              ? Text(title, style: Theme.of(context).textTheme.headlineSmall)
              : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(title, style: Theme.of(context).textTheme.headlineSmall),
                  SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                  ),
                ],
              ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_none, color: Color(0xFF0891B2)),
          onPressed: showNotificationsSheet,
        ),
        IconButton(
          icon: const Icon(Icons.person_outline, color: Color(0xFF0891B2)),
          onPressed:
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final List<Widget> pages = [
      DoctorDashboardContent(appointments: appointments),
      const DoctorAppointmentsScreen(),
      const DoctorAvailabilityPage(),
      const ProfileScreen(),
    ];
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: _buildAppBar(),
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() => _selectedIndex = index);
        },
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.schedule),
            label: 'Appointments',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            label: 'Availability',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class DoctorDashboardContent extends StatelessWidget {
  final List<Map<String, dynamic>> appointments;
  const DoctorDashboardContent({super.key, required this.appointments});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Today's appointments (${appointments.length})",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          ...appointments.map(
            (rdv) => Card(
              child: ListTile(
                title: Text(rdv['patientName'] ?? ''),
                subtitle: Text(rdv['date'] ?? ''),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
