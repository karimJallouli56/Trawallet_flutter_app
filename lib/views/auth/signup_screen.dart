import 'package:flutter/material.dart';
import 'package:trawallet_final_version/services/auth_service.dart';
import 'package:trawallet_final_version/widgets/input_field.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _usernameController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _countryController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _usernameController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _countryController.dispose();

    super.dispose();
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _authService.signUpWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        username: _usernameController.text.trim(),
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        country: _countryController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account created successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Custom validator methods
  String? _emailValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    if (!value.contains('@')) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _passwordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  String? _confirmPasswordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }

    // Check if passwords match
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,

                children: [
                  Image.asset('assets/logos/trawallet.png', height: 70),
                  SizedBox(height: 10),
                  Text(
                    'Welcome Back',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal.shade800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Sign in to continue',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  InputField(
                    label: 'Username',
                    icon: Icons.person,
                    controller: _usernameController,
                    withBorder: true,
                    isPassword: false,
                    validator: (value) => value == null || value.isEmpty
                        ? 'Please enter a username'
                        : null,
                  ),
                  const SizedBox(height: 20),

                  InputField(
                    label: 'Full Name',
                    icon: Icons.badge,
                    controller: _nameController,
                    withBorder: true,
                    isPassword: false,
                    validator: (value) => value == null || value.isEmpty
                        ? 'Please enter your name'
                        : null,
                  ),
                  const SizedBox(height: 20),

                  InputField(
                    label: 'Phone Number',
                    icon: Icons.phone,
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    withBorder: true,
                    isPassword: false,
                    validator: (value) => value == null || value.isEmpty
                        ? 'Please enter your phone'
                        : null,
                  ),
                  const SizedBox(height: 20),

                  InputField(
                    label: 'Country',
                    icon: Icons.flag,
                    controller: _countryController,
                    withBorder: true,
                    isPassword: false,
                    validator: (value) => value == null || value.isEmpty
                        ? 'Please enter your country'
                        : null,
                  ),
                  const SizedBox(height: 20),
                  // Email Input Field
                  InputField(
                    label: 'Email Address',
                    icon: Icons.email,
                    controller: _emailController,
                    withBorder: true,
                    isPassword: false,
                    validator: _emailValidator,
                  ),
                  const SizedBox(height: 20),
                  // Password Input Field
                  InputField(
                    label: 'Password',
                    icon: Icons.lock,
                    controller: _passwordController,
                    withBorder: true,
                    isPassword: true,
                    validator: _passwordValidator,
                  ),
                  const SizedBox(height: 20),
                  // Confirm Password Input Field
                  InputField(
                    label: 'Confirm Password',
                    icon: Icons.lock,
                    controller: _confirmPasswordController,
                    withBorder: true,
                    isPassword: true,
                    validator: _confirmPasswordValidator,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: size.width * 0.9,
                    height: size.height * 0.06,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _signUp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.teal,
                              ),
                            )
                          : const Text(
                              'Sign In',
                              style: TextStyle(fontSize: 16),
                            ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account?',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          'Sign In',
                          style: TextStyle(
                            color: Colors.teal.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
