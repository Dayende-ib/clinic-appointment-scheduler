import 'package:flutter/material.dart';
import 'package:caretime/app_colors.dart';

class DoctorProfileBottomSheet extends StatefulWidget {
  final List<String> availableTimes;
  final ValueChanged<String> onTimeSelected;

  const DoctorProfileBottomSheet({
    super.key,
    required this.availableTimes,
    required this.onTimeSelected,
  });

  @override
  State<DoctorProfileBottomSheet> createState() =>
      _DoctorProfileBottomSheetState();
}

class _DoctorProfileBottomSheetState extends State<DoctorProfileBottomSheet> {
  String? selectedTime;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Choisir un créneau',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children:
                widget.availableTimes.map((time) {
                  final isSelected = selectedTime == time;
                  return ChoiceChip(
                    label: Text(time),
                    selected: isSelected,
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                    onSelected: (_) => setState(() => selectedTime = time),
                  );
                }).toList(),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed:
                  selectedTime == null
                      ? null
                      : () {
                        Navigator.pop(context);
                        widget.onTimeSelected(selectedTime!);
                      },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text('Confirmer le rendez-vous'),
            ),
          ),
        ],
      ),
    );
  }
}
