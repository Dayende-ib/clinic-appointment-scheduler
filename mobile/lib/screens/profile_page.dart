import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // Données fictives (à remplacer par API ou Provider)
  final doctor = const {
    'name': 'Dr Ibrahim Dayende',
    'specialty': 'Cardiologue',
    'email': 'ibrahim.dayende@clinique.com',
    'phone': '+226 70 00 00 00',
    'avatar': null, // ou une URL si tu veux afficher une image
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Color(0xFF0891B2)),
        title: Text(
          'My Profile',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF0891B2),
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Photo de profil ou avatar
            CircleAvatar(
              radius: 50,
              backgroundColor: const Color(0xFF03A6A1).withOpacity(0.1),
              child: Icon(
                Icons.person,
                size: 50,
                color: const Color(0xFF03A6A1),
              ),
            ),

            const SizedBox(height: 16),

            Text(
              doctor['name']!,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            Text(
              doctor['specialty']!,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),

            const SizedBox(height: 32),

            // Infos personnelles
            _infoTile(Icons.email, "Email", doctor['email']!),
            _infoTile(Icons.phone, "Phone", doctor['phone']!),

            const SizedBox(height: 32),

            // Boutons
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/edit-profile');
              },
              icon: const Icon(Icons.edit),
              label: const Text("Edit profile"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF03A6A1),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
                textStyle: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),

            const SizedBox(height: 12),

            OutlinedButton.icon(
              onPressed: () {
                // TODO: ajouter la logique de déconnexion
                Navigator.pushReplacementNamed(context, '/login');
              },
              icon: const Icon(Icons.logout, color: Colors.red),
              label: const Text("Logout"),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.redAccent),
                foregroundColor: Colors.red,
                minimumSize: const Size(double.infinity, 48),
                textStyle: const TextStyle(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoTile(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF0891B2)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
