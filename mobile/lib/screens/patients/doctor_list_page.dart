import 'package:flutter/material.dart';
import 'doctor_profile_page.dart';
import '../../services/patient_api_service.dart';
import 'all_availability_page.dart';

class DoctorsListScreen extends StatefulWidget {
  const DoctorsListScreen({super.key});

  @override
  DoctorsListScreenState createState() => DoctorsListScreenState();
}

class DoctorsListScreenState extends State<DoctorsListScreen> {
  final Color primaryColor = Color(0xFF03A6A1);
  final Color secondaryColor = Color(0xFF0891B2);

  // Ajout d'une liste de couleurs pastel pour les cartes
  final List<Color> cardColors = [
    Color(0xFFE0F7FA), // bleu clair
    Color(0xFFFFF9C4), // jaune clair
    Color(0xFFFFF3E0), // orange très clair
    Color(0xFFE1F5FE), // bleu très pâle
    Color(0xFFF1F8E9), // vert très clair
    Color(0xFFF8BBD0), // rose très clair
    Color(0xFFD1C4E9), // violet très clair
    Color(0xFFFFECB3), // jaune pâle
    Color(0xFFC8E6C9), // vert pâle
  ];

  String? selectedSpecialty;
  int? selectedDoctorIndex;
  String? selectedCountry;
  String? selectedCity;
  String search = '';

  List<Map<String, dynamic>> doctors = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadDoctors();
  }

  Future<void> _loadDoctors() async {
    setState(() {
      isLoading = true;
      error = null;
    });
    try {
      final data = await PatientApiService.getDoctorsList();
      setState(() {
        doctors = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  final List<String> specialties = [
    'All specialties',
    'Cardiology',
    'Dermatology',
    'Pediatrics',
    'Orthopedics',
    'Endocrinology',
    'General Practitioner',
    'Physician',
    'Rheumatology',
  ];

  List<String> get countries {
    final set = <String>{};
    for (final d in doctors) {
      final c = (d['country'] ?? '').toString().trim();
      if (c.isNotEmpty) set.add(c);
    }
    return ['All countries', ...set.toList()..sort()];
  }

  List<String> get cities {
    final set = <String>{};
    for (final d in doctors) {
      if (selectedCountry != null && selectedCountry != 'All countries') {
        if ((d['country'] ?? '') != selectedCountry) continue;
      }
      final c = (d['city'] ?? '').toString().trim();
      if (c.isNotEmpty) set.add(c);
    }
    return ['All cities', ...set.toList()..sort()];
  }

  List<Doctor> get filteredDoctors {
    final searchLower = search.toLowerCase();
    return doctors
        .where((d) {
          final matchesSpecialty =
              selectedSpecialty == null ||
              selectedSpecialty == 'All specialties' ||
              d['specialty'] == selectedSpecialty;
          final matchesCountry =
              selectedCountry == null ||
              selectedCountry == 'All countries' ||
              d['country'] == selectedCountry;
          final matchesCity =
              selectedCity == null ||
              selectedCity == 'All cities' ||
              d['city'] == selectedCity;
          final matchesSearch =
              searchLower.isEmpty ||
              (d['firstname'] ?? '').toString().toLowerCase().contains(
                searchLower,
              ) ||
              (d['lastname'] ?? '').toString().toLowerCase().contains(
                searchLower,
              ) ||
              ('${d['firstname'] ?? ''} ${d['lastname'] ?? ''}')
                  .toLowerCase()
                  .contains(searchLower) ||
              (d['specialty'] ?? '').toString().toLowerCase().contains(
                searchLower,
              ) ||
              (d['country'] ?? '').toString().toLowerCase().contains(
                searchLower,
              ) ||
              (d['city'] ?? '').toString().toLowerCase().contains(searchLower);
          return matchesSpecialty &&
              matchesCountry &&
              matchesCity &&
              matchesSearch;
        })
        .map(
          (d) => Doctor(
            id: d['_id'] ?? d['id'] ?? '',
            name: '${d['firstname'] ?? ''} ${d['lastname'] ?? ''}',
            specialty: d['specialty'] ?? '',
            image: d['image'] ?? 'assets/images/male-doctor-icon.png',
            country: d['country'] ?? '',
            city: d['city'] ?? '',
            phone: d['phone'] ?? '',
          ),
        )
        .toList();
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder:
          (context) => FilterBottomSheet(
            specialties: specialties,
            selectedSpecialty: selectedSpecialty,
            primaryColor: primaryColor,
            onSpecialtySelected: (specialty) {
              setState(() {
                selectedSpecialty = specialty;
              });
              Navigator.pop(context);
            },
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (error != null) {
      return Center(child: Text('Error: $error'));
    }
    return Scaffold(
      backgroundColor: Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          "Doctors List",
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Search for a doctor...",
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                  suffixIcon: IconButton(
                    icon: Icon(
                      Icons.tune,
                      color:
                          selectedSpecialty != null &&
                                  selectedSpecialty != 'All specialties'
                              ? primaryColor
                              : Colors.grey[400],
                    ),
                    onPressed: _showFilterBottomSheet,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                onChanged: (v) => setState(() => search = v),
              ),
            ),
          ),
          if (selectedSpecialty != null &&
              selectedSpecialty != 'All specialties')
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: primaryColor.withAlpha((0.1 * 255).toInt()),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: primaryColor.withAlpha((0.3 * 255).toInt()),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          selectedSpecialty!,
                          style: TextStyle(
                            color: primaryColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(width: 8),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedSpecialty = null;
                            });
                          },
                          child: Icon(
                            Icons.close,
                            size: 16,
                            color: primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    "${filteredDoctors.length} doctor(s) found",
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButton<String>(
                    value: selectedCountry ?? 'All countries',
                    isExpanded: true,
                    items:
                        countries
                            .map(
                              (c) => DropdownMenuItem(value: c, child: Text(c)),
                            )
                            .toList(),
                    onChanged: (val) {
                      setState(() {
                        selectedCountry = val;
                        selectedCity = null; // reset city when country changes
                      });
                    },
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: DropdownButton<String>(
                    value: selectedCity ?? 'All cities',
                    isExpanded: true,
                    items:
                        cities
                            .map(
                              (c) => DropdownMenuItem(value: c, child: Text(c)),
                            )
                            .toList(),
                    onChanged: (val) {
                      setState(() {
                        selectedCity = val;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 8),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                bottom: 80,
              ), // Add bottom padding for nav bar
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.85,
                ),
                itemCount: filteredDoctors.length,
                itemBuilder: (context, index) {
                  final doctor = filteredDoctors[index];
                  final isSelected = selectedDoctorIndex == index;
                  final cardColor = cardColors[index % cardColors.length];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => DoctorProfileScreen(doctor: doctor),
                        ),
                      );
                    },
                    child: DoctorCard(
                      doctor: doctor,
                      primaryColor: primaryColor,
                      isSelected: isSelected,
                      onArrowTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                    DoctorProfileScreen(doctor: doctor),
                          ),
                        );
                      },
                      backgroundColor: cardColor,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.list_alt),
        label: const Text('View all availability'),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AllAvailabilityPage()),
          );
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
      ),
    );
  }
}

