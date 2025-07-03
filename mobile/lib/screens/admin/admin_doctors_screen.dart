import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/admin_service.dart';

const Color kPrimaryColor = Color(0xFF03A6A1);
const Color kSecondaryColor = Color(0xFF0891B2);
final Color kAccentColor = Colors.orange.shade600;
const Color kSoftRed = Color(0xFFDB6C6C);
const Color kSuccessGreen = Color(0xFF10B981);
const Color kWarningYellow = Color(0xFFF59E0B);

class AdminDoctorsScreen extends StatefulWidget {
  const AdminDoctorsScreen({super.key});

  @override
  State<AdminDoctorsScreen> createState() => _AdminDoctorsScreenState();
}

class _AdminDoctorsScreenState extends State<AdminDoctorsScreen> {
  List<Map<String, dynamic>> doctors = [];
  bool isLoading = true;
  String? error;
  String searchQuery = '';
  String filterStatus = 'Tous';

  @override
  void initState() {
    super.initState();
    _loadDoctors();
  }

  Future<void> _loadDoctors() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final data = await AdminService.getAllDoctors();
      setState(() {
        doctors = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> _toggleDoctorStatus(String doctorId, bool currentStatus) async {
    try {
      final success = await AdminService.toggleDoctorStatus(
        doctorId,
        !currentStatus,
      );
      if (success) {
        _loadDoctors();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              currentStatus ? 'Docteur désactivé' : 'Docteur activé',
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

  Future<void> _deleteDoctor(String doctorId, String doctorName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirmer la suppression'),
            content: Text(
              'Êtes-vous sûr de vouloir supprimer le docteur "$doctorName" ?',
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
        final success = await AdminService.deleteDoctor(doctorId);
        if (success) {
          _loadDoctors();
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Docteur "$doctorName" supprimé'),
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

  void _showDoctorDetails(Map<String, dynamic> doctor) {
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
                        backgroundColor: kPrimaryColor,
                        child: Text(
                          (doctor['name'] as String).isNotEmpty
                              ? (doctor['name'] as String)[0]
                              : '?',
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
                              doctor['name'] ?? 'Nom inconnu',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1F2937),
                              ),
                            ),
                            Text(
                              doctor['specialization'] ??
                                  'Spécialisation non définie',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                      ),
                      _buildStatusChip(doctor['active'] ?? false),
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
                          'Email: ${doctor['email'] ?? 'Non renseigné'}',
                          'Téléphone: ${doctor['phone'] ?? 'Non renseigné'}',
                        ]),
                        const SizedBox(height: 20),
                        _buildDetailSection('🏥 Informations professionnelles', [
                          'Spécialisation: ${doctor['specialization'] ?? 'Non définie'}',
                          'Numéro de licence: ${doctor['licenseNumber'] ?? 'Non renseigné'}',
                          'Années d\'expérience: ${doctor['experienceYears'] ?? 'Non renseigné'}',
                        ]),
                        const SizedBox(height: 20),
                        _buildDetailSection('📅 Horaires de travail', [
                          'Lundi - Vendredi: ${doctor['workingHours']?['weekdays'] ?? 'Non défini'}',
                          'Samedi: ${doctor['workingHours']?['saturday'] ?? 'Non défini'}',
                          'Dimanche: ${doctor['workingHours']?['sunday'] ?? 'Non défini'}',
                        ]),
                        const SizedBox(height: 20),
                        _buildDetailSection('💰 Tarifs', [
                          'Consultation: ${doctor['pricing']?['consultation'] ?? 'Non défini'}',
                          'Suivi: ${doctor['pricing']?['followUp'] ?? 'Non défini'}',
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
                              '/admin/doctors/appointments',
                              arguments: {'doctorId': doctor['id']},
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kPrimaryColor,
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
                              '/admin/doctors/schedule',
                              arguments: {'doctorId': doctor['id']},
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
                            'Voir planning',
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

  List<Map<String, dynamic>> get filteredDoctors {
    return doctors.where((doctor) {
      final matchesSearch =
          searchQuery.isEmpty ||
          (doctor['name'] as String).toLowerCase().contains(
            searchQuery.toLowerCase(),
          ) ||
          (doctor['specialization'] as String).toLowerCase().contains(
            searchQuery.toLowerCase(),
          ) ||
          (doctor['email'] as String).toLowerCase().contains(
            searchQuery.toLowerCase(),
          );

      final matchesFilter =
          filterStatus == 'Tous' ||
          (filterStatus == 'Actifs' && doctor['active'] == true) ||
          (filterStatus == 'Inactifs' && doctor['active'] == false);

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
                onPressed: _loadDoctors,
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
          'Gestion des Docteurs',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: kPrimaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDoctors,
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
                    hintText: 'Rechercher un docteur...',
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
          // Doctors list
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadDoctors,
              child:
                  filteredDoctors.isEmpty
                      ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.medical_services,
                              size: 64,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Aucun docteur trouvé',
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
                        itemCount: filteredDoctors.length,
                        itemBuilder: (context, index) {
                          final doctor = filteredDoctors[index];
                          final isActive = doctor['active'] ?? false;

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              leading: CircleAvatar(
                                radius: 25,
                                backgroundColor: kPrimaryColor,
                                child: Text(
                                  (doctor['name'] as String).isNotEmpty
                                      ? (doctor['name'] as String)[0]
                                      : '?',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Text(
                                doctor['name'] ?? 'Nom inconnu',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    doctor['specialization'] ??
                                        'Spécialisation non définie',
                                  ),
                                  Text(
                                    doctor['email'] ?? 'Email non renseigné',
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
                                          _showDoctorDetails(doctor);
                                          break;
                                        case 'toggle':
                                          _toggleDoctorStatus(
                                            doctor['id'],
                                            isActive,
                                          );
                                          break;
                                        case 'delete':
                                          _deleteDoctor(
                                            doctor['id'],
                                            doctor['name'],
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
                              onTap: () => _showDoctorDetails(doctor),
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
          // Navigation vers l'écran d'ajout de docteur
          Navigator.pushNamed(context, '/admin/doctors/add');
        },
        backgroundColor: kPrimaryColor,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}
