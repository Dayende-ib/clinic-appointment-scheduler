import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/doctor_appointment_service.dart';

const Color kPrimaryColor = Color(0xFF03A6A1);
const Color kSecondaryColor = Color(0xFF0891B2);
final Color kAccentColor = Colors.orange.shade600;
const Color kSoftRed = Color(0xFFDB6C6C);

class DoctorAppointmentsScreen extends StatefulWidget {
  final Map<String, dynamic>? arguments;

  const DoctorAppointmentsScreen({super.key, this.arguments});

  @override
  State<DoctorAppointmentsScreen> createState() =>
      _DoctorAppointmentsScreenState();
}

class _DoctorAppointmentsScreenState extends State<DoctorAppointmentsScreen> {
  List<Map<String, dynamic>> allAppointments = [];
  String filterStatus = 'All';
  String search = '';
  List<String> statusOptions = ['All', 'Upcoming', 'Completed', 'Cancelled'];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _applyInitialFilter();
    _loadAppointments();
  }

  void _applyInitialFilter() {
    if (widget.arguments != null && widget.arguments!['filter'] != null) {
      final filter = widget.arguments!['filter'] as String;
      switch (filter) {
        case 'today':
          filterStatus =
              'All'; // On garde 'All' pour voir tous les rendez-vous d'aujourd'hui
          break;
        case 'completed':
          filterStatus = 'Completed';
          break;
        case 'booked':
          filterStatus = 'Upcoming';
          break;
        case 'upcoming':
          filterStatus = 'Upcoming';
          break;
        case 'all':
        default:
          filterStatus = 'All';
          break;
      }
    }
  }

  Future<void> _loadAppointments() async {
    setState(() {
      isLoading = true;
      error = null;
    });
    try {
      final data = await DoctorAppointmentService.fetchDoctorAppointments();
      setState(() {
        allAppointments = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  void _showAppointmentDetails(Map<String, dynamic> appointment) {
    final patientDetails = appointment['patientDetails'] ?? {};
    final DateTime date = appointment['date'];
    final String status = appointment['originalStatus'] ?? '';
    final String reason = appointment['reason'] ?? '';
    final String patientName = appointment['patient'] ?? '';
    final String patientEmail = patientDetails['email'] ?? '';
    final String patientPhone = patientDetails['phone'] ?? '';
    final String patientNotes = appointment['notes']?['patientNotes'] ?? '';
    final String doctorNotes = appointment['notes']?['doctorNotes'] ?? '';
    final String aptId = appointment['id'] ?? '';

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
                          'Date: ${DateFormat('EEEE d MMMM yyyy', 'fr_FR').format(date)}',
                          'Heure: ${DateFormat('HH:mm').format(date)}',
                        ]),
                        const SizedBox(height: 20),
                        _buildDetailSection('👤 Informations patient', [
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
                          _buildDetailSection('📋 Mes notes', [doctorNotes]),
                        ],
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
                // Action buttons
                if (status == 'booked')
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              final success =
                                  await DoctorAppointmentService.rejectAppointment(
                                    aptId,
                                  );
                              if (success) {
                                Navigator.pop(context);
                                _loadAppointments();
                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Rendez-vous rejeté'),
                                    backgroundColor: kSoftRed,
                                  ),
                                );
                              } else {
                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Erreur lors du rejet'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kSoftRed,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              'Rejeter',
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
                            onPressed: () async {
                              final success =
                                  await DoctorAppointmentService.confirmAppointment(
                                    aptId,
                                  );
                              if (success) {
                                Navigator.pop(context);
                                _loadAppointments();
                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text('Rendez-vous confirmé'),
                                    backgroundColor: kPrimaryColor,
                                  ),
                                );
                              } else {
                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Erreur lors de la confirmation',
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kPrimaryColor,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              'Confirmer',
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

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (error != null) {
      return Center(
        child: Text(
          'Erreur: '
          '$error',
        ),
      );
    }
    List<Map<String, dynamic>> filtered =
        allAppointments.where((rdv) {
          final matchesStatus =
              filterStatus == 'All' || rdv['status'] == filterStatus;
          final matchesSearch =
              search.isEmpty ||
              (rdv['patient'] as String).toLowerCase().contains(
                search.toLowerCase(),
              );

          // Filtre spécial pour "today" - ne montrer que les rendez-vous d'aujourd'hui
          bool matchesToday = true;
          if (widget.arguments != null &&
              widget.arguments!['filter'] == 'today') {
            final today = DateTime.now();
            final appointmentDate = rdv['date'] as DateTime;
            matchesToday =
                appointmentDate.year == today.year &&
                appointmentDate.month == today.month &&
                appointmentDate.day == today.day;
          }

          return matchesStatus && matchesSearch && matchesToday;
        }).toList();
    filtered.sort(
      (a, b) => (a['date'] as DateTime).compareTo(b['date'] as DateTime),
    );

    String getTitle() {
      if (widget.arguments != null && widget.arguments!['filter'] != null) {
        final filter = widget.arguments!['filter'] as String;
        switch (filter) {
          case 'today':
            return 'Today\'s appointments';
          case 'completed':
            return 'Completed appointments';
          case 'booked':
            return 'Pending appointments';
          case 'upcoming':
            return 'Upcoming appointments';
          case 'all':
            return 'All my appointments';
          default:
            return 'My appointments';
        }
      }
      return 'My appointments';
    }

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Search for a patient...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    onChanged: (v) => setState(() => search = v),
                  ),
                ),
                const SizedBox(width: 12),
                DropdownButton<String>(
                  value: filterStatus,
                  items:
                      statusOptions
                          .map(
                            (s) => DropdownMenuItem(value: s, child: Text(s)),
                          )
                          .toList(),
                  onChanged: (v) => setState(() => filterStatus = v ?? 'All'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child:
                  filtered.isEmpty
                      ? const Center(child: Text('Aucun rendez-vous trouvé.'))
                      : ListView.separated(
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, i) {
                          final rdv = filtered[i];
                          final date = rdv['date'] as DateTime;
                          final status = rdv['status'] as String;
                          final originalStatus =
                              rdv['originalStatus'] as String;
                          Color statusColor;
                          switch (status) {
                            case 'Upcoming':
                              statusColor = Colors.teal;
                              break;
                            case 'Completed':
                              statusColor = Colors.green;
                              break;
                            case 'Cancelled':
                              statusColor = Colors.red;
                              break;
                            default:
                              statusColor = Colors.grey;
                          }
                          return Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: statusColor.withAlpha(
                                  (0.15 * 255).toInt(),
                                ),
                                child: Icon(Icons.person, color: statusColor),
                              ),
                              title: Text(
                                rdv['patient'],
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              subtitle: Text(
                                '${DateFormat('EEEE d MMMM', 'fr_FR').format(date)} à ${DateFormat('HH:mm').format(date)}',
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    status,
                                    style: TextStyle(
                                      color: statusColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (originalStatus == 'booked')
                                    TextButton(
                                      onPressed:
                                          () => _showAppointmentDetails(rdv),
                                      child: const Text('Détails'),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
