import 'package:flutter/material.dart';
import 'package:caretime/screens/admin/doctor_list_screen.dart';
import 'package:caretime/screens/admin/patient_list_screen.dart';
import 'package:caretime/screens/admin/all_doctor_schedules_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  // Les listes doivent être alimentées dynamiquement
  List<Map<String, dynamic>> doctors = [];
  List<Map<String, dynamic>> patients = [];

  String doctorSearch = '';
  String patientSearch = '';

  void _manageScheduleSettings() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Schedule Settings'),
            content: const Text(
              'Manage global schedule settings (to be implemented).',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Area')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.medical_services),
                  label: const Text('View Doctors'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => DoctorListScreen(
                              doctors: doctors,
                              onToggle:
                                  (i) => setState(
                                    () =>
                                        doctors[i]['active'] =
                                            !doctors[i]['active'],
                                  ),
                              onRemove:
                                  (i) => setState(() => doctors.removeAt(i)),
                              search: doctorSearch,
                              onSearch: (v) => setState(() => doctorSearch = v),
                            ),
                      ),
                    );
                  },
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.people),
                  label: const Text('View Patients'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => PatientListScreen(
                              patients: patients,
                              onToggle:
                                  (i) => setState(
                                    () =>
                                        patients[i]['active'] =
                                            !patients[i]['active'],
                                  ),
                              onRemove:
                                  (i) => setState(() => patients.removeAt(i)),
                              search: patientSearch,
                              onSearch:
                                  (v) => setState(() => patientSearch = v),
                            ),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 32),
            ListTile(
              leading: const Icon(Icons.settings, color: Colors.grey),
              title: const Text('Schedule Settings'),
              onTap: _manageScheduleSettings,
              tileColor: Colors.grey[100],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(
                Icons.calendar_month,
                color: Colors.deepPurple,
              ),
              title: const Text('All Doctor Schedules'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => AllDoctorSchedulesScreen(doctors: doctors),
                  ),
                );
              },
              tileColor: Colors.deepPurple[50],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
