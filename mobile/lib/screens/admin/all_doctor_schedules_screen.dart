import 'package:flutter/material.dart';
import '../../services/doctor_availability_service.dart';
import '../../app_theme.dart';

class AllDoctorSchedulesScreen extends StatefulWidget {
  final List<Map<String, dynamic>> doctors;
  const AllDoctorSchedulesScreen({super.key, required this.doctors});

  @override
  State<AllDoctorSchedulesScreen> createState() =>
      _AllDoctorSchedulesScreenState();
}

class _AllDoctorSchedulesScreenState extends State<AllDoctorSchedulesScreen> {
  String search = '';
  Map<String, List<Map<String, String>>> doctorPlannings = {};
  Set<String> loadingDoctors = {};

  @override
  void initState() {
    super.initState();
    _loadAllPlannings();
  }

  Future<void> _loadAllPlannings() async {
    for (final doctor in widget.doctors) {
      final doctorId = doctor['id'] ?? doctor['_id'] ?? '';
      if (doctorId.isEmpty) continue;
      setState(() => loadingDoctors.add(doctorId));
      final today = DateTime.now();
      final slots = await DoctorAvailabilityService.getAvailabilityForDate(
        today,
        doctorId: doctorId,
      );
      setState(() {
        doctorPlannings[doctorId] = slots;
        loadingDoctors.remove(doctorId);
      });
    }
  }

  // Les médecins doivent être fournis dynamiquement via widget.doctors
  List<Map<String, dynamic>> get allDoctors => widget.doctors;

