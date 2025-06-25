import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DoctorAppointmentsScreen extends StatefulWidget {
  const DoctorAppointmentsScreen({super.key});

  @override
  State<DoctorAppointmentsScreen> createState() =>
      _DoctorAppointmentsScreenState();
}

class _DoctorAppointmentsScreenState extends State<DoctorAppointmentsScreen> {
  // Simule une liste de rendez-vous
  List<Map<String, dynamic>> allAppointments = [
    {
      'date': DateTime.now().add(const Duration(hours: 2)),
      'patient': 'Alice Martin',
      'status': 'Upcoming',
    },
    {
      'date': DateTime.now().add(const Duration(days: 1, hours: 1)),
      'patient': 'Jean Dupont',
      'status': 'Upcoming',
    },
    {
      'date': DateTime.now().subtract(const Duration(days: 1)),
      'patient': 'Sophie Bernard',
      'status': 'Completed',
    },
    {
      'date': DateTime.now().add(const Duration(days: 2)),
      'patient': 'Paul Durand',
      'status': 'Cancelled',
    },
  ];

  String filterStatus = 'All';
  String search = '';

  List<String> statusOptions = ['All', 'Upcoming', 'Completed', 'Cancelled'];

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filtered =
        allAppointments.where((rdv) {
          final matchesStatus =
              filterStatus == 'All' || rdv['status'] == filterStatus;
          final matchesSearch =
              search.isEmpty ||
              (rdv['patient'] as String).toLowerCase().contains(
                search.toLowerCase(),
              );
          return matchesStatus && matchesSearch;
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
                      hintText: 'Search a patient...',
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
                      ? const Center(child: Text('No appointments found.'))
                      : ListView.separated(
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, i) {
                          final rdv = filtered[i];
                          final date = rdv['date'] as DateTime;
                          final status = rdv['status'] as String;
                          Color statusColor;
                          switch (status) {
                            case 'À venir':
                              statusColor = Colors.teal;
                              break;
                            case 'Terminé':
                              statusColor = Colors.green;
                              break;
                            case 'Annulé':
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
                                backgroundColor: statusColor.withOpacity(0.15),
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
                                  if (status == 'À venir')
                                    TextButton(
                                      onPressed: () {},
                                      child: const Text('Voir fiche'),
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
