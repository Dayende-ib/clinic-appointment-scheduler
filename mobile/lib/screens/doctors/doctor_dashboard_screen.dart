import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DoctorDashboardScreen extends StatefulWidget {
  const DoctorDashboardScreen({super.key});

  @override
  State<DoctorDashboardScreen> createState() => _DoctorDashboardScreenState();
}

class _DoctorDashboardScreenState extends State<DoctorDashboardScreen> {
  // Placez ici vos données et méthodes nécessaires

  @override
  void initState() {
    super.initState();
    _checkAuth();
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

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Today's appointments",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          // ...intégrer ici le contenu du dashboard (cartes, statistiques, etc.)...
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ...autres classes de cartes (si nécessaire)...
