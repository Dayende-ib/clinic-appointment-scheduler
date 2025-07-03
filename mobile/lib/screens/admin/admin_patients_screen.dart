import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/admin_service.dart';

const Color kPrimaryColor = Color(0xFF03A6A1);
const Color kSecondaryColor = Color(0xFF0891B2);
final Color kAccentColor = Colors.orange.shade600;
const Color kSoftRed = Color(0xFFDB6C6C);
const Color kSuccessGreen = Color(0xFF10B981);
const Color kWarningYellow = Color(0xFFF59E0B);

class AdminPatientsScreen extends StatefulWidget {
  const AdminPatientsScreen({super.key});

  @override
  State<AdminPatientsScreen> createState() => _AdminPatientsScreenState();
}

class _AdminPatientsScreenState extends State<AdminPatientsScreen> {
  List<Map<String, dynamic>> patients = [];
  bool isLoading = true;
  String? error;
  String searchQuery = '';
  String filterStatus = 'Tous';

  @override
  void initState() {
    super.initState();
    _loadPatients();
  }

  Future<void> _loadPatients() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final data = await AdminService.getAllPatients();
      setState(() {
        patients =
            data
                .map<Map<String, dynamic>>(
                  (p) => {
                    ...p,
                    'name':
                        ((p['firstname'] ?? '') + ' ' + (p['lastname'] ?? ''))
                            .trim(),
                    'email': p['email'] ?? '',
                    'phone': p['phone'] ?? '',
                    'active': p['isActive'] ?? true,
                  },
                )
                .toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> _togglePatientStatus(
    String patientId,
    bool currentStatus,
  ) async {
    try {
      final success = await AdminService.togglePatientStatus(
        patientId,
        !currentStatus,
      );
      if (success) {
        _loadPatients();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              currentStatus ? 'Patient désactivé' : 'Patient activé',
            ),
            backgroundColor: currentStatus ? kSoftRed : kSuccessGreen,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deletePatient(String patientId, String patientName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirmer la suppression'),
            content: Text(
              'Êtes-vous sûr de vouloir supprimer le patient "$patientName" ?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Annuler'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: kSoftRed),
                child: const Text('Supprimer'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      try {
        final success = await AdminService.deletePatient(patientId);
        if (success) {
          _loadPatients();
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Patient "$patientName" supprimé'),
              backgroundColor: kSuccessGreen,
            ),
          );
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showPatientDetails(Map<String, dynamic> patient) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            height: MediaQuery.of(context).size.height * 0.8,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                // Handle bar
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // Header
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: kSecondaryColor,
                        child: Text(
                          (patient['name'] ?? '')[0],
                          style: const TextStyle(
                            fontSize: 24,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              patient['name'] ?? 'Nom inconnu',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1F2937),
                              ),
                            ),
                            Text(
                              'Patient',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                      ),
                      _buildStatusChip(patient['active'] ?? false),
                    ],
                  ),
                ),
                // Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDetailSection('📧 Contact', [
                          'Email: ${patient['email'] ?? 'Non renseigné'}',
                          'Téléphone: ${patient['phone'] ?? 'Non renseigné'}',
                        ]),
                        const SizedBox(height: 20),
                        _buildDetailSection('👤 Informations personnelles', [
                          'Date de naissance: ${patient['dateOfBirth'] != null ? DateFormat('dd/MM/yyyy').format(DateTime.parse(patient['dateOfBirth'])) : 'Non renseigné'}',
                          'Genre: ${patient['gender'] ?? 'Non renseigné'}',
                          'Adresse: ${patient['address'] ?? 'Non renseigné'}',
                        ]),
                        const SizedBox(height: 20),
                        _buildDetailSection('🏥 Informations médicales', [
                          'Groupe sanguin: ${patient['bloodGroup'] ?? 'Non renseigné'}',
                          'Allergies: ${patient['allergies']?.join(', ') ?? 'Aucune'}',
                          'Antécédents: ${patient['medicalHistory'] ?? 'Aucun'}',
                        ]),
                        const SizedBox(height: 20),
                        _buildDetailSection('📅 Informations de compte', [
                          'Date d\'inscription: ${patient['createdAt'] != null ? DateFormat('dd/MM/yyyy').format(DateTime.parse(patient['createdAt'])) : 'Non renseigné'}',
                          'Dernière connexion: ${patient['lastLogin'] != null ? DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(patient['lastLogin'])) : 'Jamais'}',
                        ]),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
                // Action buttons
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.pushNamed(
                              context,
                              '/admin/patients/appointments',
                              arguments: {'patientId': patient['id']},
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kSecondaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Voir rendez-vous',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.pushNamed(
                              context,
                              '/admin/patients/history',
                              arguments: {'patientId': patient['id']},
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kAccentColor,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Historique médical',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildDetailSection(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 8),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              item,
              style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color:
            isActive
                ? kSuccessGreen.withValues(alpha: 0.1)
                : kSoftRed.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isActive ? kSuccessGreen : kSoftRed),
      ),
      child: Text(
        isActive ? 'Actif' : 'Inactif',
        style: TextStyle(
          color: isActive ? kSuccessGreen : kSoftRed,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  List<Map<String, dynamic>> get filteredPatients {
    return patients.where((patient) {
      final matchesSearch =
          searchQuery.isEmpty ||
          (patient['name'] ?? '').toLowerCase().contains(
            searchQuery.toLowerCase(),
          ) ||
          (patient['email'] as String).toLowerCase().contains(
            searchQuery.toLowerCase(),
          ) ||
          (patient['phone'] as String).toLowerCase().contains(
            searchQuery.toLowerCase(),
          );

      final matchesFilter =
          filterStatus == 'Tous' ||
          (filterStatus == 'Actifs' && patient['active'] == true) ||
          (filterStatus == 'Inactifs' && patient['active'] == false);

      return matchesSearch && matchesFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF9FAFB),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (error != null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF9FAFB),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Erreur: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadPatients,
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text(
          'Gestion des Patients',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: kSecondaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPatients,
            tooltip: 'Actualiser',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and filter bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Rechercher un patient...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF9FAFB),
                  ),
                  onChanged: (value) => setState(() => searchQuery = value),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text(
                      'Filtre: ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 8),
                    DropdownButton<String>(
                      value: filterStatus,
                      items:
                          ['Tous', 'Actifs', 'Inactifs'].map((status) {
                            return DropdownMenuItem(
                              value: status,
                              child: Text(status),
                            );
                          }).toList(),
                      onChanged:
                          (value) =>
                              setState(() => filterStatus = value ?? 'Tous'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Patients list
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadPatients,
              child:
                  filteredPatients.isEmpty
                      ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.people, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              'Aucun patient trouvé',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      )
                      : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredPatients.length,
                        itemBuilder: (context, index) {
                          final patient = filteredPatients[index];
                          final isActive = patient['active'] ?? false;

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              leading: CircleAvatar(
                                radius: 25,
                                backgroundColor: kSecondaryColor,
                                child: Text(
                                  (patient['name'] ?? '')[0],
                                  style: const TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Text(
                                patient['name'] ?? 'Nom inconnu',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    patient['email'] ?? 'Email non renseigné',
                                  ),
                                  Text(
                                    patient['phone'] ??
                                        'Téléphone non renseigné',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _buildStatusChip(isActive),
                                  const SizedBox(width: 8),
                                  PopupMenuButton<String>(
                                    onSelected: (value) {
                                      switch (value) {
                                        case 'details':
                                          _showPatientDetails(patient);
                                          break;
                                        case 'toggle':
                                          _togglePatientStatus(
                                            patient['id'],
                                            isActive,
                                          );
                                          break;
                                        case 'delete':
                                          _deletePatient(
                                            patient['id'],
                                            patient['name'],
                                          );
                                          break;
                                      }
                                    },
                                    itemBuilder:
                                        (context) => [
                                          const PopupMenuItem(
                                            value: 'details',
                                            child: Row(
                                              children: [
                                                Icon(Icons.info_outline),
                                                SizedBox(width: 8),
                                                Text('Détails'),
                                              ],
                                            ),
                                          ),
                                          PopupMenuItem(
                                            value: 'toggle',
                                            child: Row(
                                              children: [
                                                Icon(
                                                  isActive
                                                      ? Icons.block
                                                      : Icons.check_circle,
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  isActive
                                                      ? 'Désactiver'
                                                      : 'Activer',
                                                ),
                                              ],
                                            ),
                                          ),
                                          const PopupMenuItem(
                                            value: 'delete',
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.delete,
                                                  color: kSoftRed,
                                                ),
                                                SizedBox(width: 8),
                                                Text(
                                                  'Supprimer',
                                                  style: TextStyle(
                                                    color: kSoftRed,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                  ),
                                ],
                              ),
                              onTap: () => _showPatientDetails(patient),
                            ),
                          );
                        },
                      ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigation vers l'écran d'ajout de patient
          Navigator.pushNamed(context, '/admin/patients/add');
        },
        backgroundColor: kSecondaryColor,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}
