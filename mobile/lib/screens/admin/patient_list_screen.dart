import 'package:flutter/material.dart';

class PatientListScreen extends StatelessWidget {
  final List<Map<String, dynamic>> patients;
  final void Function(int) onToggle;
  final void Function(int) onRemove;
  final String search;
  final void Function(String) onSearch;

  const PatientListScreen({
    super.key,
    required this.patients,
    required this.onToggle,
    required this.onRemove,
    required this.search,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    final filteredPatients =
        patients
            .where(
              (p) => p['name'].toLowerCase().contains(search.toLowerCase()),
            )
            .toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Patient List')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Search for a patient',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: onSearch,
            ),
            const SizedBox(height: 8),
            Expanded(
              child:
                  filteredPatients.isEmpty
                      ? const Center(child: Text('No patient found.'))
                      : ListView.builder(
                        itemCount: filteredPatients.length,
                        itemBuilder:
                            (context, i) => Card(
                              child: ListTile(
                                leading: const Icon(
                                  Icons.person,
                                  color: Colors.blue,
                                ),
                                title: Text(
                                  filteredPatients[i]['name'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  filteredPatients[i]['email'] ?? '',
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.toggle_on),
                                      onPressed: () => onToggle(i),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      onPressed: () => onRemove(i),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
