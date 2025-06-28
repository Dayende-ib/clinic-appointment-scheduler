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

  // Ajout de plus de médecins fictifs
  List<Map<String, dynamic>> get allDoctors => [
    {'name': 'Dr. Dupont', 'active': true},
    {'name': 'Dr. Martin', 'active': true},
    {'name': 'Dr. Bernard', 'active': true},
    {'name': 'Dr. Lefevre', 'active': true},
    {'name': 'Dr. Petit', 'active': true},
    {'name': 'Dr. Moreau', 'active': true},
    {'name': 'Dr. Girard', 'active': true},
    {'name': 'Dr. Garcia', 'active': true},
    {'name': 'Dr. Laurent', 'active': true},
    {'name': 'Dr. Robert', 'active': true},
    {'name': 'Dr. Simon', 'active': true},
    {'name': 'Dr. Michel', 'active': true},
    {'name': 'Dr. David', 'active': true},
    {'name': 'Dr. Richard', 'active': true},
    {'name': 'Dr. Thomas', 'active': true},
  ];

  // Génère des plannings fictifs enrichis pour chaque médecin sur un mois
  Map<String, List<Map<String, String>>> getMonthlySchedules() {
    final now = DateTime.now();
    final daysInMonth = DateUtils.getDaysInMonth(now.year, now.month);
    final List<String> doctorNames =
        allDoctors.map((d) => d['name'] as String).toList();
    final Map<String, List<Map<String, String>>> schedules = {};
    final List<String> types = [
      'Consultation',
      'Opération',
      'Visite',
      'Téléconsultation',
      'Urgence',
    ];
    final List<String> lieux = [
      'Cabinet A',
      'Cabinet B',
      'Clinique X',
      'En ligne',
      'Hôpital Y',
    ];
    final List<String> patients = [
      'Alice Durand',
      'Bob Leroy',
      'Jean Petit',
      'Sophie Martin',
      'Lucas Bernard',
      'Emma Lefevre',
      'Noah Petit',
      'Léa Moreau',
      'Tom Girard',
      'Chloé Garcia',
    ];
    for (final name in doctorNames) {
      schedules[name] = List.generate(16, (i) {
        final day = ((i + 2) * 2 + i) % daysInMonth + 1;
        final startHour = 8 + (i % 8);
        final endHour = startHour + 1 + (i % 2);
        return {
          'date': DateFormat(
            'dd/MM/yyyy',
          ).format(DateTime(now.year, now.month, day)),
          'heure':
              '${startHour.toString().padLeft(2, '0')}:00 - ${endHour.toString().padLeft(2, '0')}:00',
          'type': types[i % types.length],
          'lieu': lieux[i % lieux.length],
          'patient':
              patients[(i + doctorNames.indexOf(name)) % patients.length],
          'note':
              i % 4 == 0
                  ? 'Suivi régulier'
                  : i % 4 == 1
                  ? 'Première visite'
                  : '',
        };
      });
    }
    return schedules;
  }

  void _showDoctorMonthSchedule(
    BuildContext context,
    String doctor,
    List<Map<String, String>> planning,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder:
          (context) => DrMonthPlanningSheet(doctor: doctor, planning: planning),
    );
  }

  @override
  Widget build(BuildContext context) {
    final schedules = getMonthlySchedules();
    final filteredDoctors =
        allDoctors
            .where(
              (d) => d['name'].toLowerCase().contains(search.toLowerCase()),
            )
            .toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Plannings des Médecins')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Rechercher un médecin',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (v) => setState(() => search = v),
            ),
            const SizedBox(height: 8),
            Expanded(
              child:
                  filteredDoctors.isEmpty
                      ? const Center(child: Text('Aucun médecin trouvé.'))
                      : ListView.builder(
                        itemCount: filteredDoctors.length,
                        itemBuilder: (context, i) {
                          final doctor = filteredDoctors[i]['name'];
                          final planning = schedules[doctor] ?? [];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            child: ListTile(
                              leading: const Icon(
                                Icons.medical_services,
                                color: Colors.teal,
                              ),
                              title: Text(
                                doctor,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                '${planning.length} créneaux ce mois-ci',
                              ),
                              trailing: IconButton(
                                icon: const Icon(
                                  Icons.calendar_month,
                                  color: Colors.deepPurple,
                                ),
                                tooltip: 'Voir planning du mois',
                                onPressed:
                                    () => _showDoctorMonthSchedule(
                                      context,
                                      doctor,
                                      planning,
                                    ),
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

class DrMonthPlanningSheet extends StatelessWidget {
  final String doctor;
  final List<Map<String, String>> planning;
  const DrMonthPlanningSheet({
    super.key,
    required this.doctor,
    required this.planning,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder:
          (context, scrollController) => Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 24,
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.medical_services, color: Colors.teal),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Planning de $doctor',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const Divider(),
                if (planning.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: Text('Aucun créneau ce mois-ci.')),
                  )
                else
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: planning.length,
                      itemBuilder: (context, i) {
                        final slot = planning[i];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: ListTile(
                            leading: const Icon(
                              Icons.event_available,
                              color: Colors.deepPurple,
                            ),
                            title: Text('${slot['date']} — ${slot['heure']}'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Type : ${slot['type']}'),
                                Text('Lieu : ${slot['lieu']}'),
                                Text('Patient : ${slot['patient']}'),
                                if ((slot['note'] ?? '').isNotEmpty)
                                  Text('Note : ${slot['note']}'),
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
