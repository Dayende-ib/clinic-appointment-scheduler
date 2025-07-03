import 'package:flutter/material.dart';
import '../../services/admin_service.dart';

const Color kPrimaryColor = Color(0xFF03A6A1);
const Color kSecondaryColor = Color(0xFF0891B2);
final Color kAccentColor = Colors.orange.shade600;
const Color kSoftRed = Color(0xFFDB6C6C);
const Color kSuccessGreen = Color(0xFF10B981);
const Color kWarningYellow = Color(0xFFF59E0B);

class AdminDoctorsScreen extends StatefulWidget {
  const AdminDoctorsScreen({super.key});

  @override
  State<AdminDoctorsScreen> createState() => _AdminDoctorsScreenState();
}

class _AdminDoctorsScreenState extends State<AdminDoctorsScreen> {
  List<Map<String, dynamic>> doctors = [];
  bool isLoading = true;
  String? error;
  String searchQuery = '';
  String filterStatus = 'All';

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
      final data = await AdminService.getAllDoctors();
      setState(() {
        doctors =
            data
                .map<Map<String, dynamic>>(
                  (d) => {
                    ...d,
                    'id': d['id'] ?? d['_id'],
                    'name':
                        ((d['firstname'] ?? '') + ' ' + (d['lastname'] ?? ''))
                            .trim(),
                    'specialization': d['specialty'] ?? '',
                    'active': d['isActive'] ?? true,
                  },
                )
                .toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> _toggleDoctorStatus(String doctorId, bool currentStatus) async {
    try {
      final success = await AdminService.toggleDoctorStatus(
        doctorId,
        !currentStatus,
      );
      if (success) {
        _loadDoctors();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              currentStatus ? 'Doctor deactivated' : 'Doctor activated',
            ),
            backgroundColor: currentStatus ? kSoftRed : kSuccessGreen,
          ),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to deactivate doctor.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _enableDoctor(String doctorId) async {
    try {
      final success = await AdminService.enableUser(doctorId);
      if (success) {
        _loadDoctors();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Doctor reactivated'),
            backgroundColor: kSuccessGreen,
          ),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to reactivate doctor.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteDoctor(String doctorId, String doctorName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirm deletion'),
            content: Text(
              'Are you sure you want to delete doctor "$doctorName"?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: kSoftRed),
                child: const Text('Delete'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      try {
        final success = await AdminService.deleteDoctor(doctorId);
        if (success) {
          _loadDoctors();
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Doctor "$doctorName" deleted'),
              backgroundColor: kSuccessGreen,
            ),
          );
        } else {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to delete doctor.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showDoctorDetails(Map<String, dynamic> doctor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            height: MediaQuery.of(context).size.height * 0.8,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                // Handle bar
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // Header
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: kPrimaryColor,
                        child: Text(
                          (doctor['name'] ?? '').isNotEmpty
                              ? (doctor['name'] as String)[0]
                              : '?',
                          style: const TextStyle(
                            fontSize: 24,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              doctor['name'] ?? 'Unknown name',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1F2937),
                              ),
                            ),
                            Text(
                              doctor['specialization'] ?? '',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                      ),
                      _buildStatusChip(doctor['active'] ?? false),
                    ],
                  ),
                ),
                // Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDetailSection('📧 Contact', [
                          'Email: ${doctor['email'] ?? 'Not provided'}',
                          'Phone: ${doctor['phone'] ?? 'Not provided'}',
                        ]),
                        const SizedBox(height: 20),
                        _buildDetailSection('🏥 Professional Information', [
                          'Specialization: ${doctor['specialization'] ?? 'Not defined'}',
                          'License number: ${doctor['licenseNumber'] ?? 'Not provided'}',
                          'Years of experience: ${doctor['experienceYears'] ?? 'Not provided'}',
                        ]),
                        const SizedBox(height: 20),
                        _buildDetailSection('📅 Working hours', [
                          'Monday - Friday: ${doctor['workingHours']?['weekdays'] ?? 'Not defined'}',
                          'Saturday: ${doctor['workingHours']?['saturday'] ?? 'Not defined'}',
                          'Sunday: ${doctor['workingHours']?['sunday'] ?? 'Not defined'}',
                        ]),
                        const SizedBox(height: 20),
                        _buildDetailSection('💰 Pricing', [
                          'Consultation: ${doctor['pricing']?['consultation'] ?? 'Not defined'}',
                          'Follow-up: ${doctor['pricing']?['followUp'] ?? 'Not defined'}',
                        ]),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildDetailSection(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 8),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              item,
              style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color:
            isActive
                ? kSuccessGreen.withValues(alpha: 0.1)
                : kSoftRed.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isActive ? kSuccessGreen : kSoftRed),
      ),
      child: Text(
        isActive ? 'Active' : 'Inactive',
        style: TextStyle(
          color: isActive ? kSuccessGreen : kSoftRed,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  List<Map<String, dynamic>> get filteredDoctors {
    return doctors.where((doctor) {
      final name = (doctor['name'] ?? '').toLowerCase();
      final specialization = (doctor['specialization'] ?? '').toLowerCase();
      final email = (doctor['email'] ?? '').toLowerCase();
      final search = searchQuery.toLowerCase();
      final matchesSearch =
          search.isEmpty ||
          name.contains(search) ||
          specialization.contains(search) ||
          email.contains(search);
      final matchesFilter =
          filterStatus == 'All' ||
          (filterStatus == 'Active' && doctor['active'] == true) ||
          (filterStatus == 'Inactive' && doctor['active'] == false);
      return matchesSearch && matchesFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF9FAFB),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (error != null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF9FAFB),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadDoctors,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text(
          'Doctors Management',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: kPrimaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDoctors,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and filter bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search for a doctor...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF9FAFB),
                  ),
                  onChanged: (value) => setState(() => searchQuery = value),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text(
                      'Filter: ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 8),
                    DropdownButton<String>(
                      value: filterStatus,
                      items:
                          ['All', 'Active', 'Inactive'].map((status) {
                            return DropdownMenuItem(
                              value: status,
                              child: Text(status),
                            );
                          }).toList(),
                      onChanged:
                          (value) =>
                              setState(() => filterStatus = value ?? 'All'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Doctors list
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadDoctors,
              child:
                  filteredDoctors.isEmpty
                      ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.medical_services,
                              size: 64,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No doctors found',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      )
                      : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredDoctors.length,
                        itemBuilder: (context, index) {
                          final doctor = filteredDoctors[index];
                          final isActive = doctor['active'] ?? false;

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              leading: CircleAvatar(
                                radius: 25,
                                backgroundColor: kPrimaryColor,
                                child: Text(
                                  (doctor['name'] ?? '').isNotEmpty
                                      ? (doctor['name'] as String)[0]
                                      : '?',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Text(
                                doctor['name'] ?? 'Unknown name',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(doctor['specialization'] ?? ''),
                                  Text(
                                    doctor['email'] ?? 'Email not provided',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _buildStatusChip(isActive),
                                  const SizedBox(width: 8),
                                  PopupMenuButton<String>(
                                    onSelected: (value) {
                                      switch (value) {
                                        case 'details':
                                          _showDoctorDetails(doctor);
                                          break;
                                        case 'toggle':
                                          if (isActive) {
                                            _toggleDoctorStatus(
                                              doctor['id'],
                                              isActive,
                                            );
                                          } else {
                                            _enableDoctor(doctor['id']);
                                          }
                                          break;
                                        case 'delete':
                                          _deleteDoctor(
                                            doctor['id'],
                                            doctor['name'],
                                          );
                                          break;
                                      }
                                    },
                                    itemBuilder:
                                        (context) => [
                                          const PopupMenuItem(
                                            value: 'details',
                                            child: Row(
                                              children: [
                                                Icon(Icons.info_outline),
                                                SizedBox(width: 8),
                                                Text('Details'),
                                              ],
                                            ),
                                          ),
                                          PopupMenuItem(
                                            value: 'toggle',
                                            child: Row(
                                              children: [
                                                Icon(
                                                  isActive
                                                      ? Icons.block
                                                      : Icons.check_circle,
                                                  color:
                                                      isActive
                                                          ? null
                                                          : kSuccessGreen,
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  isActive
                                                      ? 'Deactivate'
                                                      : 'Activate',
                                                ),
                                              ],
                                            ),
                                          ),
                                          const PopupMenuItem(
                                            value: 'delete',
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.delete,
                                                  color: kSoftRed,
                                                ),
                                                SizedBox(width: 8),
                                                Text(
                                                  'Delete',
                                                  style: TextStyle(
                                                    color: kSoftRed,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                  ),
                                ],
                              ),
                              onTap: () => _showDoctorDetails(doctor),
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
