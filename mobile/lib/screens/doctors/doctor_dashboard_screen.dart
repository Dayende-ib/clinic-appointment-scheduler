import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/doctor_service.dart';
import '../../services/doctor_appointment_service.dart';

const Color kPrimaryColor = Color(0xFF03A6A1);
const Color kSecondaryColor = Color(0xFF0891B2);
final Color kAccentColor = Colors.orange.shade600;
const Color kSoftRed = Color(0xFFDB6C6C);
const Color kSuccessGreen = Color(0xFF10B981);
const Color kWarningYellow = Color(0xFFF59E0B);

class DoctorDashboardScreen extends StatefulWidget {
  const DoctorDashboardScreen({super.key});

  @override
  State<DoctorDashboardScreen> createState() => _DoctorDashboardScreenState();
}

class _DoctorDashboardScreenState extends State<DoctorDashboardScreen> {
  Map<String, dynamic>? doctorProfile;
  bool isLoading = true;
  String? error;
  List<Map<String, dynamic>> todayAppointments = [];
  List<Map<String, dynamic>> upcomingAppointments = [];
  List<Map<String, dynamic>> allAppointments = [];

  // Statistiques
  int totalToday = 0;
  int completedToday = 0;
  int pendingToday = 0;
  int totalUpcoming = 0;
  int totalCompleted = 0;
  int totalCancelled = 0;

  @override
  void initState() {
    super.initState();
    _checkAuth();
    _loadAllData();
  }

