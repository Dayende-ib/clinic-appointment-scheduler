import 'package:flutter/material.dart';

class AllDoctorSchedulesScreen extends StatefulWidget {
  final List<Map<String, dynamic>> doctors;
  const AllDoctorSchedulesScreen({super.key, required this.doctors});

  @override
  State<AllDoctorSchedulesScreen> createState() =>
      _AllDoctorSchedulesScreenState();
}

class _AllDoctorSchedulesScreenState extends State<AllDoctorSchedulesScreen> {
  String search = '';

  // Les médecins doivent être fournis dynamiquement via widget.doctors
  List<Map<String, dynamic>> get allDoctors => widget.doctors;

  // Les plannings doivent être fournis dynamiquement ou via une source réelle
  Map<String, List<Map<String, String>>> getMonthlySchedules() {
    return {};
  }

  @override
  Widget build(BuildContext context) {
    final schedules = getMonthlySchedules();
    return Scaffold(
      appBar: AppBar(title: const Text('All Doctor Schedules')),
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
              child: ListView(
                children:
                    allDoctors
                        .where(
                          (d) => d['name'].toLowerCase().contains(
                            search.toLowerCase(),
                          ),
                        )
                        .map((doctor) {
                          final doctorSchedules =
                              schedules[doctor['name']] ?? [];
                          return ExpansionTile(
                            title: Text(doctor['name']),
                            children:
                                doctorSchedules.isEmpty
                                    ? [
                                      const ListTile(
                                        title: Text(
                                          'No schedules for this month.',
                                        ),
                                      ),
                                    ]
                                    : doctorSchedules
                                        .map(
                                          (s) => ListTile(
                                            title: Text(
                                              '${s['type']} with ${s['patient']}',
                                            ),
                                            subtitle: Text(
                                              '${s['date']} at ${s['time']} - ${s['location']}',
                                            ),
                                          ),
                                        )
                                        .toList(),
                          );
                        })
                        .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
