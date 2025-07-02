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

  Future<void> _addFullWeekSlots() async {
    setState(() => isLoading = true);
    final weekDates = getWeekDates();
    for (final date in weekDates) {
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
    await _loadWeekAvailabilities();
    setState(() => isLoading = false);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Full week availabilities added!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final weekDates = getWeekDates();
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Availabilities'),
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: _showAddSlotSheet),
        ],
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : weekAvailabilities.isEmpty
              ? const Center(child: Text('No availabilities yet.'))
              : ListView(
                padding: const EdgeInsets.all(16),
                children:
                    weekDates.map((date) {
                      final key = DateFormat('yyyy-MM-dd').format(date);
                      final slots = weekAvailabilities[key] ?? [];
                      if (slots.isEmpty) return const SizedBox.shrink();
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      DateFormat(
                                        'EEEE, dd MMMM',
                                        'en_US',
                                      ).format(date),
                                      style:
                                          Theme.of(
                                            context,
                                          ).textTheme.titleMedium,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.close,
                                      color: Colors.red,
                                    ),
                                    tooltip: 'Delete all slots for this day',
                                    onPressed: () async {
                                      final success =
                                          await DoctorAvailabilityService.deleteAvailabilityForDate(
                                            date,
                                          );
                                      await _loadWeekAvailabilities();
                                      if (!mounted) return;
                                      if (success) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'All slots deleted for this day.',
                                            ),
                                          ),
                                        );
                                      } else {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Error while deleting slots.',
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                children: [
                                  for (int i = 0; i < slots.length; i++)
                                    Chip(
                                      label: Text(
                                        '${slots[i]['start']} - ${slots[i]['end']}',
                                      ),
                                      onDeleted: () async {
                                        // Suppression d'un créneau
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
                                          const SnackBar(
                                            content: Text('Slot deleted.'),
                                          ),
                                        );
                                      },
                                    ),
                                ],
                              ),
                              Row(
                                children: [
                                  ElevatedButton(
                                    onPressed: _addFullWeekSlots,
                                    child: const Text('Full Week'),
                                  ),
                                ],
                              ),
                            ],
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

  List<DateTime> getWeekDates() {
    final today = DateTime.now();
    final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
    return List.generate(7, (i) => startOfWeek.add(Duration(days: i)))
        .where((d) => !d.isBefore(DateTime(today.year, today.month, today.day)))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final weekDates = getWeekDates();
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
          SizedBox(
            height: 70,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: weekDates.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final date = weekDates[i];
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
                  final weekDates = getWeekDates();
                  for (final date in weekDates) {
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
                            'Full week availabilities added!',
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
                child: const Text('Full Week'),
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