  Future<void> _checkAuth() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null || token.isEmpty) {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  Future<void> _loadAllData() async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      await Future.wait([_loadProfile(), _loadAppointments()]);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> _loadProfile() async {
    try {
      final data = await DoctorService.fetchDoctorProfile();
      if (!mounted) return;
      setState(() {
        doctorProfile = data;
      });
    } catch (e) {
      // Gérer l'erreur silencieusement
    }
  }

  Future<void> _loadAppointments() async {
    try {
      final allData = await DoctorAppointmentService.fetchDoctorAppointments();
      final today = DateTime.now();

      final todayData =
          allData.where((apt) {
            final date = apt['date'] as DateTime;
            return date.year == today.year &&
                date.month == today.month &&
                date.day == today.day;
          }).toList();

      final upcomingData =
          allData.where((apt) {
            final date = apt['date'] as DateTime;
            return date.isAfter(today);
          }).toList();

      if (!mounted) return;
      setState(() {
        allAppointments = allData;
        todayAppointments = todayData;
        upcomingAppointments = upcomingData;

        // Calculer les statistiques
        totalToday = todayData.length;
        completedToday =
            todayData
                .where((apt) => apt['originalStatus'] == 'completed')
                .length;
        pendingToday =
            todayData
                .where(
                  (apt) =>
                      apt['originalStatus'] == 'booked' ||
                      apt['originalStatus'] == 'confirmed',
                )
                .length;

        totalUpcoming = upcomingData.length;
        totalCompleted =
            allData.where((apt) => apt['originalStatus'] == 'completed').length;
        totalCancelled =
            allData.where((apt) => apt['originalStatus'] == 'canceled').length;

        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
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
                        _buildDetailSection('📅 Appoitment', [
                          'Date: ${DateFormat('EEEE d MMMM yyyy', 'en_US').format(date)}',
                          'Heure: ${DateFormat('HH:mm').format(date)}',
                        ]),
                        const SizedBox(height: 20),
                        _buildDetailSection('👤 Patient information', [
                          'Email: $patientEmail',
                          'Phone: $patientPhone',
                        ]),
                        const SizedBox(height: 20),
                        _buildDetailSection('💬 Reason of consultation', [
                          reason.isNotEmpty ? reason : 'No reason specified',
                        ]),
                        if (patientNotes.isNotEmpty) ...[
                          const SizedBox(height: 20),
                          _buildDetailSection('📝 Patient notes', [
                            patientNotes,
                          ]),
                        ],
                        if (doctorNotes.isNotEmpty) ...[
                          const SizedBox(height: 20),
                          _buildDetailSection('📋 My notes', [doctorNotes]),
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
                                _loadAllData();
                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Appointment canceled'),
                                    backgroundColor: kSoftRed,
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
                              'Cancel',
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
                                _loadAllData();
                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text(
                                      'Appointment confirmed',
                                    ),
                                    backgroundColor: kPrimaryColor,
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
                              'Confirme',
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
        label = 'Confirmed';
        break;
      case 'booked':
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

  Widget _buildStatCard({
    required String title,
    required int value,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: Colors.white, size: 20),
                ),
                const Spacer(),
                Icon(Icons.arrow_forward_ios, color: color, size: 16),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value.toString(),
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: color.withOpacity(0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToAppointmentsWithFilter(String filter) {
    Navigator.pushNamed(
      context,
      '/doctor/appointments',
      arguments: {'filter': filter},
    );
  }

  void _navigateToAvailability() {
    Navigator.pushNamed(context, '/doctor/availability');
  }

  void _navigateToProfile() {
    Navigator.pushNamed(context, '/profile');
  }

  void _showQuickStats() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Global statistics'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildStatRow(
                  'Total appointments',
                  allAppointments.length,
                  Icons.calendar_today,
                ),
                _buildStatRow(
                  'Completed appointments',
                  totalCompleted,
                  Icons.check_circle,
                ),
                _buildStatRow(
                  'Cancelled appointments',
                  totalCancelled,
                  Icons.cancel,
                ),
                _buildStatRow(
                  'Upcoming appointments',
                  totalUpcoming,
                  Icons.schedule,
                ),
              ],
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

  Widget _buildStatRow(String label, int value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: kPrimaryColor, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(label)),
          Text(
            value.toString(),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
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
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: color, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentCard(Map<String, dynamic> appointment) {
    final String patientName = appointment['patient'] ?? '';
    final String reason = appointment['reason'] ?? '';
    final DateTime date = appointment['date'];
    final String status = appointment['originalStatus'] ?? '';
    final String timeStr = DateFormat('HH:mm').format(date);

    return GestureDetector(
      onTap: () => _showAppointmentDetails(appointment),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border(
            left: BorderSide(color: _getStatusColor(status), width: 4),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _getStatusColor(status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.access_time,
                color: _getStatusColor(status),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    patientName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  if (reason.isNotEmpty)
                    Text(
                      reason,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6B7280),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  timeStr,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                _buildStatusChip(status),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'confirmed':
        return kSuccessGreen;
      case 'booked':
        return kWarningYellow;
      case 'canceled':
        return kSoftRed;
      case 'completed':
        return kPrimaryColor;
      default:
        return kSecondaryColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF9FAFB),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    const Text(
                      'Loading doctor dashboard...',
                      style: TextStyle(fontSize: 16, color: Color(0xFF6B7280)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (error != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadAllData,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final String doctorName =
        doctorProfile != null
            ? '${doctorProfile!['firstname']} ${doctorProfile!['lastname']}'
            : 'Doctor';

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: RefreshIndicator(
        onRefresh: _loadAllData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: kPrimaryColor,
                    child: Text(
                      doctorName.isNotEmpty ? doctorName[0] : 'D',
                      style: const TextStyle(
                        fontSize: 24,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hello, Dr $doctorName',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        Text(
                          DateFormat(
                            'EEEE d MMMM yyyy',
                            'en_US',
                          ).format(DateTime.now()),
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: _showQuickStats,
                    icon: const Icon(Icons.analytics_outlined),
                    tooltip: 'Global statistics',
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // Statistiques du jour
              Text(
                'Today',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      title: 'Total',
                      value: totalToday,
                      icon: Icons.calendar_today,
                      color: kSecondaryColor,
                      onTap: () {
                        _navigateToAppointmentsWithFilter('today');
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      title: 'Completed',
                      value: completedToday,
                      icon: Icons.check_circle,
                      color: kSuccessGreen,
                      onTap: () {
                        _navigateToAppointmentsWithFilter('completed');
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      title: 'Pending',
                      value: pendingToday,
                      icon: Icons.schedule,
                      color: kWarningYellow,
                      onTap: () {
                        _navigateToAppointmentsWithFilter('booked');
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // Statistiques globales
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Overview',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  TextButton(
                    onPressed: _showQuickStats,
                    child: const Text('See more'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      title: 'Total',
                      value: allAppointments.length,
                      icon: Icons.calendar_month,
                      color: kSecondaryColor,
                      onTap: () => _navigateToAppointmentsWithFilter('all'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      title: 'Completed',
                      value: totalCompleted,
                      icon: Icons.check_circle,
                      color: kSuccessGreen,
                      onTap:
                          () => _navigateToAppointmentsWithFilter('completed'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      title: 'Upcoming',
                      value: totalUpcoming,
                      icon: Icons.schedule,
                      color: kWarningYellow,
                      onTap:
                          () => _navigateToAppointmentsWithFilter('upcoming'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // Actions rapides
              Text(
                'Quick actions',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 16),
              _buildActionCard(
                title: 'Manage my availabilities',
                subtitle: 'Add or modify your slots',
                icon: Icons.schedule,
                color: kPrimaryColor,
                onTap: _navigateToAvailability,
              ),
              const SizedBox(height: 12),
              _buildActionCard(
                title: 'All my appointments',
                subtitle: 'See and manage all your appointments',
                icon: Icons.list_alt,
                color: kSecondaryColor,
                onTap: () {
                  _navigateToAppointmentsWithFilter('all');
                },
              ),
              const SizedBox(height: 12),
              _buildActionCard(
                title: 'My profile',
                subtitle: 'Modify your information',
                icon: Icons.person,
                color: kAccentColor,
                onTap: _navigateToProfile,
              ),
              const SizedBox(height: 30),

              // Rendez-vous d'aujourd'hui
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Today\'s appointments',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  if (todayAppointments.isNotEmpty)
                    TextButton(
                      onPressed: () {
                        _navigateToAppointmentsWithFilter('today');
                      },
                      child: const Text('See all'),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              if (todayAppointments.isEmpty)
                Container(
                  padding: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.event_busy, size: 48, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No appointments today',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                )
              else
                ...todayAppointments.take(3).map(_buildAppointmentCard),
              const SizedBox(height: 30),

              // Prochains rendez-vous
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Upcoming appointments',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  if (upcomingAppointments.isNotEmpty)
                    TextButton(
                      onPressed: () {
                        _navigateToAppointmentsWithFilter('upcoming');
                      },
                      child: const Text('See all'),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              if (upcomingAppointments.isEmpty)
                Container(
                  padding: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.event_note, size: 48, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No upcoming appointments',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                )
              else
                ...upcomingAppointments.take(3).map(_buildAppointmentCard),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