  // Les plannings doivent être fournis dynamiquement ou via une source réelle
  Map<String, List<Map<String, String>>> getMonthlySchedules() {
    return {};
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> doctors = widget.doctors;
    return Scaffold(
      appBar: AppBar(title: const Text('Plannings des docteurs')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Rechercher un médecin',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) => setState(() => search = value),
            ),
            const SizedBox(height: 8),
            Expanded(
              child:
                  doctors.isEmpty
                      ? const Center(
                        child: Text(
                          'Aucun médecin sélectionné.',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      )
                      : ListView(
                        children:
                            doctors.map((doctor) {
                              final String name =
                                  ((doctor['firstname'] ?? '') +
                                          ' ' +
                                          (doctor['lastname'] ?? ''))
                                      .trim();
                              final String displayName =
                                  name.isNotEmpty ? name : 'Nom inconnu';
                              final String email = doctor['email'] ?? '';
                              final String specialty =
                                  doctor['specialty'] ?? 'Spécialité inconnue';
                              final doctorId =
                                  doctor['id'] ?? doctor['_id'] ?? '';
                              final planning = doctorPlannings[doctorId] ?? [];
                              final isLoading = loadingDoctors.contains(
                                doctorId,
                              );
                              final isSingle = doctors.length == 1;
                              if (isSingle) {
                                // Affichage direct sans ExpansionTile
                                return Card(
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 8,
                                    horizontal: 0,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          displayName,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          '$email\n$specialty',
                                          style: const TextStyle(
                                            color: Colors.grey,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        if (isLoading)
                                          const Text(
                                            'Chargement du planning...',
                                          )
                                        else if (planning.isEmpty)
                                          const Text(
                                            'Aucun planning disponible pour ce médecin.',
                                            style: TextStyle(
                                              color: Colors.redAccent,
                                            ),
                                          )
                                        else
                                          ...planning
                                              .take(3)
                                              .map(
                                                (s) => Container(
                                                  margin:
                                                      const EdgeInsets.symmetric(
                                                        vertical: 4,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: AppColors.primary
                                                        .withOpacity(0.08),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          10,
                                                        ),
                                                  ),
                                                  child: ListTile(
                                                    leading: const Icon(
                                                      Icons.access_time,
                                                      color: AppColors.primary,
                                                    ),
                                                    title: Text(
                                                      '${s['start']} - ${s['end']}',
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    subtitle: Text(
                                                      'Créneau disponible',
                                                      style: TextStyle(
                                                        color:
                                                            AppColors
                                                                .textSecondary,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                        if (!isLoading && planning.length > 3)
                                          TextButton(
                                            style: TextButton.styleFrom(
                                              foregroundColor: Colors.white,
                                              backgroundColor: AppColors.accent,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                            ),
                                            onPressed: () {
                                              showModalBottomSheet(
                                                context: context,
                                                shape:
                                                    const RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.vertical(
                                                            top:
                                                                Radius.circular(
                                                                  20,
                                                                ),
                                                          ),
                                                    ),
                                                builder:
                                                    (context) => Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                            20,
                                                          ),
                                                      height: 400,
                                                      decoration: BoxDecoration(
                                                        color:
                                                            AppColors
                                                                .background,
                                                        borderRadius:
                                                            const BorderRadius.vertical(
                                                              top:
                                                                  Radius.circular(
                                                                    20,
                                                                  ),
                                                            ),
                                                      ),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          const Text(
                                                            'Tous les créneaux',
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 18,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            height: 16,
                                                          ),
                                                          Expanded(
                                                            child: ListView.builder(
                                                              itemCount:
                                                                  planning
                                                                      .length,
                                                              itemBuilder:
                                                                  (
                                                                    context,
                                                                    i,
                                                                  ) => Container(
                                                                    margin: const EdgeInsets.symmetric(
                                                                      vertical:
                                                                          4,
                                                                      horizontal:
                                                                          8,
                                                                    ),
                                                                    decoration: BoxDecoration(
                                                                      color:
                                                                          i % 2 == 0
                                                                              ? AppColors.primary.withOpacity(
                                                                                0.08,
                                                                              )
                                                                              : AppColors.secondary.withOpacity(0.08),
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                            10,
                                                                          ),
                                                                    ),
                                                                    child: ListTile(
                                                                      leading: const Icon(
                                                                        Icons
                                                                            .access_time,
                                                                        color:
                                                                            AppColors.primary,
                                                                      ),
                                                                      title: Text(
                                                                        '${planning[i]['start']} - ${planning[i]['end']}',
                                                                        style: const TextStyle(
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                        ),
                                                                      ),
                                                                      subtitle: Text(
                                                                        'Créneau disponible',
                                                                        style: TextStyle(
                                                                          color:
                                                                              AppColors.textSecondary,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                              );
                                            },
                                            child: const Text(
                                              'Voir tout le planning',
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                );
                              } else {
                                // Cas multi-docteurs (ExpansionTile)
                                return ExpansionTile(
                                  title: Text(displayName),
                                  subtitle: Text('$email\n$specialty'),
                                  children:
                                      isLoading
                                          ? [
                                            const ListTile(
                                              title: Text(
                                                'Chargement du planning...',
                                              ),
                                            ),
                                          ]
                                          : planning.isEmpty
                                          ? [
                                            const ListTile(
                                              title: Text(
                                                'Aucun planning disponible.',
                                              ),
                                            ),
                                          ]
                                          : [
                                            ...List<Map<String, String>>.from(
                                              planning.take(3),
                                            ).asMap().entries.map((entry) {
                                              final i = entry.key;
                                              final s = entry.value;
                                              return Container(
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 4,
                                                      horizontal: 8,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color:
                                                      i % 2 == 0
                                                          ? AppColors.primary
                                                              .withOpacity(0.08)
                                                          : AppColors.secondary
                                                              .withOpacity(
                                                                0.08,
                                                              ),
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                child: ListTile(
                                                  leading: const Icon(
                                                    Icons.access_time,
                                                    color: AppColors.primary,
                                                  ),
                                                  title: Text(
                                                    '${s['start']} - ${s['end']}',
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  subtitle: Text(
                                                    'Créneau disponible',
                                                    style: TextStyle(
                                                      color:
                                                          AppColors
                                                              .textSecondary,
                                                    ),
                                                  ),
                                                ),
                                              );
                                            }),
                                            if (planning.length > 3)
                                              ListTile(
                                                title: TextButton(
                                                  style: TextButton.styleFrom(
                                                    foregroundColor:
                                                        Colors.white,
                                                    backgroundColor:
                                                        AppColors.accent,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                    ),
                                                  ),
                                                  onPressed: () {
                                                    showModalBottomSheet(
                                                      context: context,
                                                      shape: const RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.vertical(
                                                              top:
                                                                  Radius.circular(
                                                                    20,
                                                                  ),
                                                            ),
                                                      ),
                                                      builder:
                                                          (
                                                            context,
                                                          ) => Container(
                                                            padding:
                                                                const EdgeInsets.all(
                                                                  20,
                                                                ),
                                                            height: 400,
                                                            decoration: BoxDecoration(
                                                              color:
                                                                  AppColors
                                                                      .background,
                                                              borderRadius:
                                                                  const BorderRadius.vertical(
                                                                    top:
                                                                        Radius.circular(
                                                                          20,
                                                                        ),
                                                                  ),
                                                            ),
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                const Text(
                                                                  'Tous les créneaux',
                                                                  style: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize:
                                                                        18,
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                  height: 16,
                                                                ),
                                                                Expanded(
                                                                  child: ListView.builder(
                                                                    itemCount:
                                                                        planning
                                                                            .length,
                                                                    itemBuilder:
                                                                        (
                                                                          context,
                                                                          i,
                                                                        ) => Container(
                                                                          margin: const EdgeInsets.symmetric(
                                                                            vertical:
                                                                                4,
                                                                            horizontal:
                                                                                8,
                                                                          ),
                                                                          decoration: BoxDecoration(
                                                                            color:
                                                                                i %
                                                                                            2 ==
                                                                                        0
                                                                                    ? AppColors.primary.withOpacity(
                                                                                      0.08,
                                                                                    )
                                                                                    : AppColors.secondary.withOpacity(
                                                                                      0.08,
                                                                                    ),
                                                                            borderRadius: BorderRadius.circular(
                                                                              10,
                                                                            ),
                                                                          ),
                                                                          child: ListTile(
                                                                            leading: const Icon(
                                                                              Icons.access_time,
                                                                              color:
                                                                                  AppColors.primary,
                                                                            ),
                                                                            title: Text(
                                                                              '${planning[i]['start']} - ${planning[i]['end']}',
                                                                              style: const TextStyle(
                                                                                fontWeight:
                                                                                    FontWeight.bold,
                                                                              ),
                                                                            ),
                                                                            subtitle: Text(
                                                                              'Créneau disponible',
                                                                              style: TextStyle(
                                                                                color:
                                                                                    AppColors.textSecondary,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                    );
                                                  },
                                                  child: const Text(
                                                    'Voir tout le planning',
                                                  ),
                                                ),
                                              ),
                                          ],
                                );
                              }
                            }).toList(),
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
