import 'package:flutter/material.dart'; 

const Color kPrimaryColor = Color(0xFF03A6A1);
const Color kSecondaryColor = Color(0xFF0891B2);
final Color kAccentColor = Colors.orange.shade600;
const Color kSoftRed = Color(0xFFDB6C6C); // Rouge doux harmonisé

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  String selectedFilter = 'all';

  final List<Appointment> appointments = [
    Appointment(
      id: '1',
      doctorName: 'Dr. Sophie Martin',
      specialty: 'General Physician',
      date: '15 juillet 2024',
      time: '10:00',
      status: AppointmentStatus.confirmed,
      type: AppointmentType.upcoming,
      avatar: '👩‍⚕️',
    ),
    Appointment(
      id: '2',
      doctorName: 'Dr. Pierre Dubois',
      specialty: 'Endocrinologist',
      date: '20 juillet 2024',
      time: '14:30',
      status: AppointmentStatus.pending,
      type: AppointmentType.upcoming,
      avatar: '👨‍⚕️',
    ),
    Appointment(
      id: '3',
      doctorName: 'Dr. Marie Leroy',
      specialty: 'Endocrinologist',
      date: '25 juillet 2024',
      time: '16:00',
      status: AppointmentStatus.confirmed,
      type: AppointmentType.upcoming,
      avatar: '👩‍⚕️',
    ),
    Appointment(
      id: '4',
      doctorName: 'Dr. Jean Dupont',
      specialty: 'Physician',
      date: '10 juin 2024',
      time: '09:30',
      status: AppointmentStatus.completed,
      type: AppointmentType.past,
      avatar: '👨‍⚕️',
    ),
    Appointment(
      id: '5',
      doctorName: 'Dr. Anne Moreau',
      specialty: 'Dentist',
      date: '15 mai 2024',
      time: '15:00',
      status: AppointmentStatus.completed,
      type: AppointmentType.past,
      avatar: '👩‍⚕️',
    ),
    Appointment(
      id: '6',
      doctorName: 'Dr. Paul Bernard',
      specialty: 'Physician',
      date: '12 juillet 2024',
      time: '14:00',
      status: AppointmentStatus.cancelled,
      type: AppointmentType.cancelled,
      avatar: '👨‍⚕️',
    ),
  ];

  List<Appointment> get filteredAppointments {
    if (selectedFilter == 'all') return appointments;
    return appointments.where((apt) => apt.type.name == selectedFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Column(
        children: [
          _buildHeader(),
          _buildFilters(),
          Expanded(child: _buildAppointmentsList()),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [kPrimaryColor, kSecondaryColor],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'My appointments',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Manage your medical appointments',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    final filters = {
      'all': 'All',
      'upcoming': 'Upcoming',
      'past': 'Past',
      'cancelled': 'Cancelled',
    };

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: filters.entries
              .map((e) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _buildFilterButton(e.value, e.key),
                  ))
              .toList(),
        ),
      ),
    );
  }

  Widget _buildFilterButton(String label, String value) {
    final isSelected = selectedFilter == value;
    return GestureDetector(
      onTap: () => setState(() => selectedFilter = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? kPrimaryColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF64748B),
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildAppointmentsList() {
    final grouped = _groupAppointmentsByType();
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
      children: [
        if (selectedFilter == 'all' || selectedFilter == 'upcoming')
          _buildSection('Upcoming', '🟢', grouped['upcoming'] ?? []),
        if (selectedFilter == 'all' || selectedFilter == 'past')
          _buildSection('Past', '🔵', grouped['past'] ?? []),
        if (selectedFilter == 'all' || selectedFilter == 'cancelled')
          _buildSection('Cancelled', '🔴', grouped['cancelled'] ?? []),
      ],
    );
  }

  Map<String, List<Appointment>> _groupAppointmentsByType() {
    final Map<String, List<Appointment>> grouped = {};
    for (var apt in filteredAppointments) {
      grouped[apt.type.name] = grouped[apt.type.name] ?? [];
      grouped[apt.type.name]!.add(apt);
    }
    return grouped;
  }

  Widget _buildSection(String title, String emoji, List<Appointment> appointments) {
    if (appointments.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF374151),
                ),
              ),
            ],
          ),
        ),
        ...appointments.map(_buildAppointmentCard),
        const SizedBox(height: 25),
      ],
    );
  }

  Widget _buildAppointmentCard(Appointment appointment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border(
          left: BorderSide(
            color: _getBorderColor(appointment.type),
            width: 4,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildDoctorInfo(appointment),
            const SizedBox(height: 12),
            _buildAppointmentMeta(appointment),
            const SizedBox(height: 12),
            _buildActions(appointment),
          ],
        ),
      ),
    );
  }

  Widget _buildDoctorInfo(Appointment appointment) {
    return Row(
      children: [
        Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            color: kAccentColor,
            borderRadius: BorderRadius.circular(22.5),
          ),
          child: Center(
            child: Text(appointment.avatar, style: const TextStyle(fontSize: 20)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                appointment.doctorName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2937),
                ),
              ),
              Text(
                appointment.specialty,
                style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAppointmentMeta(Appointment appointment) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMetaRow('📅', appointment.date),
            _buildMetaRow('🕙', appointment.time),
          ],
        ),
        _buildStatusBadge(appointment.status),
      ],
    );
  }

  Widget _buildMetaRow(String icon, String text) {
    return Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 12)),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(AppointmentStatus status) {
    Color bg, fg;
    String label;

    switch (status) {
      case AppointmentStatus.confirmed:
        bg = const Color(0xFFDCFCE7);
        fg = const Color(0xFF166534);
        label = 'Confirmed';
        break;
      case AppointmentStatus.pending:
        bg = const Color(0xFFFEF3C7);
        fg = const Color(0xFF92400E);
        label = 'Pending';
        break;
      case AppointmentStatus.cancelled:
        bg = const Color(0xFFFEE2E2);
        fg = const Color(0xFF991B1B);
        label = 'Cancelled';
        break;
      case AppointmentStatus.completed:
        bg = const Color(0xFFE0E7FF);
        fg = const Color(0xFF3730A3);
        label = 'Completed';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Text(label, style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildActions(Appointment appointment) {
    List<Widget> actions;

    switch (appointment.type) {
      case AppointmentType.upcoming:
        actions = [
          _action('Modify', Colors.grey.shade100, const Color(0xFF475569), () => _modifyAppointment(appointment)),
          _action('Cancel', kSoftRed, Colors.white, () => _cancelAppointment(appointment)), // Rouge adouci ici
        ];
        break;
      case AppointmentType.past:
        actions = [
          _action('View report', Colors.grey.shade100, const Color(0xFF475569), () => _viewReport(appointment)),
          _action('Reschedule', kPrimaryColor, Colors.white, () => _rescheduleAppointment(appointment)),
        ];
        break;
      case AppointmentType.cancelled:
        actions = [
          _action('Reschedule', kPrimaryColor, Colors.white, () => _rescheduleAppointment(appointment)),
        ];
        break;
    }

    return Row(
      children: actions
          .map((btn) => Expanded(child: Padding(padding: const EdgeInsets.only(right: 8), child: btn)))
          .toList(),
    );
  }

  Widget _action(String label, Color bg, Color fg, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(color: fg, fontSize: 13, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Color _getBorderColor(AppointmentType type) {
    switch (type) {
      case AppointmentType.upcoming:
        return const Color(0xFF10B981);
      case AppointmentType.past:
        return kSecondaryColor;
      case AppointmentType.cancelled:
        return kSoftRed;
    }
  }

  void _modifyAppointment(Appointment appointment) => print('Modify appointment: ${appointment.doctorName}');
  void _cancelAppointment(Appointment appointment) => print('Cancel appointment: ${appointment.doctorName}');
  void _viewReport(Appointment appointment) => print('View report: ${appointment.doctorName}');
  void _rescheduleAppointment(Appointment appointment) => print('Reschedule appointment: ${appointment.doctorName}');
}

class Appointment {
  final String id;
  final String doctorName;
  final String specialty;
  final String date;
  final String time;
  final AppointmentStatus status;
  final AppointmentType type;
  final String avatar;

  Appointment({
    required this.id,
    required this.doctorName,
    required this.specialty,
    required this.date,
    required this.time,
    required this.status,
    required this.type,
    required this.avatar,
  });
}

enum AppointmentStatus { confirmed, pending, cancelled, completed }
enum AppointmentType { upcoming, past, cancelled }