import 'package:flutter/material.dart';
import 'doctor_profile_page.dart';

class DoctorsListScreen extends StatefulWidget {
  const DoctorsListScreen({super.key});

  @override
  _DoctorsListScreenState createState() => _DoctorsListScreenState();
}

class _DoctorsListScreenState extends State<DoctorsListScreen> {
  final Color primaryColor = Color(0xFF03A6A1);
  final Color secondaryColor = Color(0xFF0891B2);

  String? selectedSpecialty;
  int? selectedDoctorIndex;

  final List<Doctor> doctors = [
    Doctor(
      name: "Dr. Johan Janson",
      specialty: "Endocrinologist",
      rating: 4.5,
      reviews: 85,
      image: "assets/images/male-doctor-icon.png",
    ),
    Doctor(
      name: "Dr. Marilyn Stanton",
      specialty: "General Practitioner",
      rating: 5.0,
      reviews: 85,
      image: "assets/images/male-doctor-icon.png",
    ),
    Doctor(
      name: "Dr. Marvin McKinney",
      specialty: "Cardiologist",
      rating: 4.3,
      reviews: 85,
      image: "assets/images/male-doctor-icon.png",
    ),
    Doctor(
      name: "Dr. Arlene McCoy",
      specialty: "Physician",
      rating: 4.5,
      reviews: 85,
      image: "assets/images/male-doctor-icon.png",
    ),
    Doctor(
      name: "Dr. Eleanor Pena",
      specialty: "Rheumatologist",
      rating: 4.4,
      reviews: 85,
      image: "assets/images/male-doctor-icon.png",
    ),
    Doctor(
      name: "Dr. Katya Donin",
      specialty: "Endocrinologist",
      rating: 5.0,
      reviews: 85,
      image: "assets/images/male-doctor-icon.png",
    ),
  ];

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

  List<Doctor> get filteredDoctors {
    if (selectedSpecialty == null || selectedSpecialty == 'All specialties') {
      return doctors;
    }
    return doctors
        .where((doctor) => doctor.specialty == selectedSpecialty)
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
        actions: [
          IconButton(
            icon: Icon(Icons.more_horiz, color: Colors.black87),
            onPressed: () {},
          ),
        ],
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
                                (context) =>
                                    DoctorProfileScreen(doctor: doctor),
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
      ),
    );
  }
}

class DoctorCard extends StatelessWidget {
  final Doctor doctor;
  final Color primaryColor;
  final bool isSelected;
  final VoidCallback onArrowTap;

  const DoctorCard({
    super.key,
    required this.doctor,
    required this.primaryColor,
    required this.isSelected,
    required this.onArrowTap,
  });

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
                doctor.image.isNotEmpty
                    ? CircleAvatar(
                      radius: 20,
                      backgroundImage: AssetImage(doctor.image),
                      backgroundColor:
                          isSelected
                              ? Colors.white.withOpacity(0.2)
                              : Colors.grey[200],
                    )
                    : CircleAvatar(
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
              "${doctor.reviews} reviews",
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
                              ? primaryColor.withOpacity(0.2)
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