class DoctorCard extends StatelessWidget {
  final Doctor doctor;
  final Color primaryColor;
  final bool isSelected;
  final VoidCallback onArrowTap;
  final Color backgroundColor;

  const DoctorCard({
    super.key,
    required this.doctor,
    required this.primaryColor,
    required this.isSelected,
    required this.onArrowTap,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final country = doctor.country ?? '';
    final city = doctor.city ?? '';
    return Container(
      decoration: BoxDecoration(
        color: isSelected ? primaryColor : backgroundColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Hero(
                  tag: 'doctor-avatar-${doctor.id}',
                  child: CircleAvatar(
                    radius: 16,
                    backgroundImage: AssetImage(doctor.image),
                    backgroundColor:
                        isSelected
                            ? Colors.white.withAlpha((0.2 * 255).toInt())
                            : Colors.grey[200],
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    doctor.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: 4),
            Text(
              doctor.specialty,
              style: TextStyle(
                fontSize: 12,
                color:
                    isSelected
                        ? Colors.white.withAlpha((0.8 * 255).toInt())
                        : Colors.grey[600],
              ),
            ),
            if (city.isNotEmpty || country.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 2.0),
                child: Text(
                  [city, country].where((s) => s.isNotEmpty).join(', '),
                  style: TextStyle(
                    fontSize: 11,
                    color:
                        isSelected
                            ? Colors.white.withAlpha((0.7 * 255).toInt())
                            : Colors.grey[500],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            Spacer(),
            Row(
              children: [
                Spacer(),
                GestureDetector(
                  onTap: onArrowTap,
                  child: Container(
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? Colors.white.withAlpha((0.2 * 255).toInt())
                              : Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.arrow_forward,
                      size: 14,
                      color: isSelected ? Colors.white : Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class Doctor {
  final String id;
  final String name;
  final String specialty;
  final String image;
  final String? country;
  final String? city;
  final String? phone;

  Doctor({
    required this.id,
    required this.name,
    required this.specialty,
    required this.image,
    this.country,
    this.city,
    this.phone,
  });
}

class FilterBottomSheet extends StatelessWidget {
  final List<String> specialties;
  final String? selectedSpecialty;
  final Color primaryColor;
  final Function(String) onSpecialtySelected;

  const FilterBottomSheet({
    super.key,
    required this.specialties,
    required this.selectedSpecialty,
    required this.primaryColor,
    required this.onSpecialtySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.4,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: EdgeInsets.only(top: 6),
            width: 32,
            height: 3,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Text(
                  "Filter by specialty",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Spacer(),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(Icons.close, color: Colors.grey[600], size: 20),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: Colors.grey[200]),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: specialties.length,
              itemBuilder: (context, index) {
                final specialty = specialties[index];
                final isSelected = specialty == selectedSpecialty;
                return InkWell(
                  onTap: () => onSpecialtySelected(specialty),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? primaryColor.withAlpha((0.2 * 255).toInt())
                              : Colors.transparent,
                    ),
                    child: Text(
                      specialty,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: isSelected ? primaryColor : Colors.black87,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
