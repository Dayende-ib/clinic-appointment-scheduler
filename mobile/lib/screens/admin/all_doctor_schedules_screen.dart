import 'package:flutter/material.dart';
import '../../services/doctor_availability_service.dart';
import '../../app_theme.dart';
import 'package:intl/intl.dart';

class AllDoctorSchedulesScreen extends StatefulWidget {
  final List<Map<String, dynamic>> doctors;
  const AllDoctorSchedulesScreen({super.key, required this.doctors});

  @override
  State<AllDoctorSchedulesScreen> createState() =>
      _AllDoctorSchedulesScreenState();
}

class _AllDoctorSchedulesScreenState extends State<AllDoctorSchedulesScreen> {
  Map<String, Map<String, List<Map<String, String>>>> weekPlannings =
      {}; // doctorId -> {dateStr: [slots]}
  Set<String> loadingDoctors = {};
  String search = '';

  final List<Color> doctorCardColors = [
    Colors.blue.shade50,
    Colors.green.shade50,
    Colors.orange.shade50,
    Colors.purple.shade50,
    Colors.teal.shade50,
    Colors.pink.shade50,
    Colors.amber.shade50,
    Colors.cyan.shade50,
    Colors.lime.shade50,
    Colors.indigo.shade50,
  ];

  @override
  void initState() {
    super.initState();
    print('[AllDoctorSchedulesScreen] Liste des docteurs reçue :');
    print(widget.doctors);
    if (widget.doctors.isEmpty) {
      print('[AllDoctorSchedulesScreen] Aucun médecin sélectionné !');
    }
    _loadAllWeekPlannings();
  }

  List<DateTime> getWeekDates() {
    final today = DateTime.now();
    final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
    return List.generate(7, (i) => startOfWeek.add(Duration(days: i)));
  }

  Future<void> _loadAllWeekPlannings() async {
    final weekDates = getWeekDates();
    for (final doctor in widget.doctors) {
      final doctorId = doctor['id'] ?? doctor['_id'] ?? '';
      print(
        '[AllDoctorSchedulesScreen] Chargement du planning pour doctorId=$doctorId, doctor=$doctor',
      );
      if (doctorId.isEmpty) continue;
      setState(() => loadingDoctors.add(doctorId));
      Map<String, List<Map<String, String>>> planning = {};
      for (final date in weekDates) {
        final slots = await DoctorAvailabilityService.getAvailabilityForDate(
          date,
          doctorId: doctorId,
        );
        final dateStr = DateFormat('yyyy-MM-dd').format(date);
        planning[dateStr] = slots;
      }
      setState(() {
        weekPlannings[doctorId] = planning;
        loadingDoctors.remove(doctorId);
      });
    }
  }

  // Les médecins doivent être fournis dynamiquement via widget.doctors
  List<Map<String, dynamic>> get allDoctors => widget.doctors;

  // Les plannings doivent être fournis dynamiquement ou via une source réelle
  Map<String, List<Map<String, String>>> getMonthlySchedules() {
    return {};
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> doctors = widget.doctors;
    final weekDates = getWeekDates();
    return Scaffold(
      appBar: AppBar(title: const Text('Doctors Schedules')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Search for a doctor',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) => setState(() => search = value),
            ),
            const SizedBox(height: 8),
            Expanded(
              child:
                  doctors.isEmpty
                      ? const Center(
                        child: Text(
                          'No doctor selected.',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      )
                      : ListView.builder(
                        itemCount: doctors.length,
                        itemBuilder: (context, idx) {
                          final doctor = doctors[idx];
                          final cardColor =
                              doctorCardColors[idx % doctorCardColors.length];
                          final String name =
                              ((doctor['firstname'] ?? '') +
                                      ' ' +
                                      (doctor['lastname'] ?? ''))
                                  .trim();
                          final String displayName =
                              name.isNotEmpty ? name : 'Nom inconnu';
                          final String email = doctor['email'] ?? '';
                          final String specialty =
                              doctor['specialty'] ?? 'Spécialité inconnue';
                          final doctorId = doctor['id'] ?? doctor['_id'] ?? '';
                          final planning = weekPlannings[doctorId] ?? {};
                          final isLoading = loadingDoctors.contains(doctorId);
                          final isSingle = doctors.length == 1;
                          return Card(
                            color: cardColor,
                            margin: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 0,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    displayName,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '$email\n$specialty',
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                  const SizedBox(height: 12),
                                  if (isLoading)
                                    const Text('Loading schedule...')
                                  else
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children:
                                          weekDates.map((date) {
                                            final dateStr = DateFormat(
                                              'yyyy-MM-dd',
                                            ).format(date);
                                            final slots =
                                                planning[dateStr] ?? [];
                                            final dayName = DateFormat(
                                              'EEEE',
                                              'fr_FR',
                                            ).format(date);
                                            return Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  '${dayName[0].toUpperCase()}${dayName.substring(1)} :',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 15,
                                                  ),
                                                ),
                                                if (slots.isEmpty)
                                                  const Padding(
                                                    padding: EdgeInsets.only(
                                                      left: 12,
                                                      bottom: 8,
                                                    ),
                                                    child: Text(
                                                      'No slots available',
                                                      style: TextStyle(
                                                        color: Colors.red,
                                                      ),
                                                    ),
                                                  )
                                                else
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                          left: 12,
                                                          bottom: 8,
                                                        ),
                                                    child: Wrap(
                                                      spacing: 8,
                                                      runSpacing: 4,
                                                      children:
                                                          slots
                                                              .map(
                                                                (s) => Chip(
                                                                  label: Text(
                                                                    '${s['start']} - ${s['end']}',
                                                                  ),
                                                                ),
                                                              )
                                                              .toList(),
                                                    ),
                                                  ),
                                              ],
                                            );
                                          }).toList(),
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
