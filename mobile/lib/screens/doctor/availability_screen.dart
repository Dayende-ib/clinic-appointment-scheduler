import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../app_strings.dart';
import '../../app_colors.dart';

class AvailabilityScreen extends StatefulWidget {
  const AvailabilityScreen({super.key});

  @override
  State<AvailabilityScreen> createState() => _AvailabilityScreenState();
}

class _AvailabilityScreenState extends State<AvailabilityScreen> {
  // Simule les créneaux disponibles et occupés pour la semaine
  // Pour la traduction, on utilise AppStrings
  // Only English
  List<String> get weekDays => [
    AppStrings.enWeekdayMon,
    AppStrings.enWeekdayTue,
    AppStrings.enWeekdayWed,
    AppStrings.enWeekdayThu,
    AppStrings.enWeekdayFri,
    AppStrings.enWeekdaySat,
    AppStrings.enWeekdaySun,
  ];
  final List<String> timeSlots = [
    '08:00',
    '09:00',
    '10:00',
    '11:00',
    '12:00',
    '14:00',
    '15:00',
    '16:00',
    '17:00',
  ];
  // Map<date, Set<heure>>
  Map<String, Set<String>> availableSlots = {};
  Map<String, Set<String>> busySlots = {
    // Exemples de créneaux déjà pris
    DateFormat('yyyy-MM-dd').format(DateTime.now()): {'09:00', '15:00'},
  };

  DateTime selectedWeekStart = DateTime.now();

  @override
  void initState() {
    super.initState();
    // Aligne le début de semaine sur lundi
    selectedWeekStart = DateTime.now().subtract(
      Duration(days: DateTime.now().weekday - 1),
    );
  }

  void toggleSlot(DateTime day, String hour) {
    final dateStr = DateFormat('yyyy-MM-dd').format(day);
    setState(() {
      if (busySlots[dateStr]?.contains(hour) ?? false)
        return; // Ne pas modifier les créneaux occupés
      availableSlots.putIfAbsent(dateStr, () => <String>{});
      if (availableSlots[dateStr]!.contains(hour)) {
        availableSlots[dateStr]!.remove(hour);
      } else {
        availableSlots[dateStr]!.add(hour);
      }
    });
  }

  void toggleDay(DateTime day) {
    final dateStr = DateFormat('yyyy-MM-dd').format(day);
    setState(() {
      availableSlots.putIfAbsent(dateStr, () => <String>{});
      bool allSelected = timeSlots.every(
        (hour) =>
            (busySlots[dateStr]?.contains(hour) ?? false) ||
            availableSlots[dateStr]!.contains(hour),
      );
      for (final hour in timeSlots) {
        if (busySlots[dateStr]?.contains(hour) ?? false) continue;
        if (allSelected) {
          availableSlots[dateStr]!.remove(hour);
        } else {
          availableSlots[dateStr]!.add(hour);
        }
      }
    });
  }

  void toggleHour(String hour) {
    setState(() {
      bool allSelected = true;
      for (int i = 0; i < 7; i++) {
        final day = selectedWeekStart.add(Duration(days: i));
        final dateStr = DateFormat('yyyy-MM-dd').format(day);
        if (!(busySlots[dateStr]?.contains(hour) ?? false) &&
            !(availableSlots[dateStr]?.contains(hour) ?? false)) {
          allSelected = false;
          break;
        }
      }
      for (int i = 0; i < 7; i++) {
        final day = selectedWeekStart.add(Duration(days: i));
        final dateStr = DateFormat('yyyy-MM-dd').format(day);
        availableSlots.putIfAbsent(dateStr, () => <String>{});
        if (busySlots[dateStr]?.contains(hour) ?? false) continue;
        if (allSelected) {
          availableSlots[dateStr]!.remove(hour);
        } else {
          availableSlots[dateStr]!.add(hour);
        }
      }
    });
  }

  void saveSlots() {
    // Here, you could send the slots to the backend
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(AppStrings.enAvailabilitiesSaved)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${AppStrings.enWeekOf} ${DateFormat('MM/dd/yyyy').format(selectedWeekStart)}',
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(color: AppColors.primary),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed: () {
                        setState(() {
                          selectedWeekStart = selectedWeekStart.subtract(
                            const Duration(days: 7),
                          );
                        });
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed: () {
                        setState(() {
                          selectedWeekStart = selectedWeekStart.add(
                            const Duration(days: 7),
                          );
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(
                    AppColors.secondary.withOpacity(0.1),
                  ),
                  columns: [
                    DataColumn(
                      label: GestureDetector(
                        onTap: () {},
                        child: Text(AppStrings.enHour),
                      ),
                    ),
                    ...List.generate(7, (i) {
                      final day = selectedWeekStart.add(Duration(days: i));
                      return DataColumn(
                        label: GestureDetector(
                          onTap: () => toggleDay(day),
                          child: Column(
                            children: [
                              Text(weekDays[i], textAlign: TextAlign.center),
                              Text(
                                DateFormat('MM/dd').format(day),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                  rows:
                      timeSlots.map((hour) {
                        return DataRow(
                          cells: [
                            DataCell(
                              GestureDetector(
                                onTap: () => toggleHour(hour),
                                child: Text(
                                  hour,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ),
                            ...List.generate(7, (i) {
                              final day = selectedWeekStart.add(
                                Duration(days: i),
                              );
                              final dateStr = DateFormat(
                                'yyyy-MM-dd',
                              ).format(day);
                              final isBusy =
                                  busySlots[dateStr]?.contains(hour) ?? false;
                              final isAvailable =
                                  availableSlots[dateStr]?.contains(hour) ??
                                  false;
                              return DataCell(
                                GestureDetector(
                                  onTap:
                                      isBusy
                                          ? null
                                          : () => toggleSlot(day, hour),
                                  child: Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color:
                                          isBusy
                                              ? Colors.red[200]
                                              : isAvailable
                                              ? AppColors.primary
                                              : Colors.grey[100],
                                      border: Border.all(
                                        color:
                                            isBusy
                                                ? Colors.red
                                                : isAvailable
                                                ? AppColors.primary
                                                : Colors.grey,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child:
                                        isBusy
                                            ? const Icon(
                                              Icons.block,
                                              color: Colors.red,
                                              size: 18,
                                            )
                                            : isAvailable
                                            ? const Icon(
                                              Icons.check,
                                              color: Colors.white,
                                              size: 18,
                                            )
                                            : null,
                                  ),
                                ),
                              );
                            }),
                          ],
                        );
                      }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: Text(AppStrings.enSaveAvailabilities),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
                onPressed: saveSlots,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
