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
      appBar: AppBar(title: const Text('Liste des Patients')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Rechercher un patient',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: onSearch,
            ),
            const SizedBox(height: 8),
            Expanded(
              child:
                  filteredPatients.isEmpty
                      ? const Center(child: Text('Aucun patient trouvé.'))
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
                                  filteredPatients[i]['active']
                                      ? 'Actif'
                                      : 'Désactivé',
                                  style: TextStyle(
                                    color:
                                        filteredPatients[i]['active']
                                            ? Colors.green
                                            : Colors.red,
                                  ),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        filteredPatients[i]['active']
                                            ? Icons.block
                                            : Icons.check,
                                        color: Colors.orange,
                                      ),
                                      tooltip:
                                          filteredPatients[i]['active']
                                              ? 'Désactiver'
                                              : 'Activer',
                                      onPressed:
                                          () => onToggle(
                                            patients.indexOf(
                                              filteredPatients[i],
                                            ),
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
                                            patients.indexOf(
                                              filteredPatients[i],
                                            ),
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
