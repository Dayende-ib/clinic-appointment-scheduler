import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/doctor_appointment_service.dart';

class DoctorAppointmentsScreen extends StatefulWidget {
  const DoctorAppointmentsScreen({super.key});

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
    _loadAppointments();
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
                                '${DateFormat('EEEE d MMMM', 'en_US').format(date)} at ${DateFormat('HH:mm').format(date)}',
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
                                  if (status == 'Upcoming')
                                    TextButton(
                                      onPressed: () {},
                                      child: const Text('Show Details'),
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
