import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateByRole();
  }

  Future<void> _navigateByRole() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final role = prefs.getString('role');
    await Future.delayed(
      const Duration(milliseconds: 800),
    ); // petit délai pour l'effet splash
    if (token == null || token.isEmpty) {
      if (mounted) Navigator.pushReplacementNamed(context, '/login');
      return;
    }
    if (role == 'doctor') {
      if (mounted) Navigator.pushReplacementNamed(context, '/doctor');
    } else if (role == 'admin') {
      if (mounted) Navigator.pushReplacementNamed(context, '/admin');
    } else {
      if (mounted) Navigator.pushReplacementNamed(context, '/patient');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 120,
              width: 200,
              child: Image.asset('assets/images/Logo-caretime.png'),
            ),
            SizedBox(height: 24),
            LinearProgressIndicator(),
            SizedBox(height: 16),
            Text('Welcome...', style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
