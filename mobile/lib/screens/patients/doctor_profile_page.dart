import 'package:flutter/material.dart';
import 'package:caretime/app_colors.dart';
import 'doctor_list_page.dart'; // Import pour accéder à la classe Doctor
import '../../services/patient_api_service.dart';

class DoctorProfileScreen extends StatefulWidget {
  final Doctor doctor;

  const DoctorProfileScreen({super.key, required this.doctor});

  @override
  State<DoctorProfileScreen> createState() => _DoctorProfileScreenState();
}

class _DoctorProfileScreenState extends State<DoctorProfileScreen> {
  List<Map<String, dynamic>> slots = [];
  bool isLoading = true;
  String? error;
  int? selectedSlotIndex;
  bool isBooking = false;
  DateTime selectedDate = DateTime.now();
  DateTime calendarMonth = DateTime(DateTime.now().year, DateTime.now().month);
  List<int> selectedSlotIndices = [];
  List<DateTime> selectedDates = [];

  @override
  void initState() {
    super.initState();
    _loadSlots();
  }

  Future<void> _loadSlots() async {
    setState(() {
      isLoading = true;
      error = null;
    });
    try {
      final dateStr =
          '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}';
      final s = await PatientApiService.getDoctorAvailabilities(
        widget.doctor.id,
        dateStr,
      );
      setState(() {
        slots = s;
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Profil du docteur'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : error != null
              ? Center(child: Text('Erreur: $error'))
              : ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // Navigation entre les mois
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        onPressed: () {
                          setState(() {
                            calendarMonth = DateTime(
                              calendarMonth.year,
                              calendarMonth.month - 1,
                            );
                            // Si le jour sélectionné n'existe pas dans le nouveau mois, on prend le 1er
                            int lastDay =
                                DateTime(
                                  calendarMonth.year,
                                  calendarMonth.month + 1,
                                  0,
                                ).day;
                            int newDay =
                                selectedDate.day > lastDay
                                    ? lastDay
                                    : selectedDate.day;
                            selectedDate = DateTime(
                              calendarMonth.year,
                              calendarMonth.month,
                              newDay,
                            );
                          });
                          _loadSlots();
                        },
                      ),
                      Text(
                        '${_monthName(calendarMonth.month)} ${calendarMonth.year}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed: () {
                          setState(() {
                            calendarMonth = DateTime(
                              calendarMonth.year,
                              calendarMonth.month + 1,
                            );
                            int lastDay =
                                DateTime(
                                  calendarMonth.year,
                                  calendarMonth.month + 1,
                                  0,
                                ).day;
                            int newDay =
                                selectedDate.day > lastDay
                                    ? lastDay
                                    : selectedDate.day;
                            selectedDate = DateTime(
                              calendarMonth.year,
                              calendarMonth.month,
                              newDay,
                            );
                          });
                          _loadSlots();
                        },
                      ),
                    ],
                  ),
                  // Mini calendrier horizontal du mois
                  SizedBox(
                    height: 70,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount:
                          DateTime(
                            calendarMonth.year,
                            calendarMonth.month + 1,
                            0,
                          ).day,
                      itemBuilder: (context, i) {
                        final day = i + 1;
                        final date = DateTime(
                          calendarMonth.year,
                          calendarMonth.month,
                          day,
                        );
                        final isSelected =
                            selectedDate.year == date.year &&
                            selectedDate.month == date.month &&
                            selectedDate.day == day;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedDate = date;
                            });
                            _loadSlots();
                          },
                          child: Container(
                            width: 48,
                            margin: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.teal : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.teal, width: 1),
                              boxShadow: [
                                if (isSelected)
                                  BoxShadow(
                                    color: Colors.teal.withOpacity(0.15),
                                    blurRadius: 8,
                                  ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  [
                                    'Lun',
                                    'Mar',
                                    'Mer',
                                    'Jeu',
                                    'Ven',
                                    'Sam',
                                    'Dim',
                                  ][date.weekday - 1],
                                  style: TextStyle(
                                    color:
                                        isSelected ? Colors.white : Colors.teal,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  day.toString(),
                                  style: TextStyle(
                                    color:
                                        isSelected
                                            ? Colors.white
                                            : Colors.black87,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Carte profil simple
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.08),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 36,
                          backgroundImage: AssetImage(widget.doctor.image),
                          backgroundColor: Colors.grey[200],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          widget.doctor.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.doctor.specialty,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.teal,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Créneaux disponibles pour le ${selectedDate.day.toString().padLeft(2, '0')}/${selectedDate.month.toString().padLeft(2, '0')}/${selectedDate.year}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (slots.isEmpty)
                    Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.event_busy,
                            color: Colors.grey[400],
                            size: 60,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            "Aucune disponibilité pour ce jour.",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (slots.isNotEmpty)
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        for (int i = 0; i < slots.length; i++)
                          FilterChip(
                            label: Text(
                              slots[i]['time'] ?? '',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            selected: selectedSlotIndices.contains(i),
                            selectedColor: Colors.teal,
                            backgroundColor: Colors.white,
                            labelStyle: TextStyle(
                              color:
                                  selectedSlotIndices.contains(i)
                                      ? Colors.white
                                      : Colors.teal,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(
                                color: Colors.teal.withOpacity(0.2),
                              ),
                            ),
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  selectedSlotIndices.add(i);
                                  if (!selectedDates.contains(selectedDate)) {
                                    selectedDates.add(selectedDate);
                                  }
                                } else {
                                  selectedSlotIndices.remove(i);
                                  // Si plus aucun créneau sélectionné pour ce jour, on retire la date
                                  if (!selectedSlotIndices.any(
                                    (idx) => slots[idx]['date'] == selectedDate,
                                  )) {
                                    selectedDates.remove(selectedDate);
                                  }
                                }
                              });
                            },
                          ),
                      ],
                    ),
                  const SizedBox(height: 30),
                  if (selectedSlotIndices.isNotEmpty)
                    Card(
                      color: Colors.grey[50],
                      margin: const EdgeInsets.only(bottom: 20),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Résumé de la réservation',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 10),
                            for (int idx in selectedSlotIndices)
                              Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    size: 16,
                                    color: Colors.teal,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${selectedDate.day.toString().padLeft(2, '0')}/${selectedDate.month.toString().padLeft(2, '0')}/${selectedDate.year} - ${slots[idx]['time']}',
                                    style: const TextStyle(fontSize: 15),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),
                  Center(
                    child: SizedBox(
                      width: 260,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[800],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed:
                            selectedSlotIndices.isEmpty || isBooking
                                ? null
                                : () async {
                                  setState(() {
                                    isBooking = true;
                                  });
                                  bool allSuccess = true;
                                  for (int idx in selectedSlotIndices) {
                                    String startTime = slots[idx]['time'];
                                    String hour =
                                        startTime.contains('-')
                                            ? startTime.split('-')[0]
                                            : startTime;
                                    String dateStr =
                                        '${selectedDate.year.toString().padLeft(4, '0')}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}';
                                    String datetimeIso =
                                        '${dateStr}T$hour:00.000Z';
                                    final success =
                                        await PatientApiService.bookAppointment(
                                          doctorId: widget.doctor.id,
                                          datetime: datetimeIso,
                                          reason: 'Consultation',
                                        );
                                    if (!success) allSuccess = false;
                                  }
                                  setState(() {
                                    isBooking = false;
                                    selectedSlotIndices.clear();
                                    selectedDates.clear();
                                  });
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          allSuccess
                                              ? 'Tous les rendez-vous ont été réservés !'
                                              : 'Certains créneaux n\'ont pas pu être réservés.',
                                        ),
                                        backgroundColor:
                                            allSuccess
                                                ? Colors.teal
                                                : Colors.red,
                                      ),
                                    );
                                  }
                                },
                        child:
                            isBooking
                                ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                                : const Text(
                                  'Confirmer la réservation',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
    );
  }

  String _monthName(int month) {
    const months = [
      'Janvier',
      'Février',
      'Mars',
      'Avril',
      'Mai',
      'Juin',
      'Juillet',
      'Août',
      'Septembre',
      'Octobre',
      'Novembre',
      'Décembre',
    ];
    return months[month - 1];
  }
}
