import 'package:flutter/material.dart';
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
  final TextEditingController _noteController = TextEditingController();
  String? _selectedReason;
  final List<String> _motifs = [
    'Consultation',
    'Prescription renewal',
    'Test results',
    'Follow-up',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _loadSlots();
  }

  Future<void> _loadSlots() async {
    setState(() {
      isLoading = true;
      error = null;
      selectedSlotIndices.clear();
      selectedDates.clear();
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
        selectedSlotIndices.clear();
        selectedDates.clear();
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
        selectedSlotIndices.clear();
        selectedDates.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Doctor profile'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : error != null
              ? Center(child: Text('Error: $error'))
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
                                    'Mon',
                                    'Tue',
                                    'Wed',
                                    'Thu',
                                    'Fri',
                                    'Sat',
                                    'Sun',
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
                        Hero(
                          tag: 'doctor-avatar-${widget.doctor.id}',
                          child: CircleAvatar(
                            radius: 36,
                            backgroundImage: AssetImage(widget.doctor.image),
                            backgroundColor: Colors.grey[200],
                          ),
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
                        if (widget.doctor.phone != null &&
                            widget.doctor.phone!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.phone, size: 16, color: Colors.teal),
                                SizedBox(width: 6),
                                Text(
                                  widget.doctor.phone!,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Available slots for ${selectedDate.day.toString().padLeft(2, '0')}/${selectedDate.month.toString().padLeft(2, '0')}/${selectedDate.year}',
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
                            "No availability for this day.",
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
                          _buildSlotChip(i, slots[i]['time'], selectedDate),
                      ],
                    ),
                  const SizedBox(height: 30),
                  if (selectedSlotIndices.isNotEmpty && slots.isNotEmpty)
                    Card(
                      color: Colors.grey[50],
                      margin: const EdgeInsets.only(bottom: 20),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Booking summary',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 10),
                            for (int idx in selectedSlotIndices)
                              if (idx >= 0 && idx < slots.length)
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
                  if (selectedSlotIndices.isNotEmpty && slots.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          DropdownButtonFormField<String>(
                            value: _selectedReason,
                            decoration: const InputDecoration(
                              labelText: 'Reason',
                              border: OutlineInputBorder(),
                            ),
                            items:
                                _motifs
                                    .map(
                                      (motif) => DropdownMenuItem(
                                        value: motif,
                                        child: Text(motif),
                                      ),
                                    )
                                    .toList(),
                            onChanged:
                                (val) => setState(() => _selectedReason = val),
                            validator:
                                (val) =>
                                    val == null || val.isEmpty
                                        ? 'Please choose a reason'
                                        : null,
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _noteController,
                            maxLines: 2,
                            decoration: const InputDecoration(
                              labelText: 'Note (optional)',
                              border: OutlineInputBorder(),
                              hintText:
                                  'E.g.: I would like to discuss a specific issue...',
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
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
                            selectedSlotIndices.isEmpty ||
                                    isBooking ||
                                    slots.isEmpty
                                ? null
                                : () async {
                                  setState(() {
                                    isBooking = true;
                                  });
                                  bool allSuccess = true;
                                  for (int idx in selectedSlotIndices) {
                                    if (idx < 0 || idx >= slots.length) {
                                      continue;
                                    }
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
                                          reason:
                                              _selectedReason ?? 'Consultation',
                                          patientNotes:
                                              _noteController.text.isNotEmpty
                                                  ? _noteController.text
                                                  : null,
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
                                              ? 'All appointments have been booked!'
                                              : 'Some appointments could not be booked.',
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
                                  'Confirm booking',
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
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }

  Widget _buildSlotChip(int i, String? slotTime, DateTime date) {
    final now = DateTime.now();
    final isPastDay = date.isBefore(DateTime(now.year, now.month, now.day));
    final isToday =
        date.year == now.year && date.month == now.month && date.day == now.day;
    bool isPastSlot = false;
    if (slotTime != null && slotTime.isNotEmpty) {
      final startHour = int.tryParse(slotTime.split(':')[0]) ?? 0;
      final startMinute =
          int.tryParse(slotTime.split(':')[1].split('-')[0]) ?? 0;
      final slotDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        startHour,
        startMinute,
      );
      isPastSlot = slotDateTime.isBefore(now);
    }
    final isDisabled = isPastDay || (isToday && isPastSlot);
    return FilterChip(
      label: Text(
        slotTime ?? '',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color:
              isDisabled
                  ? Colors.grey
                  : (selectedSlotIndices.contains(i)
                      ? Colors.white
                      : Colors.teal),
        ),
      ),
      selected: selectedSlotIndices.contains(i),
      selectedColor: isDisabled ? Colors.grey[300] : Colors.teal,
      backgroundColor: isDisabled ? Colors.grey[200] : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color:
              isDisabled
                  ? Colors.grey[300]!
                  : Colors.teal.withValues(alpha: 0.2),
        ),
      ),
      onSelected:
          isDisabled
              ? null
              : (selected) {
                setState(() {
                  if (selected) {
                    selectedSlotIndices.add(i);
                    if (!selectedDates.contains(date)) {
                      selectedDates.add(date);
                    }
                  } else {
                    selectedSlotIndices.remove(i);
                    if (!selectedSlotIndices.any(
                      (idx) => slots[idx]['date'] == date,
                    )) {
                      selectedDates.remove(date);
                    }
                  }
                });
              },
    );
  }
}
