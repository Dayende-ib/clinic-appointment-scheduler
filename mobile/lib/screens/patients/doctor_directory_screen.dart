import 'package:flutter/material.dart';
import 'DoctorProfileScreen.dart';
import 'patient_dashboard_screen.dart';
import 'AppointmentsScreen.dart';

class DoctorsListScreen extends StatefulWidget {
  @override
  _DoctorsListScreenState createState() => _DoctorsListScreenState();
}

class _DoctorsListScreenState extends State<DoctorsListScreen> {
  final Color primaryColor = Color(0xFF03A6A1);
  final Color secondaryColor = Color(0xFF0891B2);
  int _selectedIndex = 2; // Index 2 pour "Médecins"

  String? selectedSpecialty;
  int? selectedDoctorIndex;

  final List<Doctor> doctors = [
    Doctor(
      name: "Dr. Johan Janson",
      specialty: "Endocrinologist",
      rating: 4.5,
      reviews: 85,
      image: "assets/doctor1.jpg",
    ),
    Doctor(
      name: "Dr. Marilyn Stanton",
      specialty: "General Physician",
      rating: 5.0,
      reviews: 85,
      image: "assets/doctor2.jpg",
    ),
    Doctor(
      name: "Dr. Marvin McKinney",
      specialty: "Cardiologist",
      rating: 4.3,
      reviews: 85,
      image: "assets/doctor3.jpg",
    ),
    Doctor(
      name: "Dr. Arlene McCoy",
      specialty: "Physician",
      rating: 4.5,
      reviews: 85,
      image: "assets/doctor4.jpg",
    ),
    Doctor(
      name: "Dr. Eleanor Pena",
      specialty: "Arthropathic",
      rating: 4.4,
      reviews: 85,
      image: "assets/doctor5.jpg",
    ),
    Doctor(
      name: "Dr. Katya Donin",
      specialty: "Endocrinologist",
      rating: 5.0,
      reviews: 85,
      image: "assets/doctor6.jpg",
    ),
  ];

  List<String> get specialties {
    return [
      'Toutes les spécialités',
      'Cardiologie',
      'Dermatologie',
      'Pédiatrie',
      'Orthopédie',
      'Endocrinologist',
      'General Physician',
      'Physician',
      'Arthropathic',
    ];
  }

