import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// URL de base de l'API
const String apiBaseUrl = 'http://localhost:5000';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? userData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkAuth();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    // Si le token est null, on arrête le chargement. _checkAuth s'occupera de la redirection.
    if (token == null) {
      if (mounted) setState(() => isLoading = false);
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('$apiBaseUrl/api/users/me'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          userData = data;
          isLoading = false;
        });
        // Stocke localement les données utilisateur
        await prefs.setString('userData', jsonEncode(data));
        // Met à jour le rôle local si besoin
        if (data['role'] != null) {
          await prefs.setString('role', data['role']);
        }
      } else {
        // Si erreur serveur, tente de charger les données locales
        final local = prefs.getString('userData');
        if (local != null) {
          setState(() {
            userData = jsonDecode(local);
            isLoading = false;
          });
        } else {
          setState(() => isLoading = false);
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors du chargement du profil.')),
        );
      }
    } catch (e) {
      // Si erreur réseau, tente de charger les données locales
      final local = prefs.getString('userData');
      if (local != null) {
        setState(() {
          userData = jsonDecode(local);
          isLoading = false;
        });
      } else {
        if (mounted) setState(() => isLoading = false);
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur de connexion : $e')));
    }
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

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  Future<void> _showLogoutConfirmationDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Déconnexion'),
          content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Annuler'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: const Text('Confirmer'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _logout();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Chargement du profil...'),
            ],
          ),
        ),
      );
    }
    if (userData == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              const Text('Aucune donnée utilisateur.'),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _fetchUserData,
                icon: const Icon(Icons.refresh),
                label: const Text('Réessayer'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF03A6A1),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Color(0xFF0891B2)),
        title: const Text(
          'Profile',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF0891B2),
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 24,
                  horizontal: 16,
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: const Color(
                        0xFF03A6A1,
                      ).withAlpha((0.1 * 255).toInt()),
                      child: Icon(
                        Icons.person,
                        size: 60,
                        color: const Color(0xFF03A6A1),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "${userData!['firstname'] ?? ''} ${userData!['lastname'] ?? ''}",
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      userData!['specialty'] ?? '',
                      style: TextStyle(fontSize: 15, color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 12,
                ),
                child: Column(
                  children: [
                    _infoTile(Icons.email, "Email", userData!['email'] ?? ''),
                    const Divider(),
                    _infoTile(
                      Icons.phone,
                      "Téléphone",
                      userData!['phone'] ?? '',
                    ),
                    const Divider(),
                    _infoTile(
                      Icons.location_city,
                      "Ville",
                      userData!['city'] ?? '',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final updatedUserData = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) =>
                                  EditProfileScreen(userData: userData!),
                        ),
                      );
                      if (updatedUserData != null && mounted) {
                        setState(() {
                          userData = updatedUserData;
                        });
                        // Met à jour le cache local après modification
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setString(
                          'userData',
                          jsonEncode(updatedUserData),
                        );
                      }
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text("Modifier"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF03A6A1),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 48),
                      textStyle: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _showLogoutConfirmationDialog,
                    icon: const Icon(Icons.logout, color: Colors.red),
                    label: const Text("Déconnexion"),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.redAccent),
                      foregroundColor: Colors.red,
                      minimumSize: const Size(double.infinity, 48),
                      textStyle: const TextStyle(),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoTile(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
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

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic> userData;
  const EditProfileScreen({super.key, required this.userData});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController firstnameController;
  late TextEditingController lastnameController;
  late TextEditingController specialtyController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController cityController;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    firstnameController = TextEditingController(
      text: widget.userData['firstname'] ?? '',
    );
    lastnameController = TextEditingController(
      text: widget.userData['lastname'] ?? '',
    );
    specialtyController = TextEditingController(
      text: widget.userData['specialty'] ?? '',
    );
    emailController = TextEditingController(
      text: widget.userData['email'] ?? '',
    );
    phoneController = TextEditingController(
      text: widget.userData['phone'] ?? '',
    );
    cityController = TextEditingController(text: widget.userData['city'] ?? '');
  }

  @override
  void dispose() {
    firstnameController.dispose();
    lastnameController.dispose();
    specialtyController.dispose();
    emailController.dispose();
    phoneController.dispose();
    cityController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => isSaving = true);
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) return;
    final response = await http.put(
      Uri.parse('$apiBaseUrl/api/users/me'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'firstname': firstnameController.text.trim(),
        'lastname': lastnameController.text.trim(),
        'specialty': specialtyController.text.trim(),
        'email': emailController.text.trim(),
        'phone': phoneController.text.trim(),
        'city': cityController.text.trim(),
      }),
    );
    setState(() => isSaving = false);
    if (response.statusCode == 200) {
      if (mounted) {
        final updatedData = jsonDecode(response.body);
        Navigator.pop(context, updatedData);
      }
    } else {
      final errorData = jsonDecode(response.body);
      final message = errorData['message'] ?? 'Erreur lors de la sauvegarde.';
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Suppression de l'AppBar ici pour n'avoir qu'un seul AppBar sur la page principale
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: firstnameController,
                  decoration: const InputDecoration(labelText: 'Prénom'),
                  validator:
                      (value) =>
                          value == null || value.isEmpty
                              ? 'Champ requis'
                              : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: lastnameController,
                  decoration: const InputDecoration(labelText: 'Nom'),
                  validator:
                      (value) =>
                          value == null || value.isEmpty
                              ? 'Champ requis'
                              : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: specialtyController,
                  decoration: const InputDecoration(labelText: 'Spécialité'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Champ requis';
                    }
                    if (!RegExp(
                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                    ).hasMatch(value)) {
                      return 'Veuillez entrer un email valide';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: 'Téléphone'),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: cityController,
                  decoration: const InputDecoration(labelText: 'Ville'),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isSaving ? null : _save,
                    child:
                        isSaving
                            ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 3,
                              ),
                            )
                            : const Text('Enregistrer'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
