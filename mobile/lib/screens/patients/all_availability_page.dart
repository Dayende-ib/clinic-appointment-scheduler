import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/doctor_availability_service.dart';
import '../../services/patient_api_service.dart';
import 'doctor_profile_page.dart';
import 'doctor_list_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AllAvailabilityPage extends StatefulWidget {
  const AllAvailabilityPage({super.key});

  @override
  State<AllAvailabilityPage> createState() => _AllAvailabilityPageState();
}

class _AllAvailabilityPageState extends State<AllAvailabilityPage> {
  bool isLoading = true;
  List<Map<String, dynamic>> allAvailabilities = [];
  String? error;
  String search = '';
  String selectedSpecialty = 'All specialties';
  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  String? _selectedReason;

  final List<String> _motifs = [
    'Consultation',
    'Prescription renewal',
    'Test results',
    'Follow-up',
    'Other',
  ];

  List<String> get specialties {
    final set = <String>{};
    for (final avail in allAvailabilities) {
      final s = (avail['specialty'] ?? '').toString().trim();
      if (s.isNotEmpty) set.add(s);
    }
    return ['All specialties', ...set.toList()..sort()];
  }

  @override
  void initState() {
    super.initState();
    _loadAllAvailabilities();
  }

  Future<void> _loadAllAvailabilities() async {
    setState(() {
      isLoading = true;
      error = null;
    });
    try {
      final response = await DoctorAvailabilityService.getAllAvailabilities();

      // Vérifier si l'utilisateur connecté est un docteur
      final prefs = await SharedPreferences.getInstance();
      final userRole = prefs.getString('role');
      final currentUserId = prefs.getString('userId');

      // Filtrer les disponibilités si l'utilisateur est un docteur
      List<Map<String, dynamic>> filteredResponse = response;
      if (userRole == 'doctor' && currentUserId != null) {
        filteredResponse =
            response.where((avail) {
              final doctorId = avail['doctorId'] ?? '';
              return doctorId != currentUserId;
            }).toList();
      }

      setState(() {
        allAvailabilities = filteredResponse;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> get filteredAvailabilities {
    final searchLower = search.toLowerCase();
    return allAvailabilities.where((avail) {
      final doctorName = (avail['doctorName'] ?? '').toString().toLowerCase();
      final specialty = (avail['specialty'] ?? '').toString().toLowerCase();
      final dateStr =
          DateFormat(
            'dd/MM/yyyy',
          ).format(DateTime.parse(avail['date'])).toLowerCase();
      final slots =
          avail['slots'] is List
              ? avail['slots']
              : (avail['slots'] as Map).values.toList();
      final slotMatch = slots.any(
        (slot) =>
            (slot['time'] ?? '').toString().toLowerCase().contains(searchLower),
      );
      final matchesSearch =
          searchLower.isEmpty ||
          doctorName.contains(searchLower) ||
          specialty.contains(searchLower) ||
          dateStr.contains(searchLower) ||
          slotMatch;
      final matchesSpecialty =
          selectedSpecialty == 'All specialties' ||
          specialty == selectedSpecialty.toLowerCase();
      return matchesSearch && matchesSpecialty;
    }).toList();
  }

  void _showBookingDialog(
    Map<String, dynamic> avail,
    Map<String, dynamic> slot,
  ) {
    final date = DateTime.parse(avail['date']);
    final doctorName = avail['doctorName'] ?? 'Dr';
    final specialty = avail['specialty'] ?? '';
    final doctorId = avail['doctorId'] ?? '';
    final slotTime = slot['time'] ?? '';

    // Reset form
    _reasonController.clear();
    _notesController.clear();
    _selectedReason = null;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (dialogContext) => StatefulBuilder(
            builder:
                (context, setDialogState) => AlertDialog(
                  title: Row(
                    children: [
                      Icon(Icons.calendar_today, color: Colors.deepPurple),
                      const SizedBox(width: 8),
                      const Text('Book Appointment'),
                    ],
                  ),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Doctor info
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.deepPurple.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                doctorName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              if (specialty.isNotEmpty)
                                Text(
                                  specialty,
                                  style: const TextStyle(
                                    color: Colors.deepPurple,
                                    fontSize: 14,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Appointment details
                        Text(
                          'Appointment Details',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Date: ${DateFormat('EEEE d MMMM yyyy', 'en_US').format(date)}',
                        ),
                        Text('Time: $slotTime'),
                        const SizedBox(height: 16),
                        // Reason dropdown
                        DropdownButtonFormField<String>(
                          initialValue: _selectedReason,
                          decoration: const InputDecoration(
                            labelText: 'Reason *',
                            border: OutlineInputBorder(),
                          ),
                          items:
                              _motifs
                                  .map(
                                    (motif) => DropdownMenuItem(
                                      value: motif,
                                      child: Text(motif),
                                    ),
                                  )
                                  .toList(),
                          onChanged:
                              (val) =>
                                  setDialogState(() => _selectedReason = val),
                          validator:
                              (val) =>
                                  val == null || val.isEmpty
                                      ? 'Please choose a reason'
                                      : null,
                        ),
                        const SizedBox(height: 12),
                        // Notes field
                        TextField(
                          controller: _notesController,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            labelText: 'Notes (optional)',
                            border: OutlineInputBorder(),
                            hintText: 'Any additional information...',
                          ),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        if (_selectedReason == null ||
                            _selectedReason!.isEmpty) {
                          ScaffoldMessenger.of(dialogContext).showSnackBar(
                            const SnackBar(
                              content: Text('Please select a reason'),
                            ),
                          );
                          return;
                        }

                        Navigator.of(dialogContext).pop();

                        // Book the appointment
                        final success = await _bookAppointment(
                          doctorId: doctorId,
                          date: date,
                          slotTime: slotTime,
                          reason: _selectedReason!,
                          notes:
                              _notesController.text.isNotEmpty
                                  ? _notesController.text
                                  : null,
                        );

                        // Use the original context for SnackBar
                        if (mounted) {
                          if (success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Appointment booked successfully!',
                                ),
                                backgroundColor: Colors.green,
                                duration: Duration(seconds: 2),
                              ),
                            );
                            // Fermer la page après un délai
                            Future.delayed(const Duration(seconds: 2), () {
                              if (mounted) {
                                Navigator.of(context).pop();
                              }
                            });
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Error booking appointment'),
                                backgroundColor: Colors.red,
                                duration: Duration(seconds: 3),
                              ),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Book Appointment'),
                    ),
                  ],
                ),
          ),
    );
  }

  Future<bool> _bookAppointment({
    required String doctorId,
    required DateTime date,
    required String slotTime,
    required String reason,
    String? notes,
  }) async {
    try {
      // Parse slot time to get hour
      final hour = slotTime.split(':')[0];
      final dateStr =
          '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final datetimeIso = '${dateStr}T$hour:00.000Z';

      final success = await PatientApiService.bookAppointment(
        doctorId: doctorId,
        datetime: datetimeIso,
        reason: reason,
        patientNotes: notes,
      );

      return success;
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Availabilities'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      backgroundColor: const Color(0xFFF5F7FA),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : error != null
              ? Center(child: Text('Erreur: $error'))
              : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            decoration: const InputDecoration(
                              hintText:
                                  'Search doctor, specialty, date or hour...',
                              prefixIcon: Icon(Icons.search),
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                            onChanged: (v) => setState(() => search = v),
                          ),
                        ),
                        const SizedBox(width: 12),
                        DropdownButton<String>(
                          value: selectedSpecialty,
                          items:
                              specialties
                                  .map(
                                    (s) => DropdownMenuItem(
                                      value: s,
                                      child: Text(s),
                                    ),
                                  )
                                  .toList(),
                          onChanged:
                              (v) => setState(
                                () =>
                                    selectedSpecialty = v ?? 'All specialties',
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child:
                        filteredAvailabilities.isEmpty
                            ? const Center(
                              child: Text('No availability found.'),
                            )
                            : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: filteredAvailabilities.length,
                              itemBuilder: (context, i) {
                                final avail = filteredAvailabilities[i];
                                final date = DateTime.parse(avail['date']);
                                final slotsRaw = avail['slots'];
                                final slotsList =
                                    slotsRaw is List
                                        ? slotsRaw
                                        : (slotsRaw as Map).values.toList();
                                final doctorName = avail['doctorName'] ?? 'Dr';
                                final specialty = avail['specialty'] ?? '';
                                final doctorId = avail['doctorId'] ?? '';
                                final doctorCountry = avail['country'] ?? '';
                                final doctorCity = avail['city'] ?? '';
                                final doctorPhone = avail['phone'] ?? '';
                                final doctorImage =
                                    avail['image'] ??
                                    'assets/images/male-doctor-icon.png';
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 18),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(18),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.calendar_today,
                                              color: Colors.deepPurple,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              DateFormat(
                                                'EEEE d MMMM yyyy',
                                                'en_US',
                                              ).format(date),
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.person,
                                              color: Colors.teal,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              doctorName,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 15,
                                              ),
                                            ),
                                            if (specialty.isNotEmpty) ...[
                                              const SizedBox(width: 10),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 2,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: Colors.teal
                                                      .withOpacity(0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: Text(
                                                  specialty,
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.teal,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        Wrap(
                                          spacing: 10,
                                          runSpacing: 8,
                                          children: [
                                            for (final slot in slotsList)
                                              InkWell(
                                                onTap: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder:
                                                          (
                                                            context,
                                                          ) => DoctorProfileScreen(
                                                            doctor: Doctor(
                                                              id: doctorId,
                                                              name: doctorName,
                                                              specialty:
                                                                  specialty,
                                                              image:
                                                                  doctorImage,
                                                              country:
                                                                  doctorCountry,
                                                              city: doctorCity,
                                                              phone:
                                                                  doctorPhone,
                                                            ),
                                                          ),
                                                    ),
                                                  );
                                                },
                                                child: Chip(
                                                  label: Text(
                                                    slot['time'] ?? '',
                                                  ),
                                                  backgroundColor: Colors
                                                      .deepPurple
                                                      .withOpacity(0.08),
                                                  deleteIcon: const Icon(
                                                    Icons.add,
                                                    size: 16,
                                                  ),
                                                  onDeleted: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder:
                                                            (
                                                              context,
                                                            ) => DoctorProfileScreen(
                                                              doctor: Doctor(
                                                                id: doctorId,
                                                                name:
                                                                    doctorName,
                                                                specialty:
                                                                    specialty,
                                                                image:
                                                                    doctorImage,
                                                                country:
                                                                    doctorCountry,
                                                                city:
                                                                    doctorCity,
                                                                phone:
                                                                    doctorPhone,
                                                              ),
                                                            ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                          ],
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
    );
  }
}
