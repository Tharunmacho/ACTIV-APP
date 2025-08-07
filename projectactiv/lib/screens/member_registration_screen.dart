import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/member_registration.dart';
import '../services/auth_service.dart';
import '../utils/logger.dart';
import '../utils/auth_debug.dart';

class MemberRegistrationScreen extends StatefulWidget {
  const MemberRegistrationScreen({super.key});

  @override
  State<MemberRegistrationScreen> createState() => _MemberRegistrationScreenState();
}

class _MemberRegistrationScreenState extends State<MemberRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();
  
  // Controllers
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _stateController = TextEditingController();
  final _cityController = TextEditingController();
  final _pinCodeController = TextEditingController();
  final _panController = TextEditingController();
  
  // Form fields
  String _selectedGender = '';
  DateTime? _selectedDate;
  String _selectedMemberType = '';
  String _selectedCategory = '';
  
  File? _profileImage;
  bool _isLoading = false;
  
  final ImagePicker _picker = ImagePicker();
  
  final List<String> _genderOptions = ['Male', 'Female', 'Other'];
  final List<String> _memberTypes = ['INDIVIDUAL', 'SHG', 'FPO'];
  final List<String> _categories = [
    'Technology',
    'Healthcare',
    'Finance',
    'Education',
    'Retail',
    'Manufacturing',
    'Services',
    'Other'
  ];

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _stateController.dispose();
    _cityController.dispose();
    _pinCodeController.dispose();
    _panController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _profileImage = File(image.path);
      });
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 6570)), // 18 years ago
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _submitRegistration() async {
    AppLogger.process('Starting registration submission...');
    
    // First, try to refresh the user session
    try {
      await _authService.reloadUser();
    } catch (e) {
      AppLogger.warning('Failed to reload user: $e');
    }
    
    if (!_formKey.currentState!.validate()) {
      AppLogger.error('Form validation failed');
      return;
    }
    
    if (_selectedDate == null) {
      AppLogger.error('Date of birth not selected');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select your date of birth')),
        );
      }
      return;
    }
    
    if (_selectedGender.isEmpty) {
      AppLogger.error('Gender not selected');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select your gender')),
        );
      }
      return;
    }
    
    if (_selectedMemberType.isEmpty) {
      AppLogger.error('Member type not selected');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select member type')),
        );
      }
      return;
    }
    
    if (_selectedCategory.isEmpty) {
      AppLogger.error('Category not selected');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select category')),
        );
      }
      return;
    }

    // Check if user is authenticated
    final currentUser = _authService.currentUser;
    if (currentUser == null) {
      AppLogger.error('User not authenticated - currentUser is null');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please login first to register')),
        );
        Navigator.pushReplacementNamed(context, '/signup');
      }
      return;
    }

    // Double-check that user ID is not empty
    if (currentUser.uid.isEmpty) {
      AppLogger.error('User ID is empty');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Authentication error. Please logout and login again.')),
        );
        Navigator.pushReplacementNamed(context, '/signup');
      }
      return;
    }

    AppLogger.info('User authenticated: ${currentUser.email} (${currentUser.uid})');

    setState(() => _isLoading = true);
    AppLogger.success('All validations passed, creating registration...');

    try {
      final registration = MemberRegistration(
        fullName: _fullNameController.text.trim(),
        email: _emailController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        gender: _selectedGender,
        dateOfBirth: _selectedDate!,
        memberType: _selectedMemberType,
        category: _selectedCategory,
        address: _addressController.text.trim(),
        state: _stateController.text.trim(),
        city: _cityController.text.trim(),
        pinCode: _pinCodeController.text.trim(),
        panNumber: _panController.text.trim(),
        registrationDate: DateTime.now(),
        userId: currentUser.uid,
      );

      AppLogger.info('Registration object created for user: ${registration.userId}');
      AppLogger.process('Uploading to Firebase...');

      await _authService.saveMemberRegistration(registration, _profileImage);

      AppLogger.success('Registration saved successfully!');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registration submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      AppLogger.error('Registration failed: $e');
      if (mounted) {
        String errorMessage = 'Registration failed. Please try again.';
        
        // Provide more specific error messages
        if (e.toString().contains('permission')) {
          errorMessage = 'Permission denied. Please check Firebase rules.';
        } else if (e.toString().contains('network')) {
          errorMessage = 'Network error. Please check your internet connection.';
        } else if (e.toString().contains('auth')) {
          errorMessage = 'Authentication error. Please login again.';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF6FF),
      appBar: AppBar(
        title: const Text('ACTIV Member Registration'),
        backgroundColor: const Color(0xFF5B4DF7),
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Debug widget (only shows in debug mode)
              AuthDebugWidget(authService: _authService),
              // Profile Photo Section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () => _pickImage(),
                      child: CircleAvatar(
                        radius: 40,
                        backgroundColor: const Color(0xFFE4E9F2),
                        backgroundImage: _profileImage != null ? FileImage(_profileImage!) : null,
                        child: _profileImage == null
                            ? const Icon(Icons.camera_alt, size: 30, color: Color(0xFF8F9BB3))
                            : null,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Profile Photo',
                      style: TextStyle(fontSize: 14, color: Color(0xFF8F9BB3)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Form Fields Container
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Full Name
                    TextFormField(
                      controller: _fullNameController,
                      decoration: const InputDecoration(
                        labelText: 'Full Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => value?.trim().isEmpty == true ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),

                    // Email
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value?.trim().isEmpty == true) return 'Required';
                        if (!value!.contains('@')) return 'Invalid email';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Phone Number
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => value?.trim().isEmpty == true ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),

                    // Gender Dropdown
                    DropdownButtonFormField<String>(
                      value: _selectedGender.isEmpty ? null : _selectedGender,
                      decoration: const InputDecoration(
                        labelText: 'Gender',
                        border: OutlineInputBorder(),
                      ),
                      items: _genderOptions.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedGender = newValue ?? '';
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Member Type Dropdown
                    DropdownButtonFormField<String>(
                      value: _selectedMemberType.isEmpty ? null : _selectedMemberType,
                      decoration: const InputDecoration(
                        labelText: 'Member Type',
                        border: OutlineInputBorder(),
                      ),
                      items: _memberTypes.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedMemberType = newValue ?? '';
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Date of Birth
                    GestureDetector(
                      onTap: _selectDate,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _selectedDate == null
                                  ? 'Date of Birth'
                                  : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                              style: TextStyle(
                                color: _selectedDate == null ? Colors.grey : Colors.black,
                                fontSize: 16,
                              ),
                            ),
                            const Icon(Icons.calendar_today, color: Colors.grey),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Category
                    DropdownButtonFormField<String>(
                      value: _selectedCategory.isEmpty ? null : _selectedCategory,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                      ),
                      items: _categories.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedCategory = newValue ?? '';
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Address
                    TextFormField(
                      controller: _addressController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Address',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => value?.trim().isEmpty == true ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),

                    // State
                    TextFormField(
                      controller: _stateController,
                      decoration: const InputDecoration(
                        labelText: 'State',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => value?.trim().isEmpty == true ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),

                    // City
                    TextFormField(
                      controller: _cityController,
                      decoration: const InputDecoration(
                        labelText: 'City',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => value?.trim().isEmpty == true ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),

                    // PIN Code
                    TextFormField(
                      controller: _pinCodeController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'PIN Code',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => value?.trim().isEmpty == true ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),

                    // PAN Number
                    TextFormField(
                      controller: _panController,
                      decoration: const InputDecoration(
                        labelText: 'PAN',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => value?.trim().isEmpty == true ? 'Required' : null,
                    ),
                    const SizedBox(height: 24),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submitRegistration,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF5B4DF7),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text(
                                'Submit Registration',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
