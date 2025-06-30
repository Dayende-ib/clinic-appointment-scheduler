import 'package:flutter/material.dart';
import 'package:caretime/app_colors.dart';
import 'doctor_list_page.dart'; // Import pour accéder à la classe Doctor

class DoctorProfileScreen extends StatefulWidget {
  final Doctor doctor;

  const DoctorProfileScreen({super.key, required this.doctor});

  @override
  State<DoctorProfileScreen> createState() => _DoctorProfileScreenState();
}

class _DoctorProfileScreenState extends State<DoctorProfileScreen> {
  int selectedDay = 15;
  String selectedMonth = 'January 2025';
  List<String> availableTimes = [
    '04:30 PM',
    '05:00 PM',
    '06:30 PM',
    '07:00 PM',
    '07:45 PM',
    '08:30 PM',
  ];

  @override
  Widget build(BuildContext context) {
    final doctor = widget.doctor; // récupère le docteur passé en paramètre

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.grey[600]),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.more_horiz, color: Colors.grey[600]),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Doctor Profile Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Doctor Image dynamique
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      color: Colors.grey[200],
                      image: DecorationImage(
                        image: AssetImage(doctor.image),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.1),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Speciality dynamique
                  Text(
                    doctor.specialty,
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                  const SizedBox(height: 4),

                  // Doctor Name dynamique
                  Text(
                    doctor.name,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 4),

                  // ID fictif - tu peux adapter si tu as un champ ID
                  Text(
                    'ID: 32145687',
                    style: TextStyle(color: Colors.grey[500], fontSize: 14),
                  ),
                  const SizedBox(height: 20),

                  // Rating and Actions dynamique
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.file_copy_outlined,
                          color: Colors.grey[600],
                        ),
                        onPressed: () {},
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.star, color: Colors.white, size: 16),
                            SizedBox(width: 4),
                            Text(
                              'Rating ${doctor.rating.toString()}',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.calendar_today_outlined,
                          color: Colors.grey[600],
                        ),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.notifications_outlined,
                          color: Colors.grey[600],
                        ),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Calendar Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selectedMonth,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.chevron_left, color: Colors.grey[600]),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: Icon(Icons.chevron_right, color: Colors.grey[600]),
                      onPressed: () {},
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Days of week
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children:
                  ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
                      .map(
                        (day) => Text(
                          day,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      )
                      .toList(),
            ),

            const SizedBox(height: 12),

            // Calendar Days
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children:
                  [12, 13, 14, 15, 16, 17, 18].map((day) {
                    bool isSelected = day == selectedDay;
                    bool isToday = day == 15;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedDay = day;
                        });
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color:
                              isSelected
                                  ? AppColors.primary
                                  : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                          border:
                              isToday && !isSelected
                                  ? Border.all(
                                    color: AppColors.primary,
                                    width: 2,
                                  )
                                  : null,
                        ),
                        child: Center(
                          child: Text(
                            day.toString(),
                            style: TextStyle(
                              color:
                                  isSelected ? Colors.white : Colors.grey[800],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
            ),

            const SizedBox(height: 30),

            // Today Availability
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Today',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                    Text(
                      'Availability',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                  ],
                ),
                Text(
                  '6 Slots',
                  style: TextStyle(color: Colors.grey[500], fontSize: 14),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Time Slots
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 2.5,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: availableTimes.length,
              itemBuilder: (context, index) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Center(
                    child: Text(
                      availableTimes[index],
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 30),

            // Book Appointment Button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Rendez-vous réservé avec succès!'),
                      backgroundColor: AppColors.primary,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Book Appointment',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
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
