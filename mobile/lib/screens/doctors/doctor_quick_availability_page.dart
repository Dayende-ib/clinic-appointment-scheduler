import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/doctor_availability_service.dart';

class DoctorQuickAvailabilityPage extends StatefulWidget {
  const DoctorQuickAvailabilityPage({super.key});

  @override
  State<DoctorQuickAvailabilityPage> createState() =>
      _DoctorQuickAvailabilityPageState();
}

class _DoctorQuickAvailabilityPageState
    extends State<DoctorQuickAvailabilityPage> {
  bool isLoading = false;
  Map<String, List<Map<String, String>>> weekAvailabilities = {};

  final List<String> morningSlots = ['08:00', '09:00', '10:00', '11:00'];
  final List<String> afternoonSlots = ['14:00', '15:00', '16:00', '17:00'];
  final List<String> eveningSlots = ['18:00', '19:00', '20:00'];

  List<DateTime> getWeekDates() {
    final today = DateTime.now();
    final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
    return List.generate(7, (i) => startOfWeek.add(Duration(days: i)))
        .where((d) => !d.isBefore(DateTime(today.year, today.month, today.day)))
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _loadWeekAvailabilities();
  }

  Future<void> _loadWeekAvailabilities() async {
    setState(() => isLoading = true);
    final dates = getWeekDates();
    Map<String, List<Map<String, String>>> result = {};
    for (final date in dates) {
      final slots = await DoctorAvailabilityService.getAvailabilityForDate(
        date,
      );
      if (slots.isNotEmpty) {
        result[DateFormat('yyyy-MM-dd').format(date)] = slots;
      }
    }
    setState(() {
      weekAvailabilities = result;
      isLoading = false;
    });
  }

  void _showAddSlotSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder:
          (context) => Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: _AddSlotSheet(
              morningSlots: morningSlots,
              afternoonSlots: afternoonSlots,
              eveningSlots: eveningSlots,
              onSaved: (date, slots) async {
                setState(() => isLoading = true);
                final formattedSlots =
                    slots
                        .map(
                          (slot) => {
                            'time': '${slot['start']}-${slot['end']}',
                            'available': true,
                          },
                        )
                        .toList();
                final success =
                    await DoctorAvailabilityService.addAvailabilityV2(
                      date: date,
                      slots: formattedSlots,
                    );
                if (success) {
                  if (!mounted) return;
                  Navigator.pop(context);
                  await _loadWeekAvailabilities();
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Availability saved!')),
                  );
                } else {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Error while saving.')),
                  );
                }
                setState(() => isLoading = false);
              },
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final weekDates = getWeekDates();
    final Color mainColor = const Color(0xFF03A6A1);
    final Color accentColor = const Color(0xFF0891B2);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mainColor,
        elevation: 0,
        title: const Text(
          'My Availabilities',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: false,
        automaticallyImplyLeading: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: accentColor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add'),
        onPressed: _showAddSlotSheet,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
      ),
      backgroundColor: const Color(0xFFF5F7FA),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : weekAvailabilities.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.event_busy, size: 64, color: Colors.grey[300]),
                    const SizedBox(height: 18),
                    const Text(
                      'No availabilities yet.',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.grey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              )
              : ListView(
                padding: const EdgeInsets.all(20),
                children:
                    weekDates.map((date) {
                      final key = DateFormat('yyyy-MM-dd').format(date);
                      final slots = weekAvailabilities[key] ?? [];
                      if (slots.isEmpty) return const SizedBox.shrink();
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        margin: const EdgeInsets.only(bottom: 22),
                        child: Card(
                          elevation: 6,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          color: const Color(0xFFE6F7FA),
                          child: Padding(
                            padding: const EdgeInsets.all(22),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: mainColor.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Text(
                                        DateFormat(
                                          'EEE, dd MMM',
                                          'en_US',
                                        ).format(date),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF0891B2),
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Wrap(
                                  spacing: 12,
                                  runSpacing: 10,
                                  children: [
                                    for (int i = 0; i < slots.length; i++)
                                      AnimatedContainer(
                                        duration: const Duration(
                                          milliseconds: 250,
                                        ),
                                        curve: Curves.easeInOut,
                                        child: Chip(
                                          label: Text(
                                            '${slots[i]['start']} - ${slots[i]['end']}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF0891B2),
                                              fontSize: 15,
                                            ),
                                          ),
                                          backgroundColor: Colors.white,
                                          elevation: 2,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                          ),
                                          deleteIcon: const Icon(
                                            Icons.close,
                                            size: 18,
                                            color: Colors.redAccent,
                                          ),
                                          onDeleted: () async {
                                            slots.removeAt(i);
                                            await DoctorAvailabilityService.addAvailability(
                                              date: date,
                                              slots: slots,
                                            );
                                            await _loadWeekAvailabilities();
                                            if (!mounted) return;
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Row(
                                                  children: const [
                                                    Icon(
                                                      Icons.check_circle,
                                                      color: Colors.white,
                                                    ),
                                                    SizedBox(width: 8),
                                                    Text('Slot deleted.'),
                                                  ],
                                                ),
                                                backgroundColor: mainColor,
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
              ),
    );
  }
}

class _AddSlotSheet extends StatefulWidget {
  final List<String> morningSlots;
  final List<String> afternoonSlots;
  final List<String> eveningSlots;
  final Function(DateTime, List<Map<String, String>>) onSaved;
  const _AddSlotSheet({
    required this.morningSlots,
    required this.afternoonSlots,
    required this.eveningSlots,
    required this.onSaved,
  });

  @override
  State<_AddSlotSheet> createState() => _AddSlotSheetState();
}

class _AddSlotSheetState extends State<_AddSlotSheet> {
  DateTime selectedDate = DateTime.now();
  Set<String> selectedSlots = {};
  DateTime displayedMonth = DateTime(DateTime.now().year, DateTime.now().month);

  List<DateTime> getMonthDates() {
    final lastDay =
        DateTime(displayedMonth.year, displayedMonth.month + 1, 0).day;
    return List.generate(
      lastDay,
      (i) => DateTime(displayedMonth.year, displayedMonth.month, i + 1),
    ).where((d) {
      // Si mois courant, on ne montre que les jours >= aujourd'hui
      if (displayedMonth.year == DateTime.now().year &&
          displayedMonth.month == DateTime.now().month) {
        return !d.isBefore(DateTime.now());
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final monthDates = getMonthDates();
    final monthLabel = DateFormat('MMMM yyyy').format(displayedMonth);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Add Availability',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          // Sélecteur de mois
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () {
                  setState(() {
                    displayedMonth = DateTime(
                      displayedMonth.year,
                      displayedMonth.month - 1,
                    );
                    // Si on revient sur le mois courant et la date sélectionnée est passée, on la remet à aujourd'hui
                    if (displayedMonth.year == DateTime.now().year &&
                        displayedMonth.month == DateTime.now().month &&
                        selectedDate.isBefore(DateTime.now())) {
                      selectedDate = DateTime.now();
                    }
                  });
                },
              ),
              Text(
                monthLabel,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () {
                  setState(() {
                    displayedMonth = DateTime(
                      displayedMonth.year,
                      displayedMonth.month + 1,
                    );
                    // Si on avance, on sélectionne le 1er du mois si la date sélectionnée n'est pas dans ce mois
                    if (displayedMonth.month != selectedDate.month ||
                        displayedMonth.year != selectedDate.year) {
                      selectedDate = DateTime(
                        displayedMonth.year,
                        displayedMonth.month,
                        1,
                      );
                    }
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 70,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: monthDates.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final date = monthDates[i];
                final isSelected = DateUtils.isSameDay(date, selectedDate);
                return GestureDetector(
                  onTap: () => setState(() => selectedDate = date),
                  child: Container(
                    width: 50,
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.blue : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          DateFormat('E').format(date),
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('dd').format(date),
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.blue,
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
          Row(
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    selectedSlots.addAll([
                      '08:00',
                      '09:00',
                      '10:00',
                      '11:00',
                      '14:00',
                      '15:00',
                      '16:00',
                      '17:00',
                      '18:00',
                    ]);
                  });
                },
                child: const Text('Full Day'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () async {
                  final monthDates = getMonthDates();
                  for (final date in monthDates) {
                    final slots = [
                      {'start': '08:00', 'end': '09:00'},
                      {'start': '09:00', 'end': '10:00'},
                      {'start': '10:00', 'end': '11:00'},
                      {'start': '11:00', 'end': '12:00'},
                      {'start': '14:00', 'end': '15:00'},
                      {'start': '15:00', 'end': '16:00'},
                      {'start': '16:00', 'end': '17:00'},
                      {'start': '17:00', 'end': '18:00'},
                    ];
                    final formattedSlots =
                        slots
                            .map(
                              (slot) => {
                                'time': '${slot['start']}-${slot['end']}',
                                'available': true,
                              },
                            )
                            .toList();
                    await DoctorAvailabilityService.addAvailabilityV2(
                      date: date,
                      slots: formattedSlots,
                    );
                  }
                  if (!mounted) return;
                  Navigator.pop(context);
                  await showDialog(
                    context: context,
                    builder:
                        (context) => AlertDialog(
                          title: const Text('Success'),
                          content: const Text(
                            'Full month availabilities added!',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                  );
                },
                child: const Text('Full Month'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSlotSection('Morning Slots', widget.morningSlots),
          _buildSlotSection('Afternoon Slots', widget.afternoonSlots),
          _buildSlotSection('Evening Slots', widget.eveningSlots),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed:
                  selectedSlots.isNotEmpty &&
                          !selectedDate.isBefore(DateTime.now())
                      ? () async {
                        final slots =
                            selectedSlots.map((slot) {
                              final start = slot;
                              final startTime = TimeOfDay(
                                hour: int.parse(start.split(':')[0]),
                                minute: int.parse(start.split(':')[1]),
                              );
                              final endHour = (startTime.hour + 1) % 24;
                              final end =
                                  '${endHour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}';
                              return {'start': start, 'end': end};
                            }).toList();
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder:
                              (context) => AlertDialog(
                                title: const Text('Confirmation'),
                                content: const Text(
                                  'Are you sure you want to save these availabilities?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed:
                                        () => Navigator.of(context).pop(false),
                                    child: const Text('Cancel'),
                                  ),
                                  ElevatedButton(
                                    onPressed:
                                        () => Navigator.of(context).pop(true),
                                    child: const Text('Confirm'),
                                  ),
                                ],
                              ),
                        );
                        if (confirm == true) {
                          widget.onSaved(selectedDate, slots);
                        }
                      }
                      : null,
              child: const Text('Save'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlotSection(String title, List<String> slots) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              slots
                  .map(
                    (slot) => ChoiceChip(
                      label: Text(slot),
                      selected: selectedSlots.contains(slot),
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            selectedSlots.add(slot);
                          } else {
                            selectedSlots.remove(slot);
                          }
                        });
                      },
                    ),
                  )
                  .toList(),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