  List<Doctor> get filteredDoctors {
    if (selectedSpecialty == null ||
        selectedSpecialty == 'Toutes les spécialités') {
      return doctors;
    }
    return doctors
        .where((doctor) => doctor.specialty == selectedSpecialty)
        .toList();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
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

  PreferredSizeWidget _buildAppointmentsHeader() {
    return PreferredSize(
      preferredSize: Size.fromHeight(100),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF03A6A1), Color(0xFF0891B2)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'My appointments',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Manage your medical appointments',
                      style: TextStyle(fontSize: 14, color: Colors.white70),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    PreferredSizeWidget? appBar;
    switch (_selectedIndex) {
      case 0:
        body = MedicalDashboard();
        appBar = AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: Text(
            "Accueil",
            style: TextStyle(
              color: Colors.black87,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
        );
        break;
      case 1:
        body = Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildAppointmentsHeader(),
            Expanded(child: AppointmentsScreen()),
          ],
        );
        appBar = null;
        break;
      case 2:
        body = _doctorsListBody();
        appBar = AppBar(
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
          actions: [
            IconButton(
              icon: Icon(Icons.more_horiz, color: Colors.black87),
              onPressed: () {},
            ),
          ],
        );
        break;
      case 3:
        body = Center(child: Text('Profil patient (à personnaliser)'));
        appBar = AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: Text(
            "Profil",
            style: TextStyle(
              color: Colors.black87,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
        );
        break;
      default:
        body = _doctorsListBody();
        appBar = null;
    }
    return Scaffold(
      backgroundColor: Color(0xFFF5F7FA),
      appBar: appBar,
      body: body,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            currentIndex: _selectedIndex,
            onTap: (index) => setState(() => _selectedIndex = index),
            selectedItemColor: Color(0xFF03A6A1),
            unselectedItemColor: Colors.grey[400],
            selectedLabelStyle: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
            elevation: 0,
            items: [
              BottomNavigationBarItem(
                icon: Container(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Icon(Icons.home_outlined, size: 24),
                ),
                activeIcon: Container(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Icon(Icons.home, size: 24),
                ),
                label: 'Accueil',
              ),
              BottomNavigationBarItem(
                icon: Container(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Icon(Icons.calendar_today_outlined, size: 24),
                ),
                activeIcon: Container(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Icon(Icons.calendar_today, size: 24),
                ),
                label: 'RDV',
              ),
              BottomNavigationBarItem(
                icon: Container(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Icon(Icons.medical_services_outlined, size: 24),
                ),
                activeIcon: Container(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Icon(Icons.medical_services, size: 24),
                ),
                label: 'Médecins',
              ),
              BottomNavigationBarItem(
                icon: Container(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Icon(Icons.person_outline, size: 24),
                ),
                activeIcon: Container(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Icon(Icons.person, size: 24),
                ),
                label: 'Profil',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _doctorsListBody() {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(16),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search for doctor...",
                hintStyle: TextStyle(color: Colors.grey[400]),
                prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                suffixIcon: IconButton(
                  icon: Icon(
                    Icons.tune,
                    color:
                        selectedSpecialty != null &&
                                selectedSpecialty != 'Toutes les spécialités'
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
            ),
          ),
        ),
        if (selectedSpecialty != null &&
            selectedSpecialty != 'Toutes les spécialités')
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: primaryColor.withOpacity(0.3)),
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
                        child: Icon(Icons.close, size: 16, color: primaryColor),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  "${filteredDoctors.length} docteur(s) trouvé(s)",
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
        SizedBox(height: 8),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(left: 16, right: 16, bottom: 80),
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
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedDoctorIndex = index;
                    });
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
                              (context) => DoctorProfileScreen(doctor: doctor),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class DoctorCard extends StatelessWidget {
  final Doctor doctor;
  final Color primaryColor;
  final bool isSelected;
  final VoidCallback onArrowTap;

  const DoctorCard({
    Key? key,
    required this.doctor,
    required this.primaryColor,
    required this.isSelected,
    required this.onArrowTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isSelected ? primaryColor : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor:
                      isSelected
                          ? Colors.white.withOpacity(0.2)
                          : Colors.grey[200],
                  child: Icon(
                    Icons.person,
                    color: isSelected ? Colors.white : Colors.grey[600],
                  ),
                ),
                SizedBox(width: 12),
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
            SizedBox(height: 8),
            Text(
              doctor.specialty,
              style: TextStyle(
                fontSize: 12,
                color:
                    isSelected
                        ? Colors.white.withOpacity(0.8)
                        : Colors.grey[600],
              ),
            ),
            Spacer(),
            Row(
              children: [
                Icon(Icons.star, color: Colors.amber, size: 16),
                SizedBox(width: 4),
                Text(
                  doctor.rating.toString(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : Colors.black87,
                  ),
                ),
                Spacer(),
                GestureDetector(
                  onTap: onArrowTap,
                  child: Container(
                    padding: EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? Colors.white.withOpacity(0.2)
                              : Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.arrow_forward,
                      size: 16,
                      color: isSelected ? Colors.white : Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 4),
            Text(
              "${doctor.reviews} Reviews",
              style: TextStyle(
                fontSize: 10,
                color:
                    isSelected
                        ? Colors.white.withOpacity(0.7)
                        : Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Doctor {
  final String name;
  final String specialty;
  final double rating;
  final int reviews;
  final String image;

  Doctor({
    required this.name,
    required this.specialty,
    required this.rating,
    required this.reviews,
    required this.image,
  });
}

class FilterBottomSheet extends StatelessWidget {
  final List<String> specialties;
  final String? selectedSpecialty;
  final Color primaryColor;
  final Function(String) onSpecialtySelected;

  const FilterBottomSheet({
    Key? key,
    required this.specialties,
    required this.selectedSpecialty,
    required this.primaryColor,
    required this.onSpecialtySelected,
  }) : super(key: key);

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
            color: Colors.black.withOpacity(0.1),
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
                  "Filtrer par spécialité",
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
                      color: isSelected ? Colors.grey[600] : Colors.transparent,
                    ),
                    child: Text(
                      specialty,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: isSelected ? Colors.white : Colors.black87,
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
