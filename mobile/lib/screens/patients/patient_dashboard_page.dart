import 'package:flutter/material.dart';
import 'appointments_page.dart';
import 'doctor_list_page.dart';
import '../profile_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/patient_api_service.dart';

class PatientDashboardScreen extends StatefulWidget {
  const PatientDashboardScreen({super.key});

  @override
  State<PatientDashboardScreen> createState() => _PatientDashboardScreenState();
}

class _PatientDashboardScreenState extends State<PatientDashboardScreen> {
  int _selectedIndex = 0;
  List<Map<String, dynamic>> appointments = [];
  bool isLoading = true;
  String? error;
  Doctor? _selectedDoctor;
  List<Doctor> _doctors = [];
  bool _isLoadingDoctors = true;
  String? _doctorError;

  @override
  void initState() {
    super.initState();
    _checkAuth();
    _loadAppointments();
    _loadDoctors();
  }

  Future<void> _checkAuth() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null || token.isEmpty) {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  Future<void> _loadAppointments() async {
    setState(() {
      isLoading = true;
      error = null;
    });
    try {
      final data = await PatientApiService.getMyAppointments();
      setState(() {
        appointments = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> _loadDoctors() async {
    setState(() {
      _isLoadingDoctors = true;
      _doctorError = null;
    });
    try {
      final data = await PatientApiService.getDoctorsList();
      final doctors =
          data
              .map(
                (d) => Doctor(
                  id: d['_id'] ?? d['id'] ?? '',
                  name: (d['firstname'] ?? '') + ' ' + (d['lastname'] ?? ''),
                  specialty: d['specialty'] ?? '',
                  rating:
                      d['rating'] is double
                          ? d['rating']
                          : double.tryParse(d['rating']?.toString() ?? '') ??
                              0.0,
                  reviews:
                      d['reviews'] is int
                          ? d['reviews']
                          : int.tryParse(d['reviews']?.toString() ?? '') ?? 0,
                  image: d['image'] ?? 'assets/images/male-doctor-icon.png',
                ),
              )
              .toList();
      setState(() {
        _doctors = doctors;
        _selectedDoctor = doctors.isNotEmpty ? doctors[0] : null;
        _isLoadingDoctors = false;
      });
    } catch (e) {
      setState(() {
        _doctorError = e.toString();
        _isLoadingDoctors = false;
      });
    }
  }

  List<Widget> get _pages => [
    _dashboardHome(),
    AppointmentsScreen(),
    DoctorsListScreen(),
    ProfileScreen(),
    _isLoadingDoctors
        ? const Center(child: CircularProgressIndicator())
        : _doctorError != null
        ? Center(child: Text('Erreur: $_doctorError'))
        : Column(
          children: [
            if (_doctors.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: DropdownButton<Doctor>(
                  value: _selectedDoctor,
                  isExpanded: true,
                  items:
                      _doctors
                          .map(
                            (doc) => DropdownMenuItem(
                              value: doc,
                              child: Text(doc.name),
                            ),
                          )
                          .toList(),
                  onChanged: (doc) {
                    setState(() {
                      _selectedDoctor = doc;
                    });
                  },
                ),
              ),
          ],
        ),
  ];

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (error != null) {
      return Center(child: Text('Erreur: $error'));
    }
    return Scaffold(
      backgroundColor: Colors.white,
      appBar:
          (_selectedIndex == 0)
              ? PreferredSize(
                preferredSize: Size.fromHeight(80),
                child: AppBar(
                  backgroundColor: Colors.white,
                  elevation: 0,
                  automaticallyImplyLeading: false,
                  toolbarHeight: 80,
                  flexibleSpace: SafeArea(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Color(0xFF03A6A1),
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                          SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Welcome back!',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0891B2),
                                ),
                              ),
                              Text(
                                'Your health, our priority',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          Spacer(),
                          IconButton(
                            icon: Icon(
                              Icons.notifications,
                              color: Color(0xFF0891B2),
                            ),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
              : null,
      body: _pages[_selectedIndex],
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
                icon: Icon(Icons.home_outlined, size: 24),
                activeIcon: Icon(Icons.home, size: 24),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.calendar_today_outlined, size: 24),
                activeIcon: Icon(Icons.calendar_today, size: 24),
                label: 'Appointments',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.medical_services_outlined, size: 24),
                activeIcon: Icon(Icons.medical_services, size: 24),
                label: 'Doctors',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline, size: 24),
                activeIcon: Icon(Icons.person, size: 24),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dashboardHome() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Actions rapides
          Text(
            'Fast actions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),

          SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() => _selectedIndex = 2);
                  },
                  child: Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Color(0xFF0891B2).withAlpha((0.1 * 255).toInt()),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Color(0xFF0891B2).withAlpha((0.2 * 255).toInt()),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Color(0xFF0891B2),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Icon(Icons.add, color: Colors.white, size: 24),
                        ),
                        SizedBox(height: 12),
                        Text(
                          'New Appointment',
                          style: TextStyle(color: Color(0xFF0891B2)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(width: 16),

              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() => _selectedIndex = 1);
                  },
                  child: Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Color(0xFF03A6A1).withAlpha((0.1 * 255).toInt()),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(width: 1),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Color(0xFF03A6A1),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Icon(
                            Icons.calendar_today,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        SizedBox(height: 12),
                        Text(
                          'My appointments',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF03A6A1),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 24),

          // Rappel important
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange[200]!, width: 1),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  size: 20,
                  color: Colors.orange,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Important reminder',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.orange[700],
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Don\'t forget your appointment with Dr. Martin tomorrow at 10:00 AM',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.orange[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Espacement pour éviter que le contenu soit caché par la bottom nav
          SizedBox(height: 80),
        ],
      ),
    );
  }
}
