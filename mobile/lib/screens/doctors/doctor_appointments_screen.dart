import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/doctor_appointment_service.dart';
import 'package:caretime/strings.dart';

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
  final List<String> statusOptions = [
    'All',
    'Upcoming',
    'Completed',
    'Cancelled',
  ];
  final Map<String, String> statusLabels = {
    'All': AppStrings.doctorFilterAll,
    'Upcoming': AppStrings.doctorFilterUpcoming,
    'Completed': AppStrings.doctorFilterCompleted,
    'Cancelled': AppStrings.doctorFilterCancelled,
  };
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
          filterStatus = 'All';
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
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
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
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDetailSection(AppStrings.doctorAppointmentSection, [
                          '${AppStrings.patientDateLabel}: ${DateFormat('EEEE d MMMM yyyy', 'fr_FR').format(date)}',
                          '${AppStrings.patientTimeLabel}: ${DateFormat('HH:mm').format(date)}',
                        ]),
                        const SizedBox(height: 20),
                        _buildDetailSection(
                          AppStrings.doctorPatientInfoSection,
                          [
                            '${AppStrings.emailLabel}: $patientEmail',
                            '${AppStrings.phone}: $patientPhone',
                          ],
                        ),
                        const SizedBox(height: 20),
                        _buildDetailSection(AppStrings.doctorReasonSection, [
                          reason.isNotEmpty
                              ? reason
                              : AppStrings.doctorNoReasonSpecified,
                        ]),
                        if (patientNotes.isNotEmpty) ...[
                          const SizedBox(height: 20),
                          _buildDetailSection(
                            AppStrings.doctorPatientNotes,
                            [patientNotes],
                          ),
                        ],
                        if (doctorNotes.isNotEmpty) ...[
                          const SizedBox(height: 20),
                          _buildDetailSection(
                            AppStrings.doctorDoctorNotes,
                            [doctorNotes],
                          ),
                        ],
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
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
                                    content: Text(
                                      AppStrings.doctorAppointmentRejected,
                                    ),
                                    backgroundColor: kSoftRed,
                                  ),
                                );
                              } else {
                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(AppStrings.doctorErrorReject),
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
                              AppStrings.doctorReject,
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
                                  const SnackBar(
                                    content: Text(
                                      AppStrings.doctorAppointmentConfirmed,
                                    ),
                                    backgroundColor: kPrimaryColor,
                                  ),
                                );
                              } else {
                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      AppStrings.doctorErrorConfirm,
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
                              AppStrings.doctorConfirm,
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
        label = AppStrings.patientStatusConfirmed;
        break;
      case 'booked':
        bg = const Color(0xFFFEF3C7);
        fg = const Color(0xFF92400E);
        label = AppStrings.patientStatusPending;
        break;
      case 'canceled':
        bg = const Color(0xFFFEE2E2);
        fg = const Color(0xFF991B1B);
        label = AppStrings.patientStatusCancelled;
        break;
      case 'completed':
        bg = const Color(0xFFE0E7FF);
        fg = const Color(0xFF3730A3);
        label = AppStrings.patientStatusCompleted;
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
      return Center(child: Text('${AppStrings.errorPrefix}$error'));
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
                      hintText: AppStrings.doctorSearchPatientHint,
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
                            (s) => DropdownMenuItem(
                              value: s,
                              child: Text(statusLabels[s] ?? s),
                            ),
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
                      ? const Center(
                        child: Text(AppStrings.doctorNoAppointmentsFound),
                      )
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
                              trailing: SizedBox(
                                width: 80,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        statusLabels[status] ?? status,
                                        style: TextStyle(
                                          color: statusColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                        textAlign: TextAlign.center,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (originalStatus == 'booked')
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          top: 2.0,
                                        ),
                                        child: SizedBox(
                                          height: 24,
                                          child: TextButton(
                                            onPressed:
                                                () => _showAppointmentDetails(
                                                  rdv,
                                                ),
                                            style: TextButton.styleFrom(
                                              padding: EdgeInsets.zero,
                                              minimumSize: Size.zero,
                                              tapTargetSize:
                                                  MaterialTapTargetSize
                                                      .shrinkWrap,
                                            ),
                                            child: const Text(
                                              AppStrings.doctorDetails,
                                              style: TextStyle(fontSize: 11),
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              onTap: () => _showAppointmentDetails(rdv),
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
