import 'package:caretime/screens/login/login_screen.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:caretime/strings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:caretime/api_client.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _lastnameController = TextEditingController();
  final TextEditingController _firstnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _dateOfBirthController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _specialtyController = TextEditingController();
  final TextEditingController _licenseNumberController =
      TextEditingController();

  bool _isDoctor = false;
  DateTime? _selectedDate;
  bool _isLoading = false;
  DateTime? _lastRegisterAttempt;

  final List<String> _genders = [
    'male',
    'female',
    'other',
    'prefer_not_to_say',
  ];
  final Map<String, String> _genderLabels = {
    'male': AppStrings.genderMale,
    'female': AppStrings.genderFemale,
    'other': AppStrings.genderOther,
    'prefer_not_to_say': AppStrings.genderPreferNotToSay,
  };
  final List<String> _specialties = [
    'Cardiology',
    'Dermatology',
    'Gynecology',
    'Pediatrics',
    'Ophthalmology',
    'General practitioner',
    'Neurology',
    'Psychiatry',
    'Orthopedics',
    'ENT',
    'Urology',
    'Oncology',
    'Radiology',
    'Anesthesiology',
    'Endocrinology',
    'Nephrology',
    'Pulmonology',
    'Rheumatology',
    'Infectious diseases',
    'Hematology',
    'Gastroenterology',
    'Other',
  ];
  final Map<String, String> _specialtyLabels = {
    'Cardiology': AppStrings.specialtyCardiology,
    'Dermatology': AppStrings.specialtyDermatology,
    'Gynecology': AppStrings.specialtyGynecology,
    'Pediatrics': AppStrings.specialtyPediatrics,
    'Ophthalmology': AppStrings.specialtyOphthalmology,
    'General practitioner': AppStrings.specialtyGeneralPractitioner,
    'Neurology': AppStrings.specialtyNeurology,
    'Psychiatry': AppStrings.specialtyPsychiatry,
    'Orthopedics': AppStrings.specialtyOrthopedics,
    'ENT': AppStrings.specialtyEnt,
    'Urology': AppStrings.specialtyUrology,
    'Oncology': AppStrings.specialtyOncology,
    'Radiology': AppStrings.specialtyRadiology,
    'Anesthesiology': AppStrings.specialtyAnesthesiology,
    'Endocrinology': AppStrings.specialtyEndocrinology,
    'Nephrology': AppStrings.specialtyNephrology,
    'Pulmonology': AppStrings.specialtyPulmonology,
    'Rheumatology': AppStrings.specialtyRheumatology,
    'Infectious diseases': AppStrings.specialtyInfectiousDiseases,
    'Hematology': AppStrings.specialtyHematology,
    'Gastroenterology': AppStrings.specialtyGastroenterology,
    'Other': AppStrings.specialtyOther,
  };

  final List<String> _westAfricanCountries = [
    AppStrings.countryBenin,
    AppStrings.countryBurkinaFaso,
    AppStrings.countryCapeVerde,
    AppStrings.countryIvoryCoast,
    AppStrings.countryGambia,
    AppStrings.countryGhana,
    AppStrings.countryGuinea,
    AppStrings.countryGuineaBissau,
    AppStrings.countryLiberia,
    AppStrings.countryMali,
    AppStrings.countryMauritania,
    AppStrings.countryNiger,
    AppStrings.countryNigeria,
    AppStrings.countrySenegal,
    AppStrings.countrySierraLeone,
    AppStrings.countryTogo,
  ];
  String? _selectedCountry;
  String? _selectedGender;
  String? _selectedSpecialty;

  @override
  void dispose() {
    _lastnameController.dispose();
    _firstnameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _dateOfBirthController.dispose();
    _genderController.dispose();
    _countryController.dispose();
    _specialtyController.dispose();
    _licenseNumberController.dispose();
    super.dispose();
  }

  void _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateOfBirthController.text =
            "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  void _register() async {
    final now = DateTime.now();
    if (_lastRegisterAttempt != null &&
        now.difference(_lastRegisterAttempt!) < const Duration(seconds: 1)) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
          const SnackBar(content: Text(AppStrings.pleaseWait)),
        );
      }
      return;
    }
    _lastRegisterAttempt = now;
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      final userData = {
        'lastname': _lastnameController.text,
        'firstname': _firstnameController.text,
        'email': _emailController.text,
        'password': _passwordController.text,
        'dateOfBirth': _selectedDate?.toIso8601String(),
        'gender': _genderController.text,
        'country': _countryController.text,
        'role': _isDoctor ? 'doctor' : 'patient',
        if (_isDoctor) 'specialty': _specialtyController.text,
        if (_isDoctor) 'licenseNumber': _licenseNumberController.text,
      };
      try {
        final response = await ApiClient.post(
          '/api/users/register',
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(userData),
        );

        if (response.statusCode == 201) {
          final data = jsonDecode(response.body);
          final token = data['token'];
          final role = data['user']['role'];

          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', token);

          // Show success snackbar and redirect after a short delay.
          if (!mounted) return;
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(
            const SnackBar(content: Text(AppStrings.registerSuccess)),
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
          final msg =
              jsonDecode(response.body)['message'] ?? AppStrings.unknownError;
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(
              SnackBar(content: Text('${AppStrings.registerErrorPrefix}$msg')),
            );
          }
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFe0eafc), Color(0xFFcfdef3)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 32,
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                        // Logo ou image
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Image.asset(
                            'assets/images/Logo-caretime.png',
                            height: 80,
                          ),
                        ),
                        Text(
                          AppStrings.registerScreenTitle,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 24),
                        TextFormField(
                          controller: _lastnameController,
                          decoration: InputDecoration(
                            labelText: AppStrings.lastName,
                            prefixIcon: const Icon(Icons.person_outline),
                            border: const OutlineInputBorder(),
                          ),
                          validator:
                              (value) =>
                                  value == null || value.isEmpty
                                      ? AppStrings.requiredField
                                      : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _firstnameController,
                          decoration: InputDecoration(
                            labelText: AppStrings.firstName,
                            prefixIcon: const Icon(Icons.person),
                            border: const OutlineInputBorder(),
                          ),
                          validator:
                              (value) =>
                                  value == null || value.isEmpty
                                      ? AppStrings.requiredField
                                      : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: AppStrings.emailLabel,
                            prefixIcon: Icon(Icons.email_outlined),
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator:
                              (value) =>
                                  value == null || value.isEmpty
                                      ? AppStrings.requiredField
                                      : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: AppStrings.passwordLabel,
                            prefixIcon: const Icon(Icons.lock_outline),
                            border: const OutlineInputBorder(),
                          ),
                          validator:
                              (value) =>
                                  value == null || value.isEmpty
                                      ? AppStrings.requiredField
                                      : null,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _dateOfBirthController,
                                decoration: const InputDecoration(
                                  labelText: AppStrings.dateOfBirth,
                                  prefixIcon: Icon(Icons.cake_outlined),
                                  border: OutlineInputBorder(),
                                ),
                                readOnly: true,
                                onTap: _pickDate,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                initialValue: _selectedGender,
                                decoration: const InputDecoration(
                                  labelText: AppStrings.gender,
                                  prefixIcon: Icon(Icons.wc_outlined),
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                ),
                                isExpanded: true,
                                items:
                                    _genders
                                        .map(
                                          (g) => DropdownMenuItem(
                                            value: g,
                                            child: Text(_genderLabels[g] ?? g),
                                          ),
                                        )
                                        .toList(),
                                onChanged: (val) {
                                  setState(() {
                                    _selectedGender = val;
                                    _genderController.text = val ?? '';
                                  });
                                },
                                validator:
                                    (value) =>
                                        value == null || value.isEmpty
                                            ? AppStrings.requiredField
                                            : null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Champ pays remplacé par un dropdown
                        DropdownButtonFormField<String>(
                          initialValue: _selectedCountry,
                          decoration: const InputDecoration(
                            labelText: AppStrings.country,
                            prefixIcon: Icon(Icons.flag_outlined),
                            border: OutlineInputBorder(),
                          ),
                          items:
                              _westAfricanCountries
                                  .map(
                                    (c) => DropdownMenuItem(
                                      value: c,
                                      child: Text(c),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (val) {
                            setState(() {
                              _selectedCountry = val;
                              _countryController.text = val ?? '';
                            });
                          },
                          validator:
                              (value) =>
                                  value == null || value.isEmpty
                                      ? AppStrings.requiredField
                                      : null,
                        ),
                        const SizedBox(height: 24),
                        CheckboxListTile(
                          title: const Text(AppStrings.registerAsDoctor),
                          value: _isDoctor,
                          onChanged: (val) {
                            setState(() {
                              _isDoctor = val ?? false;
                            });
                          },
                          controlAffinity: ListTileControlAffinity.leading,
                          contentPadding: EdgeInsets.zero,
                        ),
                        if (_isDoctor) ...[
                          DropdownButtonFormField<String>(
                            initialValue: _selectedSpecialty,
                            decoration: const InputDecoration(
                              labelText: AppStrings.specialty,
                              prefixIcon: Icon(Icons.medical_services_outlined),
                              border: OutlineInputBorder(),
                            ),
                            items:
                                _specialties
                                    .map(
                                      (s) => DropdownMenuItem(
                                        value: s,
                                        child: Text(
                                          _specialtyLabels[s] ?? s,
                                        ),
                                      ),
                                    )
                                    .toList(),
                            onChanged: (val) {
                              setState(() {
                                _selectedSpecialty = val;
                                _specialtyController.text = val ?? '';
                              });
                            },
                            validator:
                                (value) =>
                                    value == null || value.isEmpty
                                        ? AppStrings.requiredField
                                        : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _licenseNumberController,
                            decoration: const InputDecoration(
                              labelText: AppStrings.licenseNumber,
                              prefixIcon: Icon(
                                Icons.confirmation_number_outlined,
                              ),
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              backgroundColor: Theme.of(context).primaryColor,
                              foregroundColor: Colors.white,
                              textStyle: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onPressed:
                                _isLoading
                                    ? null
                                    : () {
                                      FocusScope.of(context).unfocus();
                                      _register();
                                    },
                            child:
                                _isLoading
                                    ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    )
                                    : Text(AppStrings.register),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginScreen(),
                              ),
                            );
                          },
                          child: const Text(AppStrings.alreadyHaveAccount),
                        ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
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
                        'Inscription en cours...',
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
