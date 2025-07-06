import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/admin_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

const Color kPrimaryColor = Color(0xFF03A6A1);
const Color kSecondaryColor = Color(0xFF0891B2);
final Color kAccentColor = Colors.orange.shade600;
const Color kSoftRed = Color(0xFFDB6C6C);
const Color kSuccessGreen = Color(0xFF10B981);
const Color kWarningYellow = Color(0xFFF59E0B);
const Color kPurple = Color(0xFF8B5CF6);

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  Map<String, dynamic> stats = {};
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadDashboardStats();
  }

  Future<void> _loadDashboardStats() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final data = await AdminService.getDashboardStats();
      setState(() {
        stats = {
          'totalDoctors': data['users']?['doctors'] ?? 0,
          'totalPatients': data['users']?['patients'] ?? 0,
          'totalAdmins': data['users']?['admins'] ?? 0,
          'totalUsers': data['users']?['total'] ?? 0,
          'totalAppointments': data['appointments']?['total'] ?? 0,
          'confirmedAppointments': data['appointments']?['confirmed'] ?? 0,
          'canceledAppointments': data['appointments']?['canceled'] ?? 0,
          'bookedAppointments': data['appointments']?['booked'] ?? 0,
          'completedAppointments': data['appointments']?['completed'] ?? 0,
          'todayAppointments': data['appointments']?['today'] ?? 0,
          'pendingAppointments': data['appointments']?['pending'] ?? 0,
        };
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
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
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3)),
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
                color: color.withValues(alpha: 0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
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
              color: Colors.black.withValues(alpha: 0.05),
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
                color: color.withValues(alpha: 0.1),
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
                      color: Colors.black.withValues(alpha: 0.05),
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
                      'Loading admin dashboard...',
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
        backgroundColor: const Color(0xFFF9FAFB),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Erreur: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadDashboardStats,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final totalDoctors = stats['totalDoctors'] ?? 0;
    final totalPatients = stats['totalPatients'] ?? 0;
    final totalAppointments = stats['totalAppointments'] ?? 0;
    final todayAppointments = stats['todayAppointments'] ?? 0;
    final pendingAppointments = stats['pendingAppointments'] ?? 0;
    final completedAppointments = stats['completedAppointments'] ?? 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: kPrimaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDashboardStats,
            tooltip: 'refresh',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder:
                    (context) => AlertDialog(
                      title: const Text('Logout'),
                      content: const Text('Are you sure you want to log out?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Logout'),
                        ),
                      ],
                    ),
              );
              if (confirmed == true) {
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear();
                if (!context.mounted) return;
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadDashboardStats,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header avec date
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: kPrimaryColor,
                    child: const Icon(
                      Icons.admin_panel_settings,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Administrator',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        Text(
                          DateFormat(
                            'EEEE, MMMM d, yyyy',
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
                ],
              ),
              const SizedBox(height: 30),

              // Statistiques principales
              Text(
                'Overview',
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
                      title: 'Doctors',
                      value: totalDoctors,
                      icon: Icons.medical_services,
                      color: kPrimaryColor,
                      onTap:
                          () => Navigator.pushNamed(context, '/admin/doctors'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      title: 'Patients',
                      value: totalPatients,
                      icon: Icons.people,
                      color: kSecondaryColor,
                      onTap:
                          () => Navigator.pushNamed(context, '/admin/patients'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      title: 'Appointments',
                      value: totalAppointments,
                      icon: Icons.calendar_today,
                      color: kAccentColor,
                      onTap:
                          () => Navigator.pushNamed(
                            context,
                            '/admin/appointments',
                          ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      title: 'Today',
                      value: todayAppointments,
                      icon: Icons.today,
                      color: kSuccessGreen,
                      onTap:
                          () => Navigator.pushNamed(
                            context,
                            '/admin/appointments/today',
                          ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // Actions rapides
              Text(
                'User Management',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 16),
              _buildActionCard(
                title: 'Manage Doctors',
                subtitle: 'View, edit and manage all doctors',
                icon: Icons.medical_services,
                color: kPrimaryColor,
                onTap: () => Navigator.pushNamed(context, '/admin/doctors'),
              ),
              const SizedBox(height: 12),
              _buildActionCard(
                title: 'Manage Patients',
                subtitle: 'View, edit and manage all patients',
                icon: Icons.people,
                color: kSecondaryColor,
                onTap: () => Navigator.pushNamed(context, '/admin/patients'),
              ),
              const SizedBox(height: 30),

              // Gestion des rendez-vous
              Text(
                'Appointments Management',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 16),
              _buildActionCard(
                title: 'All Appointments',
                subtitle: 'View and manage all appointments',
                icon: Icons.calendar_month,
                color: kAccentColor,
                onTap:
                    () => Navigator.pushNamed(context, '/admin/appointments'),
              ),
              const SizedBox(height: 12),
              _buildActionCard(
                title: 'Pending Appointments',
                subtitle: 'Manage unconfirmed appointments',
                icon: Icons.pending_actions,
                color: kWarningYellow,
                onTap:
                    () => Navigator.pushNamed(
                      context,
                      '/admin/appointments/pending',
                    ),
              ),
              const SizedBox(height: 12),
              _buildActionCard(
                title: 'Doctors Schedules',
                subtitle: 'View all schedules and availabilities',
                icon: Icons.schedule,
                color: kPurple,
                onTap: () async {
                  final doctors = await AdminService.getAllDoctors();
                  if (!mounted) return;
                  Navigator.pushNamed(
                    context,
                    '/admin/schedules',
                    arguments: {'doctors': doctors},
                  );
                },
              ),
              const SizedBox(height: 30),

              // Statistiques détaillées
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Detailed Statistics',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildStatRow(
                      'Completed appointments',
                      completedAppointments,
                      Icons.check_circle,
                      kSuccessGreen,
                    ),
                    _buildStatRow(
                      'Pending appointments',
                      pendingAppointments,
                      Icons.schedule,
                      kWarningYellow,
                    ),
                    _buildStatRow(
                      'Occupancy rate',
                      '${((completedAppointments / (totalAppointments > 0 ? totalAppointments : 1)) * 100).toStringAsFixed(1)}%',
                      Icons.trending_up,
                      kPrimaryColor,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow(
    String label,
    dynamic value,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(label)),
          Text(
            value.toString(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
