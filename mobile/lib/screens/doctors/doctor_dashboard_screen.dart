import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeDoctorScreen extends StatelessWidget {
  final List<Map<String, String>> appointments;
  final void Function(int) onQuickAction;

  const HomeDoctorScreen({
    super.key,
    required this.appointments,
    required this.onQuickAction,
  });

  @override
  Widget build(BuildContext context) {
    final showSeeMore = appointments.length > 3;
    final displayedAppointments = appointments.take(3).toList();
    final now = TimeOfDay.now();
    // Filtre les rendez-vous "maintenant" (±15 min)
    List<Map<String, String>> getCurrentAppointments() {
      return appointments.where((rdv) {
        final timeStr = rdv['time'] ?? '';
        if (timeStr.isEmpty) return false;
        final parts = timeStr.split(":");
        if (parts.length != 2) return false;
        final hour = int.tryParse(parts[0]) ?? 0;
        final minute = int.tryParse(parts[1]) ?? 0;
        final rdvTime = TimeOfDay(hour: hour, minute: minute);
        final nowMinutes = now.hour * 60 + now.minute;
        final rdvMinutes = rdvTime.hour * 60 + rdvTime.minute;
        return (rdvMinutes - nowMinutes).abs() <= 15;
      }).toList();
    }

    final currentAppointments = getCurrentAppointments();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Today's appointments (${appointments.length})",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          ...displayedAppointments.map(
            (rdv) => _AppointmentCard(appointment: rdv),
          ),
          if (showSeeMore)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => onQuickAction(1),
                child: const Text('See more'),
              ),
            ),
          const SizedBox(height: 5),
          Divider(thickness: 1.0),
          const SizedBox(height: 10),
          Text(
            "Today's statistics",
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          _StatsCard(totalRdv: appointments.length),
          const SizedBox(height: 12),
          Divider(thickness: 1.0),
          const SizedBox(height: 12),
          Text(
            "🗓️ Weekly planning",
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          _WeeklyPlanningCard(appointments: appointments),
          const SizedBox(height: 12),
          Divider(thickness: 1.0),
          const SizedBox(height: 12),
          Text(
            "👤 Last consulted patients",
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          ...appointments
              .take(2)
              .map(
                (rdv) => _LastPatientCard(
                  patient: rdv['patient'] ?? '',
                  time: rdv['time'] ?? '',
                  onView: () => onQuickAction(2),
                ),
              ),
          const SizedBox(height: 24),
          _HealthTipCard(),
          const SizedBox(height: 24),
          // Section des rendez-vous en cours
          if (currentAppointments.isNotEmpty) ...[
            Text(
              "Appointments now",
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.red[700],
              ),
            ),
            const SizedBox(height: 8),
            ...currentAppointments.map(
              (rdv) => _AppointmentCard(appointment: rdv),
            ),
            const SizedBox(height: 24),
          ],
        ],
      ),
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  final Map<String, String> appointment;
  const _AppointmentCard({required this.appointment});
  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(
          Icons.schedule,
          color: Theme.of(context).colorScheme.tertiary,
        ),
        title: Text(
          appointment['patient']!,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        subtitle: Text(
          "À ${appointment['time']}",
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {},
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  final int totalRdv;
  const _StatsCard({required this.totalRdv});
  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Icon(Icons.schedule, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 12),
            Text(
              '$totalRdv appointments today',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}

class _HealthTipCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.teal[50],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            const Icon(Icons.lightbulb, color: Colors.teal, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Conseil du jour : Pensez à bien vous hydrater et à faire des pauses régulières.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Nouvelle carte pour les derniers patients consultés
class _LastPatientCard extends StatelessWidget {
  final String patient;
  final String time;
  final VoidCallback onView;
  const _LastPatientCard({
    required this.patient,
    required this.time,
    required this.onView,
  });
  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: const Icon(Icons.person, color: Colors.teal),
        title: Text(patient, style: Theme.of(context).textTheme.bodyLarge),
        subtitle: Text(
          "See at $time",
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        trailing: TextButton(
          onPressed: onView,
          child: const Text('Voir fiche'),
        ),
      ),
    );
  }
}

// Mini carte planning hebdomadaire
class _WeeklyPlanningCard extends StatelessWidget {
  final List<Map<String, String>> appointments;
  const _WeeklyPlanningCard({required this.appointments});

  // Simule une semaine du lundi au dimanche
  List<String> get weekDays => [
    'Lun',
    'Mar',
    'Mer',
    'Jeu',
    'Ven',
    'Sam',
    'Dim',
  ];

  // Regroupe les créneaux par jour (suppose que 'date' est au format 'yyyy-MM-dd')
  Map<String, List<String>> getSlotsByDay() {
    final Map<String, List<String>> slots = {};
    for (var rdv in appointments) {
      final date = rdv['date'] ?? '';
      final time = rdv['time'] ?? '';
      if (date.isNotEmpty) {
        slots.putIfAbsent(date, () => []).add(time);
      }
    }
    return slots;
  }

  @override
  Widget build(BuildContext context) {
    final slotsByDay = getSlotsByDay();
    final today = DateTime.now();
    // Génère les 7 jours de la semaine en cours
    final week = List.generate(
      7,
      (i) => today.subtract(Duration(days: today.weekday - 1 - i)),
    );
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children:
              week.asMap().entries.map((entry) {
                final i = entry.key;
                final day = entry.value;
                final dayStr =
                    "${day.year.toString().padLeft(4, '0')}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}";
                final slots = slotsByDay[dayStr] ?? [];
                final isToday =
                    day.day == today.day &&
                    day.month == today.month &&
                    day.year == today.year;
                return Column(
                  children: [
                    Text(
                      weekDays[i],
                      style: TextStyle(
                        fontWeight:
                            isToday ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    const SizedBox(height: 4),
                    CircleAvatar(
                      radius: 16,
                      backgroundColor:
                          slots.isNotEmpty ? Colors.teal : Colors.grey[300],
                      child: Text(
                        slots.length.toString(),
                        style: TextStyle(
                          color:
                              slots.isNotEmpty ? Colors.white : Colors.black54,
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
        ),
      ),
    );
  }
}
