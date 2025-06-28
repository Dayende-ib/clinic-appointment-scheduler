import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'doctor_appointments_screen.dart';
import 'availability_screen.dart';
import 'profile_screen.dart';
import 'home_doctor_screen.dart';

class DoctorDashboardScreen extends StatefulWidget {
  const DoctorDashboardScreen({super.key});

  @override
  State<DoctorDashboardScreen> createState() => _DoctorDashboardScreenState();
}

class _DoctorDashboardScreenState extends State<DoctorDashboardScreen> {
  int _selectedIndex = 0;

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
    DateFormat.yMMMMd('en_US').format(DateTime.now());
    final appointments = [
      {'patient': 'Karim Sanou', 'time': '09:00'},
      {'patient': 'Fatou Ouédraogo', 'time': '11:00'},
      {'patient': 'Djakari Konan', 'time': '09:00'},
      {'patient': 'Clémence Zongo', 'time': '11:00'},
    ];

    final List<Widget> pages = [
      HomeDoctorScreen(
        appointments: appointments,
        onQuickAction: (int idx) => setState(() => _selectedIndex = idx),
      ),
      const DoctorAppointmentsScreen(),
      const AvailabilityScreen(),
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
          if (index == 3) {
            showNotificationsSheet();
          } else {
            setState(() => _selectedIndex = index);
          }
        },
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
          BottomNavigationBarItem(icon: Icon(Icons.schedule), label: 'RDV'),
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            label: 'Disponibilité',
          ),
        ],
      ),
    );
  }
}
