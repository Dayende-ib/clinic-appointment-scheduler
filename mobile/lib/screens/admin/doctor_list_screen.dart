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
      appBar: AppBar(title: const Text('Liste des Médecins')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Rechercher un médecin',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: onSearch,
            ),
            const SizedBox(height: 8),
            Expanded(
              child:
                  filteredDoctors.isEmpty
                      ? const Center(child: Text('Aucun médecin trouvé.'))
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
                                  filteredDoctors[i]['active']
                                      ? 'Actif'
                                      : 'Désactivé',
                                  style: TextStyle(
                                    color:
                                        filteredDoctors[i]['active']
                                            ? Colors.green
                                            : Colors.red,
                                  ),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        filteredDoctors[i]['active']
                                            ? Icons.block
                                            : Icons.check,
                                        color: Colors.orange,
                                      ),
                                      tooltip:
                                          filteredDoctors[i]['active']
                                              ? 'Désactiver'
                                              : 'Activer',
                                      onPressed:
                                          () => onToggle(
                                            doctors.indexOf(filteredDoctors[i]),
                                          ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      tooltip: 'Supprimer',
                                      onPressed:
                                          () => onRemove(
                                            doctors.indexOf(filteredDoctors[i]),
                                          ),
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
