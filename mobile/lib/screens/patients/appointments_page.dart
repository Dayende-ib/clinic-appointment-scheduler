import 'package:flutter/material.dart';
import '../../services/patient_api_service.dart';

const Color kPrimaryColor = Color(0xFF03A6A1);
const Color kSecondaryColor = Color(0xFF0891B2);
final Color kAccentColor = Colors.orange.shade600;
const Color kSoftRed = Color(0xFFDB6C6C);

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  String selectedFilter = 'all';
  List<Map<String, dynamic>> appointments = [];
  bool isLoading = true;
  String? error;
  Set<String> deletedAppointments = {};

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
      final data = await PatientApiService.getMyAppointments();
      setState(() {
        appointments = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> _cancelAppointment(String appointmentId) async {
    final success = await PatientApiService.cancelAppointment(appointmentId);
    if (success) {
      await _loadAppointments();
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Appointment canceled.')));
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error while canceling appointment.')),
      );
    }
  }

  List<Appointment> get filteredAppointments {
    if (selectedFilter == 'all') {
      return appointments.map((e) => Appointment.fromMap(e)).toList();
    }
    return appointments
        .where((apt) => apt['type'] == selectedFilter)
        .map((e) => Appointment.fromMap(e))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (error != null) {
      return Center(child: Text('Erreur: $error'));
    }
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
        itemCount: appointments.length,
        itemBuilder: (context, index) {
          final apt = appointments[index];
          if (deletedAppointments.contains(apt['_id'] ?? apt['id'])) {
            return const SizedBox.shrink();
          }
          final doctor = apt['doctorId'] ?? {};
          final patient = apt['patientId'] ?? {};
          final DateTime? dt =
              apt['datetime'] != null
                  ? DateTime.tryParse(apt['datetime'])
                  : null;
          final String dateStr =
              dt != null
                  ? '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}'
                  : '';
          final String timeStr =
              dt != null
                  ? '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}'
                  : '';
          final String status = (apt['status'] ?? '').toString();
          final String reason = apt['reason'] ?? '';
          final String doctorName =
              (doctor['firstname'] ?? '') + ' ' + (doctor['lastname'] ?? '');
          final String specialty = doctor['specialty'] ?? '';
          final String aptId = apt['_id'] ?? apt['id'] ?? '';
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border(
                left: BorderSide(color: _getStatusColor(status), width: 4),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: kAccentColor,
                        child: Text(
                          doctorName.isNotEmpty ? doctorName[0] : '?',
                          style: const TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              doctorName.isNotEmpty
                                  ? doctorName
                                  : 'Docteur inconnu',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1F2937),
                              ),
                            ),
                            Text(
                              specialty,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                        tooltip: 'Supprimer',
                        onPressed: () {
                          setState(() {
                            deletedAppointments.add(aptId);
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Rendez-vous supprimé de la liste.',
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildMetaRow('📅', dateStr),
                          _buildMetaRow('🕙', timeStr),
                          _buildMetaRow('💬', reason),
                        ],
                      ),
                      _buildStatusBadge(status),
                    ],
                  ),
                  if (status == 'booked')
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        children: const [
                          Icon(
                            Icons.info_outline,
                            color: Colors.orange,
                            size: 18,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'En attente de validation du médecin',
                            style: TextStyle(
                              color: Colors.orange,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (status == 'booked' || status == 'confirmed')
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton.icon(
                          icon: const Icon(
                            Icons.info_outline,
                            color: kSecondaryColor,
                          ),
                          label: const Text(
                            'Détails',
                            style: TextStyle(color: kSecondaryColor),
                          ),
                          onPressed: () => _showAppointmentDetails(apt),
                        ),
                        const SizedBox(width: 8),
                        TextButton.icon(
                          icon: const Icon(
                            Icons.calendar_today,
                            color: kSecondaryColor,
                          ),
                          label: const Text(
                            'Reprogrammer',
                            style: TextStyle(color: kSecondaryColor),
                          ),
                          onPressed: () async {
                            final pickedDate = await showDatePicker(
                              context: context,
                              initialDate: dt ?? DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(
                                const Duration(days: 365),
                              ),
                            );
                            if (pickedDate == null) return;
                            final pickedTime = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.fromDateTime(
                                dt ?? DateTime.now(),
                              ),
                            );
                            if (pickedTime == null) return;
                            final newDateTime = DateTime(
                              pickedDate.year,
                              pickedDate.month,
                              pickedDate.day,
                              pickedTime.hour,
                              pickedTime.minute,
                            );
                            final iso = newDateTime.toIso8601String();
                            final success =
                                await PatientApiService.rescheduleAppointment(
                                  aptId,
                                  iso,
                                );
                            if (!mounted) return;
                            if (success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Rendez-vous reprogrammé !'),
                                ),
                              );
                              _loadAppointments();
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Erreur lors de la reprogrammation.',
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                        const SizedBox(width: 8),
                        TextButton.icon(
                          icon: const Icon(Icons.cancel, color: kSoftRed),
                          label: const Text(
                            'Annuler',
                            style: TextStyle(color: kSoftRed),
                          ),
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder:
                                  (context) => AlertDialog(
                                    title: const Text(
                                      'Annuler ce rendez-vous ?',
                                    ),
                                    content: const Text(
                                      'Cette action est irréversible.',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed:
                                            () => Navigator.pop(context, false),
                                        child: const Text('Non'),
                                      ),
                                      TextButton(
                                        onPressed:
                                            () => Navigator.pop(context, true),
                                        child: const Text('Oui, annuler'),
                                      ),
                                    ],
                                  ),
                            );
                            if (confirm == true) {
                              await PatientApiService.cancelAppointment(aptId);
                              _loadAppointments();
                            }
                          },
                        ),
                      ],
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMetaRow(String icon, String text) {
    return Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 12)),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg, fg;
    String label;
    switch (status) {
      case 'confirmed':
        bg = const Color(0xFFDCFCE7);
        fg = const Color(0xFF166534);
        label = 'Confirmed';
        break;
      case 'pending':
        bg = const Color(0xFFFEF3C7);
        fg = const Color(0xFF92400E);
        label = 'Pending';
        break;
      case 'canceled':
        bg = const Color(0xFFFEE2E2);
        fg = const Color(0xFF991B1B);
        label = 'Cancelled';
        break;
      case 'completed':
        bg = const Color(0xFFE0E7FF);
        fg = const Color(0xFF3730A3);
        label = 'Completed';
        break;
      default:
        bg = const Color(0xFFFEF3C7);
        fg = const Color(0xFF92400E);
        label = status;
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'confirmed':
        return const Color(0xFF10B981);
      case 'pending':
        return kSecondaryColor;
      case 'canceled':
        return kSoftRed;
      case 'completed':
        return kAccentColor;
      default:
        return kSecondaryColor;
    }
  }

  void _showAppointmentDetails(Map<String, dynamic> appointment) {
    final doctor = appointment['doctorId'] ?? {};
    final patient = appointment['patientId'] ?? {};
    final DateTime? dt =
        appointment['datetime'] != null
            ? DateTime.tryParse(appointment['datetime'])
            : null;
    final String dateStr =
        dt != null
            ? '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}'
            : '';
    final String timeStr =
        dt != null
            ? '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}'
            : '';
    final String status = (appointment['status'] ?? '').toString();
    final String reason = appointment['reason'] ?? '';
    final String doctorName =
        (doctor['firstname'] ?? '') + ' ' + (doctor['lastname'] ?? '');
    final String specialty = doctor['specialty'] ?? '';
    final String doctorEmail = doctor['email'] ?? '';
    final String doctorPhone = doctor['phone'] ?? '';
    final String patientNotes = appointment['notes']?['patientNotes'] ?? '';
    final String doctorNotes = appointment['notes']?['doctorNotes'] ?? '';
    final String aptId = appointment['_id'] ?? appointment['id'] ?? '';

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: kAccentColor,
                  child: Text(
                    doctorName.isNotEmpty ? doctorName[0] : '?',
                    style: const TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Détails du rendez-vous',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
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
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildDetailSection('👨‍⚕️ Médecin', [
                    'Nom: $doctorName',
                    'Spécialité: $specialty',
                    'Email: $doctorEmail',
                    'Téléphone: $doctorPhone',
                  ]),
                  const SizedBox(height: 16),
                  _buildDetailSection('📅 Rendez-vous', [
                    'Date: $dateStr',
                    'Heure: $timeStr',
                    'Statut: ${_getStatusLabel(status)}',
                  ]),
                  const SizedBox(height: 16),
                  _buildDetailSection('💬 Motif', [
                    reason.isNotEmpty ? reason : 'Aucun motif spécifié',
                  ]),
                  if (patientNotes.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _buildDetailSection('📝 Notes patient', [patientNotes]),
                  ],
                  if (doctorNotes.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _buildDetailSection('📋 Notes médecin', [doctorNotes]),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Fermer'),
              ),
            ],
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
            fontWeight: FontWeight.w600,
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

  String _getStatusLabel(String status) {
    switch (status) {
      case 'confirmed':
        return 'Confirmé';
      case 'pending':
        return 'En attente';
      case 'canceled':
        return 'Annulé';
      case 'completed':
        return 'Terminé';
      case 'booked':
        return 'Réservé (en attente de validation)';
      default:
        return status;
    }
  }
}

class Appointment {
  final String id;
  final String doctorName;
  final String specialty;
  final String date;
  final String time;
  final AppointmentStatus status;
  final AppointmentType type;
  final String avatar;

  Appointment({
    required this.id,
    required this.doctorName,
    required this.specialty,
    required this.date,
    required this.time,
    required this.status,
    required this.type,
    required this.avatar,
  });

  factory Appointment.fromMap(Map<String, dynamic> map) {
    return Appointment(
      id: map['id'],
      doctorName: map['doctorName'],
      specialty: map['specialty'],
      date: map['date'],
      time: map['time'],
      status: AppointmentStatus.values[map['status']],
      type: AppointmentType.values[map['type']],
      avatar: map['avatar'],
    );
  }
}

enum AppointmentStatus { confirmed, pending, cancelled, completed }

enum AppointmentType { upcoming, past, cancelled }
