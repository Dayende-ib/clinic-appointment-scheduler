import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AllDoctorSchedulesScreen extends StatefulWidget {
  final List<Map<String, dynamic>> doctors;
  const AllDoctorSchedulesScreen({super.key, required this.doctors});

  @override
  State<AllDoctorSchedulesScreen> createState() =>
      _AllDoctorSchedulesScreenState();
}

class _AllDoctorSchedulesScreenState extends State<AllDoctorSchedulesScreen> {
  String search = '';

  // Add more fake doctors
  List<Map<String, dynamic>> get allDoctors => [
    {'name': 'Dr. Smith', 'active': true},
    {'name': 'Dr. Johnson', 'active': true},
    {'name': 'Dr. Williams', 'active': true},
    {'name': 'Dr. Brown', 'active': true},
    {'name': 'Dr. Jones', 'active': true},
    {'name': 'Dr. Miller', 'active': true},
    {'name': 'Dr. Davis', 'active': true},
    {'name': 'Dr. Garcia', 'active': true},
    {'name': 'Dr. Rodriguez', 'active': true},
    {'name': 'Dr. Wilson', 'active': true},
    {'name': 'Dr. Martinez', 'active': true},
    {'name': 'Dr. Anderson', 'active': true},
    {'name': 'Dr. Taylor', 'active': true},
    {'name': 'Dr. Thomas', 'active': true},
    {'name': 'Dr. Hernandez', 'active': true},
  ];

  // Generate enriched fake schedules for each doctor for a month
  Map<String, List<Map<String, String>>> getMonthlySchedules() {
    final now = DateTime.now();
    final daysInMonth = DateUtils.getDaysInMonth(now.year, now.month);
    final List<String> doctorNames =
        allDoctors.map((d) => d['name'] as String).toList();
    final Map<String, List<Map<String, String>>> schedules = {};
    final List<String> types = [
      'Consultation',
      'Operation',
      'Visit',
      'Teleconsultation',
      'Emergency',
    ];
    final List<String> locations = [
      'Office A',
      'Office B',
      'Clinic X',
      'Online',
      'Hospital Y',
    ];
    final List<String> patients = [
      'Alice Smith',
      'Bob Johnson',
      'John Williams',
      'Sophie Brown',
      'Paul Jones',
      'Emma Miller',
      'Lucas Davis',
      'Olivia Garcia',
      'Liam Rodriguez',
      'Mia Wilson',
    ];
    for (final doctor in doctorNames) {
      schedules[doctor] = [];
      for (int day = 1; day <= daysInMonth; day++) {
        if (day % 3 == 0) {
          schedules[doctor]!.add({
            'date': DateFormat(
              'MM/dd/yyyy',
            ).format(DateTime(now.year, now.month, day)),
            'type': types[day % types.length],
            'location': locations[day % locations.length],
            'patient': patients[day % patients.length],
            'time': '${8 + (day % 8)}:00',
          });
        }
      }
    }
    return schedules;
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
