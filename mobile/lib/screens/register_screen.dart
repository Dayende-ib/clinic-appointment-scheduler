//import 'package:caretime/screens/login_screen.dart';
import 'package:flutter/material.dart';
import '../app_strings.dart';

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

  // Only English
  final List<String> _genders = ['Male', 'Female', 'Other'];
  final List<String> _specialties = [
    'Cardiology',
    'Dermatology',
    'Gynecology',
    'Pediatrics',
    'Ophthalmology',
    'General practitioner',
    'Other',
  ];
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

  void _register() {
    if (_formKey.currentState!.validate()) {
      // Enregistrement fictif des données
      final userData = {
        'lastname': _lastnameController.text,
        'firstname': _firstnameController.text,
        'email': _emailController.text,
        'password': _passwordController.text, // À hasher plus tard
        'dateOfBirth': _selectedDate?.toIso8601String(),
        'gender': _genderController.text,
        'address': {'country': _countryController.text},
        'role': _isDoctor ? 'doctor' : 'patient',
        if (_isDoctor) 'specialty': _specialtyController.text,
        if (_isDoctor) 'licenseNumber': _licenseNumberController.text,
      };
      // Affichage fictif
      print(userData);
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
                            'images/caretime_2x1.png',
                            height: 80,
                          ),
                        ),
                        Text(
                          AppStrings.enRegisterScreenTitle,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 24),
                        TextFormField(
                          controller: _lastnameController,
                          decoration: InputDecoration(
                            labelText: 'Last name',
                            prefixIcon: const Icon(Icons.person_outline),
                            border: const OutlineInputBorder(),
                          ),
                          validator:
                              (value) =>
                                  value == null || value.isEmpty
                                      ? 'Required field'
                                      : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _firstnameController,
                          decoration: InputDecoration(
                            labelText: 'First name',
                            prefixIcon: const Icon(Icons.person),
                            border: const OutlineInputBorder(),
                          ),
                          validator:
                              (value) =>
                                  value == null || value.isEmpty
                                      ? 'Required field'
                                      : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            prefixIcon: const Icon(Icons.email_outlined),
                            border: const OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator:
                              (value) =>
                                  value == null || value.isEmpty
                                      ? 'Required field'
                                      : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.lock_outline),
                            border: const OutlineInputBorder(),
                          ),
                          validator:
                              (value) =>
                                  value == null || value.isEmpty
                                      ? 'Required field'
                                      : null,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _dateOfBirthController,
                                decoration: const InputDecoration(
                                  labelText: 'Date of birth',
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
                                value: _selectedGender,
                                decoration: const InputDecoration(
                                  labelText: 'Gender',
                                  prefixIcon: Icon(Icons.wc_outlined),
                                  border: OutlineInputBorder(),
                                ),
                                items:
                                    _genders
                                        .map(
                                          (g) => DropdownMenuItem(
                                            value: g,
                                            child: Text(g),
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
                                            ? 'Required field'
                                            : null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _countryController,
                          decoration: const InputDecoration(
                            labelText: 'Country',
                            prefixIcon: Icon(Icons.flag_outlined),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 24),
                        CheckboxListTile(
                          title: const Text('I want to register as a doctor'),
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
                            value: _selectedSpecialty,
                            decoration: const InputDecoration(
                              labelText: 'Specialty',
                              prefixIcon: Icon(Icons.medical_services_outlined),
                              border: OutlineInputBorder(),
                            ),
                            items:
                                _specialties
                                    .map(
                                      (s) => DropdownMenuItem(
                                        value: s,
                                        child: Text(s),
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
                                        ? 'Required field'
                                        : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _licenseNumberController,
                            decoration: const InputDecoration(
                              labelText: 'License number',
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
                            onPressed: _register,
                            child: Text(AppStrings.enRegister),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: () {
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //     builder: (context) => const LoginScreen(),
                            //   ),
                            // );
                          },
                          child: const Text('Already have an account? Login'),
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
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Accueil')),
      body: const Center(child: Text('Bienvenue sur la page d\'accueil !')),
    );
  }
}
