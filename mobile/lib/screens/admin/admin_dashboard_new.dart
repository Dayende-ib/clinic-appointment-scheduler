import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/admin_service.dart';

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
        stats = data;
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
                      'Chargement du dashboard admin...',
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
                child: const Text('Réessayer'),
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
          'Dashboard Administrateur',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: kPrimaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDashboardStats,
            tooltip: 'Actualiser',
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
                          'Administrateur',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        Text(
                          DateFormat(
                            'EEEE d MMMM yyyy',
                            'fr_FR',
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
                'Vue d\'ensemble',
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
                      title: 'Docteurs',
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
                      title: 'Rendez-vous',
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
                      title: 'Aujourd\'hui',
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
                'Gestion des utilisateurs',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 16),
              _buildActionCard(
                title: 'Gestion des docteurs',
                subtitle: 'Voir, modifier et gérer tous les docteurs',
                icon: Icons.medical_services,
                color: kPrimaryColor,
                onTap: () => Navigator.pushNamed(context, '/admin/doctors'),
              ),
              const SizedBox(height: 12),
              _buildActionCard(
                title: 'Gestion des patients',
                subtitle: 'Voir, modifier et gérer tous les patients',
                icon: Icons.people,
                color: kSecondaryColor,
                onTap: () => Navigator.pushNamed(context, '/admin/patients'),
              ),
              const SizedBox(height: 30),

              // Gestion des rendez-vous
              Text(
                'Gestion des rendez-vous',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 16),
              _buildActionCard(
                title: 'Tous les rendez-vous',
                subtitle: 'Voir et gérer tous les rendez-vous',
                icon: Icons.calendar_month,
                color: kAccentColor,
                onTap:
                    () => Navigator.pushNamed(context, '/admin/appointments'),
              ),
              const SizedBox(height: 12),
              _buildActionCard(
                title: 'Rendez-vous en attente',
                subtitle: 'Gérer les rendez-vous non confirmés',
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
                title: 'Plannings des docteurs',
                subtitle: 'Voir tous les plannings et disponibilités',
                icon: Icons.schedule,
                color: kPurple,
                onTap: () => Navigator.pushNamed(context, '/admin/schedules'),
              ),
              const SizedBox(height: 30),

              // Paramètres système
              Text(
                'Paramètres système',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 16),
              _buildActionCard(
                title: 'Paramètres généraux',
                subtitle: 'Configurer les paramètres de l\'application',
                icon: Icons.settings,
                color: kSoftRed,
                onTap: () => Navigator.pushNamed(context, '/admin/settings'),
              ),
              const SizedBox(height: 12),
              _buildActionCard(
                title: 'Logs système',
                subtitle: 'Consulter les logs et l\'activité',
                icon: Icons.analytics,
                color: kPurple,
                onTap: () => Navigator.pushNamed(context, '/admin/logs'),
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
                      'Statistiques détaillées',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildStatRow(
                      'Rendez-vous terminés',
                      completedAppointments,
                      Icons.check_circle,
                      kSuccessGreen,
                    ),
                    _buildStatRow(
                      'Rendez-vous en attente',
                      pendingAppointments,
                      Icons.schedule,
                      kWarningYellow,
                    ),
                    _buildStatRow(
                      'Taux de remplissage',
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
