import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../strings.dart';
import '../../app_colors.dart';

class AvailabilityScreen extends StatefulWidget {
  const AvailabilityScreen({super.key});

  @override
  State<AvailabilityScreen> createState() => _AvailabilityScreenState();
}

class _AvailabilityScreenState extends State<AvailabilityScreen> {
  // Utiliser des formateurs de date statiques pour la performance.
  static final _dbDateFormat = DateFormat('yyyy-MM-dd');
  static final _displayDateFormat = DateFormat('MM/dd');
  static final _headerDateFormat = DateFormat('MM/dd/yyyy');

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
    _dbDateFormat.format(DateTime.now()): {'09:00', '15:00'},
  };

  DateTime selectedWeekStart = DateTime.now();

  @override
  void initState() {
    super.initState();
    _resetToCurrentWeek();
  }

  void _resetToCurrentWeek() {
    // Aligne le début de semaine sur Lundi (weekday 1)
    selectedWeekStart = DateTime.now().subtract(
      Duration(days: DateTime.now().weekday - 1),
    );
  }

  void toggleSlot(DateTime day, String hour) {
    final dateStr = _dbDateFormat.format(day);
    setState(() {
      if (busySlots[dateStr]?.contains(hour) ?? false) {
        return; // Ne pas modifier les créneaux occupés
      }
      availableSlots.putIfAbsent(dateStr, () => <String>{});
      if (availableSlots[dateStr]!.contains(hour)) {
        availableSlots[dateStr]!.remove(hour);
      } else {
        availableSlots[dateStr]!.add(hour);
      }
    });
  }

  void toggleDay(DateTime day) {
    final dateStr = _dbDateFormat.format(day);
    setState(() {
      availableSlots.putIfAbsent(dateStr, () => <String>{});
      // Vérifie si tous les créneaux *modifiables* sont déjà sélectionnés
      final modifiableSlots = timeSlots.where(
        (h) => !(busySlots[dateStr]?.contains(h) ?? false),
      );
      final allSelected = modifiableSlots.every(
        (h) => availableSlots[dateStr]!.contains(h),
      );

      for (final hour in modifiableSlots) {
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
      // Détermine si l'action sera de tout sélectionner ou désélectionner.
      // Si au moins un créneau modifiable pour cette heure n'est pas sélectionné, on sélectionne tout.
      final shouldSelectAll = List.generate(7, (i) {
        final day = selectedWeekStart.add(Duration(days: i));
        final dateStr = _dbDateFormat.format(day);
        final isBusy = busySlots[dateStr]?.contains(hour) ?? false;
        final isAvailable = availableSlots[dateStr]?.contains(hour) ?? false;
        return !isBusy && !isAvailable;
      }).any((e) => e);

      for (int i = 0; i < 7; i++) {
        final day = selectedWeekStart.add(Duration(days: i));
        final dateStr = _dbDateFormat.format(day);
        availableSlots.putIfAbsent(dateStr, () => <String>{});
        if (busySlots[dateStr]?.contains(hour) ?? false) continue;
        if (shouldSelectAll) {
          availableSlots[dateStr]!.add(hour);
        } else {
          availableSlots[dateStr]!.remove(hour);
        }
      }
    });
  }

  // Helper to get a readable summary of selected slots
  String getSelectedSlotsSummary() {
    int total = 0;
    availableSlots.forEach((_, slots) => total += slots.length);
    return total == 0 ? 'No slot selected.' : 'Selected slots: $total';
  }

  Widget _legendBox({Color? color, IconData? icon, required String label}) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: color,
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(6),
          ),
          child:
              icon != null ? Icon(icon, size: 16, color: Colors.white) : null,
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 13)),
      ],
    );
  }

  Future<void> saveSlots() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
    await Future.delayed(const Duration(seconds: 1));
    Navigator.of(context).pop();
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
                  '${AppStrings.enWeekOf} ${_headerDateFormat.format(selectedWeekStart)}',
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(color: AppColors.primary),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.today),
                      tooltip: 'Go to current week',
                      onPressed: () {
                        setState(_resetToCurrentWeek);
                      },
                    ),
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
            const SizedBox(height: 8),
            // Legend
            Row(
              children: [
                _legendBox(
                  color: Colors.red[200],
                  icon: Icons.block,
                  label: 'Busy',
                ),
                const SizedBox(width: 12),
                _legendBox(
                  color: AppColors.primary,
                  icon: Icons.check,
                  label: 'Available',
                ),
                const SizedBox(width: 12),
                _legendBox(color: Colors.grey[100], icon: null, label: 'Empty'),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              getSelectedSlotsSummary(),
              style: const TextStyle(fontWeight: FontWeight.w500),
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
                                _displayDateFormat.format(day),
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
                                _SlotCell(
                                  isBusy: isBusy,
                                  isAvailable: isAvailable,
                                  onTap: () => toggleSlot(day, hour),
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
                  foregroundColor:
                      Colors.white, // Texte en blanc pour contraste
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

/// Widget représentant une seule cellule de créneau horaire.
/// Le sortir du `build` principal améliore la lisibilité et la réutilisabilité.
class _SlotCell extends StatelessWidget {
  final bool isBusy;
  final bool isAvailable;
  final VoidCallback onTap;

  const _SlotCell({
    required this.isBusy,
    required this.isAvailable,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color color;
    final Color borderColor;
    final Widget? child;

    if (isBusy) {
      color = Colors.red[200]!;
      borderColor = Colors.red;
      child = const Icon(Icons.block, color: Colors.red, size: 18);
    } else if (isAvailable) {
      color = AppColors.primary;
      borderColor = AppColors.primary;
      child = const Icon(Icons.check, color: Colors.white, size: 18);
    } else {
      color = Colors.grey[100]!;
      borderColor = Colors.grey;
      child = null;
    }

    return GestureDetector(
      onTap: isBusy ? null : onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: color,
          border: Border.all(color: borderColor),
          borderRadius: BorderRadius.circular(8),
        ),
        child: child,
      ),
    );
  }
}
