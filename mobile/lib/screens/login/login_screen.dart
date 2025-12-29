import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'forgot_password_screen.dart';
import 'package:caretime/api_client.dart';
import 'package:caretime/strings.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isPasswordVisible = false;
  bool _isLoading = false;
  DateTime? _lastLoginAttempt;

  String? _validateEmail(String value) {
    final emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.[a-zA-Z]{2,}');
    if (value.isEmpty) return AppStrings.enterEmail;
    if (!emailRegex.hasMatch(value)) return AppStrings.invalidEmail;
    return null;
  }

  String? _validatePassword(String value) {
    if (value.isEmpty) return AppStrings.enterPassword;
    return null;
  }

  Future<void> _login() async {
    final now = DateTime.now();
    if (_lastLoginAttempt != null &&
        now.difference(_lastLoginAttempt!) < const Duration(seconds: 1)) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
          const SnackBar(content: Text(AppStrings.pleaseWait)),
        );
      }
      return;
    }
    _lastLoginAttempt = now;
    final email = emailController.text.trim();
    final password = passwordController.text;
    final emailError = _validateEmail(email);
    final passwordError = _validatePassword(password);
    if (emailError != null || passwordError != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(emailError ?? passwordError!)));
      return;
    }
    setState(() => _isLoading = true);
    try {
      final response = await ApiClient.post(
        '/api/users/login',
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'];
        final role = data['user']?['role'] ?? 'patient';
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        await prefs.setString('role', role);
        final userId = data['user']?['_id'] ?? data['user']?['id'];
        if (userId != null) {
          await prefs.setString('userId', userId);
        }
        await prefs.setString('firstname', data['user']?['firstname'] ?? '');
        await prefs.setString('lastname', data['user']?['lastname'] ?? '');
        // Affiche le snackbar puis redirige après un court délai
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
          const SnackBar(content: Text(AppStrings.loginSuccess)),
        );
        await Future.delayed(const Duration(milliseconds: 800));
        if (!mounted) return;
        if (role == 'doctor') {
          Navigator.pushReplacementNamed(context, '/doctor');
        } else if (role == 'admin') {
          Navigator.pushReplacementNamed(context, '/admin');
        } else {
          Navigator.pushReplacementNamed(context, '/patient');
        }
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
          const SnackBar(content: Text(AppStrings.invalidCredentials)),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        const SnackBar(content: Text(AppStrings.networkError)),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
              const SizedBox(height: 32),
              // Logo Caretime
              SizedBox(
                height: 120,
                width: 200,
                child: Image.asset(
                  'assets/images/Logo-caretime.png',
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(height: 4),
              const Text(
                AppStrings.subtitle,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF374151),
                ),
              ),
              const SizedBox(height: 32),
              // Champ Email
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  AppStrings.emailLabel,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF374151),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  hintText: AppStrings.emailHint,
                  fillColor: Color(0xFFF8FAFC),
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                ),
              ),

              const SizedBox(height: 16),
              // Champ Mot de passe
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  AppStrings.passwordLabel,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF374151),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: passwordController,
                obscureText: !isPasswordVisible,
                decoration: InputDecoration(
                  hintText: AppStrings.passwordHint,
                  fillColor: Color(0xFFF8FAFC),
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        isPasswordVisible = !isPasswordVisible;
                      });
                    },
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                ),
              ),
              const SizedBox(height: 8),

              // Mot de passe oublié
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ForgotPasswordScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    AppStrings.forgotPassword,
                    style: TextStyle(color: Color(0xFF0891B2)),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Bouton Se connecter avec dégradé
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF03A6A1), Color(0xFF0083B0)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child:
                      _isLoading
                          ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                          : const Text(
                            AppStrings.loginButton,
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    AppStrings.noAccount,
                    style: TextStyle(color: Color(0xFF374151)),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/register');
                    },
                    child: const Text(
                      AppStrings.signUp,
                      style: TextStyle(
                        color: Color(0xFF0891B2),
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black45,
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: Colors.white),
                      SizedBox(height: 12),
                      Text(
                        'Connexion en cours...',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
