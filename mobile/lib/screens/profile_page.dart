import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:caretime/api_config.dart';

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
          const SnackBar(
            content: Text('Error fetching user data. Please try again.'),
          ),
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
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Connexion error : $e')));
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
          title: const Text('Logout'),
          content: const Text('Are you sure you want to log out?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: const Text('Yes, Logout'),
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
              Text('Profile loading...'),
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
              const Text('Error fetching user data.'),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _fetchUserData,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
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
    final String role = userData!['role'] ?? '';
    final bool isDoctor = role == 'doctor';
    final bool isPatient = role == 'patient';
    // Gestion de l'indicatif pays pour le téléphone
    String phone = userData!['phone'] ?? '';
    String countryCode = '';
    String phoneNumber = phone;
    final RegExp phoneReg = RegExp(r'^(\+\d{1,3})\s?(.*)');
    final match = phoneReg.firstMatch(phone);
    if (match != null) {
      countryCode = match.group(1) ?? '';
      phoneNumber = match.group(2) ?? '';
    }
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
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
                    if (isDoctor)
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
                      "Phone",
                      countryCode.isNotEmpty
                          ? '$countryCode $phoneNumber'
                          : phone,
                    ),
                    const Divider(),
                    _infoTile(
                      Icons.location_city,
                      "City",
                      userData!['city'] ?? '',
                    ),
                    const Divider(),
                    _infoTile(
                      Icons.flag,
                      "Country",
                      userData!['country'] ?? '',
                    ),
                    if (isPatient) ...[
                      const Divider(),
                      _infoTile(
                        Icons.cake,
                        "Date of birth",
                        (userData!['dateOfBirth'] != null &&
                                userData!['dateOfBirth'].toString().isNotEmpty)
                            ? userData!['dateOfBirth'].toString().substring(
                              0,
                              10,
                            )
                            : '',
                      ),
                    ],
                    if (isDoctor) ...[
                      const Divider(),
                      _infoTile(
                        Icons.badge,
                        "License number",
                        userData!['licenseNumber'] ?? '',
                      ),
                    ],
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
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setString(
                          'userData',
                          jsonEncode(updatedUserData),
                        );
                      }
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text("Edit Profile"),
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
                    label: const Text("Logout"),
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
  late TextEditingController phoneController;
  bool isSaving = false;
  late String selectedCountry;
  late String selectedCity;
  late DateTime? selectedBirthDate;

  // Liste des pays d'Afrique de l'Ouest et quelques grandes villes
  static const List<String> countryList = [
    'Bénin',
    'Burkina Faso',
    'Cap-Vert',
    'Côte d\'Ivoire',
    'Gambie',
    'Ghana',
    'Guinée',
    'Guinée-Bissau',
    'Libéria',
    'Mali',
    'Niger',
    'Nigeria',
    'Sénégal',
    'Sierra Leone',
    'Togo',
    'Autre',
  ];
  static const Map<String, List<String>> cityMap = {
    'Bénin': ['Cotonou', 'Porto-Novo', 'Parakou', 'Bohicon', 'Kandi', 'Autre'],
    'Burkina Faso': [
      'Ouagadougou',
      'Bobo-Dioulasso',
      'Koudougou',
      'Ouahigouya',
      'Fada N\'Gourma',
      'Autre',
    ],
    'Cap-Vert': ['Praia', 'Mindelo', 'Santa Maria', 'Assomada', 'Autre'],
    'Côte d\'Ivoire': [
      'Abidjan',
      'Bouaké',
      'Yamoussoukro',
      'Daloa',
      'San Pedro',
      'Autre',
    ],
    'Gambie': ['Banjul', 'Serekunda', 'Brikama', 'Bakau', 'Autre'],
    'Ghana': ['Accra', 'Kumasi', 'Tamale', 'Takoradi', 'Autre'],
    'Guinée': ['Conakry', 'Labé', 'Kankan', 'Kindia', 'Autre'],
    'Guinée-Bissau': ['Bissau', 'Bafatá', 'Gabú', 'Bissorã', 'Autre'],
    'Libéria': ['Monrovia', 'Gbarnga', 'Kakata', 'Bensonville', 'Autre'],
    'Mali': ['Bamako', 'Sikasso', 'Kayes', 'Mopti', 'Autre'],
    'Niger': ['Niamey', 'Zinder', 'Maradi', 'Tahoua', 'Autre'],
    'Nigeria': ['Lagos', 'Abuja', 'Kano', 'Ibadan', 'Port Harcourt', 'Autre'],
    'Sénégal': ['Dakar', 'Thiès', 'Kaolack', 'Saint-Louis', 'Autre'],
    'Sierra Leone': ['Freetown', 'Bo', 'Kenema', 'Makeni', 'Autre'],
    'Togo': ['Lomé', 'Sokodé', 'Kara', 'Atakpamé', 'Autre'],
    'Autre': ['Autre'],
  };

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
    phoneController = TextEditingController(
      text: widget.userData['phone'] ?? '',
    );
    selectedCountry = widget.userData['country'] ?? countryList.first;
    final cities = cityMap[selectedCountry] ?? ['Autre'];
    selectedCity =
        cities.contains(widget.userData['city'])
            ? widget.userData['city']
            : cities.first;
    // Date d'anniversaire
    if (widget.userData['dateOfBirth'] != null &&
        widget.userData['dateOfBirth'].toString().isNotEmpty) {
      try {
        selectedBirthDate = DateTime.parse(widget.userData['dateOfBirth']);
      } catch (_) {
        selectedBirthDate = null;
      }
    } else {
      selectedBirthDate = null;
    }
  }

  @override
  void dispose() {
    firstnameController.dispose();
    lastnameController.dispose();
    specialtyController.dispose();
    phoneController.dispose();
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
    final Map<String, dynamic> dataToSend = {
      'firstname': firstnameController.text.trim(),
      'lastname': lastnameController.text.trim(),
      'specialty': specialtyController.text.trim(),
      'phone': phoneController.text.trim(),
      'city': selectedCity,
      'country': selectedCountry,
      'dateOfBirth':
          selectedBirthDate != null
              ? selectedBirthDate!.toUtc().toIso8601String()
              : '',
    };
    final response = await http.put(
      Uri.parse('$apiBaseUrl/api/users/me'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(dataToSend),
    );
    setState(() => isSaving = false);
    if (response.statusCode == 200) {
      if (mounted) {
        final updatedData = jsonDecode(response.body);
        Navigator.pop(context, updatedData);
      }
    } else {
      final errorData = jsonDecode(response.body);
      final message = errorData['message'] ?? 'An error occurred while saving.';
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final String role = widget.userData['role'] ?? '';
    final bool isDoctor = role == 'doctor';
    final List<String> cities = cityMap[selectedCountry] ?? ['Autre'];
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          'Edit profile',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF0891B2),
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: firstnameController,
                  decoration: const InputDecoration(labelText: 'First name'),
                  validator:
                      (value) =>
                          value == null || value.isEmpty
                              ? 'Required field'
                              : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: lastnameController,
                  decoration: const InputDecoration(labelText: 'Last name'),
                  validator:
                      (value) =>
                          value == null || value.isEmpty
                              ? 'Required field'
                              : null,
                ),
                const SizedBox(height: 12),
                if (isDoctor)
                  TextFormField(
                    controller: specialtyController,
                    decoration: const InputDecoration(labelText: 'Specialty'),
                  ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: 'Phone'),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),
                // Sélecteur de date d'anniversaire
                GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedBirthDate ?? DateTime(2000, 1, 1),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setState(() => selectedBirthDate = picked);
                    }
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: "Date of birth",
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          selectedBirthDate != null
                              ? "${selectedBirthDate!.year.toString().padLeft(4, '0')}-${selectedBirthDate!.month.toString().padLeft(2, '0')}-${selectedBirthDate!.day.toString().padLeft(2, '0')}"
                              : 'Select...',
                          style: TextStyle(
                            color:
                                selectedBirthDate != null
                                    ? Colors.black87
                                    : Colors.grey[600],
                          ),
                        ),
                        const Icon(Icons.cake, color: Color(0xFF0891B2)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedCountry,
                  decoration: const InputDecoration(labelText: 'Country'),
                  items:
                      countryList
                          .map(
                            (c) => DropdownMenuItem(value: c, child: Text(c)),
                          )
                          .toList(),
                  onChanged: (val) {
                    if (val != null && val != selectedCountry) {
                      setState(() {
                        selectedCountry = val;
                        final newCities = cityMap[selectedCountry] ?? ['Autre'];
                        selectedCity = newCities.first;
                      });
                    }
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedCity,
                  decoration: const InputDecoration(labelText: 'City'),
                  items:
                      cities
                          .map(
                            (c) => DropdownMenuItem(value: c, child: Text(c)),
                          )
                          .toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => selectedCity = val);
                  },
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
                            : const Text('Save Profile'),
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
