import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _scaleAnim = Tween<double>(
      begin: 0.7,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
    _fadeAnim = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));
    _controller.forward();
    _navigateByRole();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _navigateByRole() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final role = prefs.getString('role');
    await Future.delayed(const Duration(milliseconds: 1200));
    if (token == null || token.isEmpty) {
      if (mounted) Navigator.pushReplacementNamed(context, '/welcome');
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
            AnimatedBuilder(
              animation: _controller,
              builder:
                  (context, child) => Opacity(
                    opacity: _fadeAnim.value,
                    child: Transform.scale(
                      scale: _scaleAnim.value,
                      child: child,
                    ),
                  ),
              child: SizedBox(
                height: 120,
                width: 200,
                child: Image.asset('assets/images/Logo-caretime.png'),
              ),
            ),
            const SizedBox(height: 24),
            const LinearProgressIndicator(),
            const SizedBox(height: 16),
            const Text('Welcome...', style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
