import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/admin_service.dart';

const Color kPrimaryColor = Color(0xFF03A6A1);
const Color kSecondaryColor = Color(0xFF0891B2);
final Color kAccentColor = Colors.orange.shade600;
const Color kSoftRed = Color(0xFFDB6C6C);
const Color kSuccessGreen = Color(0xFF10B981);
const Color kWarningYellow = Color(0xFFF59E0B);
const Color kPurple = Color(0xFF8B5CF6);

class AdminAppointmentsScreen extends StatefulWidget {
  final Map<String, dynamic>? arguments;

  const AdminAppointmentsScreen({super.key, this.arguments});

  @override
  State<AdminAppointmentsScreen> createState() =>
      _AdminAppointmentsScreenState();
}

class _AdminAppointmentsScreenState extends State<AdminAppointmentsScreen> {
  List<Map<String, dynamic>> appointments = [];
  bool isLoading = true;
  String? error;
  String searchQuery = '';
  String filterStatus = 'Tous';
  String filterType = 'Tous';

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final data = await AdminService.getAllAppointments();
      setState(() {
        appointments =
            data
                .map<Map<String, dynamic>>(
                  (apt) => {
                    ...apt,
                    'patientName':
                        ((apt['patientId']?['firstname'] ?? '') +
                                ' ' +
                                (apt['patientId']?['lastname'] ?? ''))
                            .trim(),
                    'doctorName':
                        ((apt['doctorId']?['firstname'] ?? '') +
                                ' ' +
                                (apt['doctorId']?['lastname'] ?? ''))
                            .trim(),
                    'patientEmail': apt['patientId']?['email'] ?? '',
                    'patientPhone': apt['patientId']?['phone'] ?? '',
                    'doctorEmail': apt['doctorId']?['email'] ?? '',
                    'doctorPhone': apt['doctorId']?['phone'] ?? '',
                    'date': apt['datetime'] ?? '',
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

  Future<void> _deleteAppointment(
    String appointmentId,
    String patientName,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirmer la suppression'),
            content: Text(
              'Êtes-vous sûr de vouloir supprimer le rendez-vous de "$patientName" ?',
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
        final success = await AdminService.deleteAppointment(appointmentId);
        if (success) {
          _loadAppointments();
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Rendez-vous supprimé'),
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

  void _showAppointmentDetails(Map<String, dynamic> appointment) {
    final patientDetails = appointment['patientDetails'] ?? {};
    final doctorDetails = appointment['doctorDetails'] ?? {};
    final dynamic dateRaw = appointment['date'];
    DateTime? date;
    if (dateRaw is DateTime) {
      date = dateRaw;
    } else if (dateRaw is String) {
      try {
        date = DateTime.parse(dateRaw);
      } catch (_) {
        date = null;
      }
    } else {
      date = null;
    }
    final String status = appointment['status'] ?? '';
    final String reason = appointment['reason'] ?? '';
    final String patientName = appointment['patientName'] ?? '';
    final String doctorName = appointment['doctorName'] ?? '';
    final String patientEmail = (patientDetails['email']) ?? '';
    final String patientPhone = (patientDetails['phone']) ?? '';
    final String doctorEmail = (doctorDetails['email']) ?? '';
    final String doctorPhone = (doctorDetails['phone']) ?? '';
    final String patientNotes = (appointment['notes']?['patientNotes']) ?? '';
    final String doctorNotes = (appointment['notes']?['doctorNotes']) ?? '';
    final String aptId = appointment['id']?.toString() ?? '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            height: MediaQuery.of(context).size.height * 0.85,
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
                        radius: 25,
                        backgroundColor: kAccentColor,
                        child: Text(
                          patientName.isNotEmpty ? patientName[0] : '?',
                          style: const TextStyle(
                            fontSize: 22,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              patientName,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1F2937),
                              ),
                            ),
                            Text(
                              'ID: $aptId',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _buildStatusChip(status),
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
                        _buildDetailSection('📅 Rendez-vous', [
                          '${date != null ? 'Date: ${DateFormat('EEEE d MMMM yyyy', 'fr_FR').format(date)}' : 'Date inconnue'}',
                          '${date != null ? 'Heure: ${DateFormat('HH:mm').format(date)}' : ''}',
                        ]),
                        const SizedBox(height: 20),
                        _buildDetailSection('👨‍⚕️ Docteur', [
                          'Nom: $doctorName',
                          'Email: $doctorEmail',
                          'Téléphone: $doctorPhone',
                        ]),
                        const SizedBox(height: 20),
                        _buildDetailSection('👤 Patient', [
                          'Nom: $patientName',
                          'Email: $patientEmail',
                          'Téléphone: $patientPhone',
                        ]),
                        const SizedBox(height: 20),
                        _buildDetailSection('💬 Motif de consultation', [
                          reason.isNotEmpty ? reason : 'Aucun motif spécifié',
                        ]),
                        if (patientNotes.isNotEmpty) ...[
                          const SizedBox(height: 20),
                          _buildDetailSection('📝 Notes du patient', [
                            patientNotes,
                          ]),
                        ],
                        if (doctorNotes.isNotEmpty) ...[
                          const SizedBox(height: 20),
                          _buildDetailSection('📋 Notes du docteur', [
                            doctorNotes,
                          ]),
                        ],
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
                            _deleteAppointment(aptId, patientName);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kSoftRed,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Supprimer',
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
                              '/admin/appointments/edit',
                              arguments: {'appointmentId': aptId},
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
                            'Modifier',
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

  Widget _buildStatusChip(String status) {
    Color bg, fg;
    String label;
    switch (status) {
      case 'confirmed':
        bg = const Color(0xFFDCFCE7);
        fg = const Color(0xFF166534);
        label = 'Confirmé';
        break;
      case 'booked':
        bg = const Color(0xFFFEF3C7);
        fg = const Color(0xFF92400E);
        label = 'En attente';
        break;
      case 'canceled':
        bg = const Color(0xFFFEE2E2);
        fg = const Color(0xFF991B1B);
        label = 'Annulé';
        break;
      case 'completed':
        bg = const Color(0xFFE0E7FF);
        fg = const Color(0xFF3730A3);
        label = 'Terminé';
        break;
      default:
        bg = const Color(0xFFFEF3C7);
        fg = const Color(0xFF92400E);
        label = status;
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }

  List<Map<String, dynamic>> get filteredAppointments {
    return appointments.where((appointment) {
      final matchesSearch =
          searchQuery.isEmpty ||
          ((appointment['patientName'] ?? '') as String).toLowerCase().contains(
            searchQuery.toLowerCase(),
          ) ||
          ((appointment['doctorName'] ?? '') as String).toLowerCase().contains(
            searchQuery.toLowerCase(),
          ) ||
          ((appointment['reason'] ?? '') as String).toLowerCase().contains(
            searchQuery.toLowerCase(),
          );

      final matchesStatus =
          filterStatus == 'Tous' ||
          (appointment['status'] ?? '') == filterStatus;

      final matchesType =
          filterType == 'Tous' ||
          (filterType == 'Aujourd\'hui' && _isToday(appointment['date'])) ||
          (filterType == 'Cette semaine' && _isThisWeek(appointment['date'])) ||
          (filterType == 'Ce mois' && _isThisMonth(appointment['date']));

      return matchesSearch && matchesStatus && matchesType;
    }).toList();
  }

  bool _isToday(dynamic dateRaw) {
    DateTime? date;
    if (dateRaw is DateTime) {
      date = dateRaw;
    } else if (dateRaw is String) {
      try {
        date = DateTime.parse(dateRaw);
      } catch (_) {
        return false;
      }
    } else {
      return false;
    }
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  bool _isThisWeek(dynamic dateRaw) {
    DateTime? date;
    if (dateRaw is DateTime) {
      date = dateRaw;
    } else if (dateRaw is String) {
      try {
        date = DateTime.parse(dateRaw);
      } catch (_) {
        return false;
      }
    } else {
      return false;
    }
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    return date.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
        date.isBefore(endOfWeek.add(const Duration(days: 1)));
  }

  bool _isThisMonth(dynamic dateRaw) {
    DateTime? date;
    if (dateRaw is DateTime) {
      date = dateRaw;
    } else if (dateRaw is String) {
      try {
        date = DateTime.parse(dateRaw);
      } catch (_) {
        return false;
      }
    } else {
      return false;
    }
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month;
  }

  String getTitle() {
    if (widget.arguments != null && widget.arguments!['filter'] != null) {
      final filter = widget.arguments!['filter'] as String;
      switch (filter) {
        case 'today':
          return 'Rendez-vous d\'aujourd\'hui';
        case 'pending':
          return 'Rendez-vous en attente';
        case 'all':
          return 'Tous les rendez-vous';
        default:
          return 'Gestion des rendez-vous';
      }
    }
    return 'Gestion des rendez-vous';
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
                onPressed: _loadAppointments,
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
        title: Text(
          getTitle(),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: kAccentColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAppointments,
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
                    hintText: 'Rechercher un rendez-vous...',
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
                    Expanded(
                      child: DropdownButton<String>(
                        value: filterStatus,
                        isExpanded: true,
                        hint: const Text('Statut'),
                        items:
                            [
                              'Tous',
                              'booked',
                              'confirmed',
                              'completed',
                              'canceled',
                            ].map((status) {
                              String label;
                              switch (status) {
                                case 'booked':
                                  label = 'En attente';
                                  break;
                                case 'confirmed':
                                  label = 'Confirmé';
                                  break;
                                case 'completed':
                                  label = 'Terminé';
                                  break;
                                case 'canceled':
                                  label = 'Annulé';
                                  break;
                                default:
                                  label = status;
                              }
                              return DropdownMenuItem(
                                value: status,
                                child: Text(label),
                              );
                            }).toList(),
                        onChanged:
                            (value) =>
                                setState(() => filterStatus = value ?? 'Tous'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButton<String>(
                        value: filterType,
                        isExpanded: true,
                        hint: const Text('Période'),
                        items:
                            [
                              'Tous',
                              'Aujourd\'hui',
                              'Cette semaine',
                              'Ce mois',
                            ].map((type) {
                              return DropdownMenuItem(
                                value: type,
                                child: Text(type),
                              );
                            }).toList(),
                        onChanged:
                            (value) =>
                                setState(() => filterType = value ?? 'Tous'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Appointments list
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadAppointments,
              child:
                  filteredAppointments.isEmpty
                      ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 64,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Aucun rendez-vous trouvé',
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
                        itemCount: filteredAppointments.length,
                        itemBuilder: (context, index) {
                          final appointment = filteredAppointments[index];
                          final dynamic dateRaw = appointment['date'];
                          DateTime? date;
                          if (dateRaw is DateTime) {
                            date = dateRaw;
                          } else if (dateRaw is String) {
                            try {
                              date = DateTime.parse(dateRaw);
                            } catch (_) {
                              date = null;
                            }
                          } else {
                            date = null;
                          }
                          final status = appointment['status'] ?? '';

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              leading: CircleAvatar(
                                radius: 25,
                                backgroundColor: kAccentColor,
                                child: Text(
                                  ((appointment['patientName'] ?? '') as String)
                                          .isNotEmpty
                                      ? ((appointment['patientName'] ?? '')
                                          as String)[0]
                                      : '?',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Text(
                                appointment['patientName'] ??
                                    'Nom patient inconnu',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Dr. ${appointment['doctorName'] ?? 'Nom médecin inconnu'}',
                                  ),
                                  Text(
                                    '${date != null ? '${DateFormat('EEEE d MMMM', 'fr_FR').format(date)} à ${DateFormat('HH:mm').format(date)}' : 'Date inconnue'}',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _buildStatusChip(status),
                                  const SizedBox(width: 8),
                                  PopupMenuButton<String>(
                                    onSelected: (value) {
                                      switch (value) {
                                        case 'details':
                                          _showAppointmentDetails(appointment);
                                          break;
                                        case 'delete':
                                          _deleteAppointment(
                                            appointment['id']?.toString() ?? '',
                                            appointment['patientName'] ?? '',
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
                              onTap: () => _showAppointmentDetails(appointment),
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
          // Navigation vers l'écran d'ajout de rendez-vous
          Navigator.pushNamed(context, '/admin/appointments/add');
        },
        backgroundColor: kAccentColor,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}
