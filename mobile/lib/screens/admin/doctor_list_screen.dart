import 'package:flutter/material.dart';

class DoctorListScreen extends StatelessWidget {
  final List<Map<String, dynamic>> doctors;
  final void Function(int) onToggle;
  final void Function(int) onRemove;
  final String search;
  final void Function(String) onSearch;

  const DoctorListScreen({
    super.key,
    required this.doctors,
    required this.onToggle,
    required this.onRemove,
    required this.search,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    final filteredDoctors =
        doctors
            .where(
              (d) => d['name'].toLowerCase().contains(search.toLowerCase()),
            )
            .toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Doctor List')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Search for a doctor',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: onSearch,
            ),
            const SizedBox(height: 8),
            Expanded(
              child:
                  filteredDoctors.isEmpty
                      ? const Center(child: Text('No doctor found.'))
                      : ListView.builder(
                        itemCount: filteredDoctors.length,
                        itemBuilder:
                            (context, i) => Card(
                              child: ListTile(
                                leading: const Icon(
                                  Icons.medical_services,
                                  color: Colors.teal,
                                ),
                                title: Text(
                                  filteredDoctors[i]['name'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  filteredDoctors[i]['email'] ?? '',
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
