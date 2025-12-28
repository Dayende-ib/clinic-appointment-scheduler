import 'package:flutter/material.dart';
import 'doctor_dashboard_screen.dart';
import 'doctor_appointments_screen.dart';
import 'doctor_quick_availability_page.dart';
import '../profile_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:caretime/strings.dart';

class DoctorHomeScreen extends StatefulWidget {
  const DoctorHomeScreen({super.key});

  @override
  State<DoctorHomeScreen> createState() => _DoctorHomeScreenState();
}

class _DoctorHomeScreenState extends State<DoctorHomeScreen> {
  int _selectedIndex = 0;
  bool isLoading = false;
  String doctorName = '';

  @override
  void initState() {
    super.initState();
    _checkAuth();
    _loadDoctorName();
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

  Future<void> _loadDoctorName() async {
    final prefs = await SharedPreferences.getInstance();
    final firstname = prefs.getString('firstname') ?? '';
    setState(() {
      doctorName = firstname;
    });
  }

  PreferredSizeWidget _buildAppBar() {
    String title;
    String? subtitle;
    if (_selectedIndex == 0) {
      title = AppStrings.doctorHomeDashboard;
    } else if (_selectedIndex == 1) {
      title = AppStrings.doctorHomeAppointments;
      subtitle = null;
    } else if (_selectedIndex == 2) {
      title = "";
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
      const DoctorDashboardScreen(),
      const DoctorAppointmentsScreen(),
      const DoctorQuickAvailabilityPage(),
      const ProfileScreen(),
    ];
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: (_selectedIndex == 2) ? null : _buildAppBar(),
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
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: AppStrings.patientHome,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.schedule),
            label: AppStrings.doctorHomeAppointments,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            label: AppStrings.doctorHomeAvailability,
          ),
        ],
      ),
    );
  }
}
