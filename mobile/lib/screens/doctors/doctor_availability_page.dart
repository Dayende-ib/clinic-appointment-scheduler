import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class DoctorAvailabilityPage extends StatefulWidget {
  const DoctorAvailabilityPage({super.key});

  @override
  State<DoctorAvailabilityPage> createState() => _DoctorAvailabilityPageState();
}

class _DoctorAvailabilityPageState extends State<DoctorAvailabilityPage> {
  DateTime? selectedDate;
  List<Map<String, String>> slots = [];
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  bool isLoading = false;

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) setState(() => selectedDate = date);
  }

  Future<void> _pickTime({required bool isStart}) async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time != null) {
      setState(() {
        if (isStart) {
          startTime = time;
        } else {
          endTime = time;
        }
      });
    }
  }

  void _addSlot() {
    if (startTime != null && endTime != null) {
      slots.add({
        'start': startTime!.format(context),
        'end': endTime!.format(context),
      });
      setState(() {
        startTime = null;
        endTime = null;
      });
    }
  }

  Future<void> _saveAvailability() async {
    if (selectedDate == null || slots.isEmpty) return;
    setState(() => isLoading = true);

    // Récupération du token depuis SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    // Remplace l'URL par celle de ton backend
    final url = Uri.parse('http://localhost:5000/api/availability');

    final slotList =
        slots
            .map((slot) => {'start': slot['start'], 'end': slot['end']})
            .toList();

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'date': DateFormat('yyyy-MM-dd').format(selectedDate!),
        'slots': slotList,
      }),
    );

    setState(() => isLoading = false);

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Créneaux sauvegardés !')));
      setState(() {
        slots.clear();
        selectedDate = null;
      });
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur : ${response.body}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mes disponibilités')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  selectedDate == null
                      ? 'Aucune date'
                      : DateFormat('dd/MM/yyyy').format(selectedDate!),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _pickDate,
                  child: const Text('Choisir une date'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () => _pickTime(isStart: true),
                  child: Text(
                    startTime == null ? 'Début' : startTime!.format(context),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _pickTime(isStart: false),
                  child: Text(
                    endTime == null ? 'Fin' : endTime!.format(context),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addSlot,
                  child: const Text('Ajouter créneau'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: slots.length,
                itemBuilder: (context, index) {
                  final slot = slots[index];
                  return ListTile(
                    title: Text('${slot['start']} - ${slot['end']}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        setState(() => slots.removeAt(index));
                      },
                    ),
                  );
                },
              ),
            ),
            isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                  onPressed: _saveAvailability,
                  child: const Text('Sauvegarder'),
                ),
          ],
        ),
      ),
    );
  }
}
