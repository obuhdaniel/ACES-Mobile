import 'package:aces_uniben/config/app_theme.dart';
import 'package:aces_uniben/features/auth/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _matricNoController = TextEditingController();
  final TextEditingController _levelController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  final FocusNode _fullNameFocus = FocusNode();
  final FocusNode _matricNoFocus = FocusNode();
  final FocusNode _levelFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _isLoading = false;
  bool _isInitialDataLoaded = false;
  bool _hasUnsavedChanges = false;
  Map<String, String> _originalValues = {};

  // Dropdown values for level
  final List<String> _levels = ['100', '200', '300', '400', '500', '600'];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _setupControllerListeners();
    _loadUserData();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
  }

  void _setupControllerListeners() {
    final controllers = [
      _fullNameController,
      _matricNoController,
      _levelController,
      _emailController,
      _phoneController,
    ];

    for (var controller in controllers) {
      controller.addListener(_checkForChanges);
    }
  }

  void _checkForChanges() {
    final currentValues = {
      'name': _fullNameController.text,
      'matNo': _matricNoController.text,
      'level': _levelController.text,
      'email': _emailController.text,
      'phone': _phoneController.text,
    };

    bool hasChanges = false;
    for (var key in currentValues.keys) {
      if (currentValues[key] != _originalValues[key]) {
        hasChanges = true;
        break;
      }
    }

    if (hasChanges != _hasUnsavedChanges) {
      setState(() {
        _hasUnsavedChanges = hasChanges;
      });
    }
  }

  void _loadUserData() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;

    if (user != null) {
      _fullNameController.text = user.name ?? '';
      _matricNoController.text = user.matNo ?? '';
      _levelController.text = user.level ?? '';
      _emailController.text = user.uniEmail ?? '';
      _phoneController.text = ''; // Adjust if you have phone in user model

      // Store original values
      _originalValues = {
        'name': user.name ?? '',
        'matNo': user.matNo ?? '',
        'level': user.level ?? '',
        'email': user.uniEmail ?? '',
        'phone': '',
      };

      setState(() {
        _isInitialDataLoaded = true;
      });

      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _fullNameController.dispose();
    _matricNoController.dispose();
    _levelController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _fullNameFocus.dispose();
    _matricNoFocus.dispose();
    _levelFocus.dispose();
    _emailFocus.dispose();
    _phoneFocus.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    if (!_hasUnsavedChanges) return true;

    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text('Unsaved Changes'),
            content: const Text(
              'You have unsaved changes. Are you sure you want to leave?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Stay'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Leave'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Haptic feedback
    HapticFeedback.lightImpact();

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.updateProfile(
        fullName: _fullNameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        matriculationNumber: _matricNoController.text.trim(),
        universityEmail: _emailController.text.trim(),
        level: _levelController.text.trim(),
      );

      if (success) {
        HapticFeedback.heavyImpact();
        _showSuccessSnackBar();
        
        // Update original values to current values
        _originalValues = {
          'name': _fullNameController.text,
          'matNo': _matricNoController.text,
          'level': _levelController.text,
          'email': _emailController.text,
          'phone': _phoneController.text,
        };
        
        setState(() {
          _hasUnsavedChanges = false;
        });

        // Delay navigation to show success message
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          Navigator.pop(context, true); // Return true to indicate success
        }
      } else {
        _showErrorSnackBar('Failed to update profile. Please try again.');
      }
    } catch (e) {
      _showErrorSnackBar('Error: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSuccessSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Text('Profile updated successfully!'),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  // Enhanced validation methods
  String? _validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Full name is required';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value.trim())) {
      return 'Name should only contain letters and spaces';
    }
    return null;
  }

  String? _validateMatricNo(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Matriculation number is required';
    }
    // Assuming a specific format for matric numbers
    if (!RegExp(r'^ENG\d{7}$').hasMatch(value.trim().toUpperCase())) {
      return 'Invalid format. Use: ENG followed by 7 digits';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'University email is required';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }
    // Check if it's a university email
    if (!value.toLowerCase().contains('uniben.edu')) {
      return 'Please use your university email';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    // Remove all non-digit characters for validation
    final cleanPhone = value.replaceAll(RegExp(r'[^\d]'), '');
    if (cleanPhone.length < 10 || cleanPhone.length > 15) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    const themeColor = AppTheme.primaryTeal;
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    if (!_isInitialDataLoaded) {
      return Scaffold(
        backgroundColor: Colors.grey.shade50,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: themeColor),
              const SizedBox(height: 16),
              Text(
                'Loading profile...',
                style: GoogleFonts.nunitoSans(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        body: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: CustomScrollView(
                slivers: [
                  // Custom App Bar
                  SliverAppBar(
                    expandedHeight: 200,
                    floating: false,
                    pinned: true,
                    backgroundColor: Colors.white,
                    elevation: 0,
                    leading: GestureDetector(
                      onTap: () async {
                        if (await _onWillPop()) {
                          Navigator.pop(context);
                        }
                      },
                      child: Container(
                        margin: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEAFCE6),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new,
                          color: themeColor,
                          size: 20,
                        ),
                      ),
                    ),
                    flexibleSpace: FlexibleSpaceBar(
                      centerTitle: true,
                      title: Text(
                        "Edit Profile",
                        style: GoogleFonts.nunitoSans(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: themeColor,
                        ),
                      ),
                      background: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              themeColor.withOpacity(0.1),
                              Colors.white,
                            ],
                          ),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Hero(
                                tag: 'profile_avatar',
                                child: Stack(
                                  alignment: Alignment.bottomRight,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: LinearGradient(
                                          colors: [
                                            themeColor.withOpacity(0.3),
                                            themeColor.withOpacity(0.1),
                                          ],
                                        ),
                                      ),
                                      child: CircleAvatar(
                                        radius: 50,
                                        backgroundColor: const Color(0xFFD0E5EA),
                                        child: Text(
                                          user?.name?.isNotEmpty == true
                                              ? user!.name![0].toUpperCase()
                                              : "U",
                                          style: const TextStyle(
                                            fontSize: 40,
                                            color: themeColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                             
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Form Content
                  SliverToBoxAdapter(
                    child: Container(
                      margin: const EdgeInsets.only(top: 20),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(24),
                          topRight: Radius.circular(24),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (_hasUnsavedChanges)
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(12),
                                  margin: const EdgeInsets.only(bottom: 20),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.shade50,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.orange.shade200,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.info_outline,
                                        color: Colors.orange.shade700,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'You have unsaved changes',
                                          style: TextStyle(
                                            color: Colors.orange.shade700,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                              _buildTextField(
                                label: "Full Name",
                                controller: _fullNameController,
                                focusNode: _fullNameFocus,
                                nextFocusNode: _matricNoFocus,
                                validator: _validateName,
                                prefixIcon: Icons.person_outline,
                                textCapitalization: TextCapitalization.words,
                              ),
                              const SizedBox(height: 20),

                              _buildTextField(
                                label: "Matriculation Number",
                                controller: _matricNoController,
                                focusNode: _matricNoFocus,
                                nextFocusNode: _levelFocus,
                                validator: _validateMatricNo,
                                prefixIcon: Icons.badge_outlined,
                                textCapitalization: TextCapitalization.characters,
                                hintText: "e.g., CSC/2020/123",
                              ),
                              const SizedBox(height: 20),

                              // _buildLevelDropdown(),
                              const SizedBox(height: 20),

                              _buildTextField(
                                label: "University Email",
                                controller: _emailController,
                                focusNode: _emailFocus,
                                nextFocusNode: _phoneFocus,
                                validator: _validateEmail,
                                prefixIcon: Icons.email_outlined,
                                keyboardType: TextInputType.emailAddress,
                                hintText: "your.email@uniben.edu.ng",
                              ),
                              const SizedBox(height: 20),

                              _buildTextField(
                                label: "Phone Number",
                                controller: _phoneController,
                                focusNode: _phoneFocus,
                                validator: _validatePhone,
                                prefixIcon: Icons.phone_outlined,
                                keyboardType: TextInputType.phone,
                                hintText: "+234 xxx xxx xxxx",
                                textInputAction: TextInputAction.done,
                              ),
                              const SizedBox(height: 40),

                              // Update Button
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                width: double.infinity,
                                height: 56,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _hasUnsavedChanges
                                        ? themeColor
                                        : Colors.grey.shade400,
                                    elevation: _hasUnsavedChanges ? 4 : 0,
                                    shadowColor: themeColor.withOpacity(0.3),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  onPressed: (_isLoading || !_hasUnsavedChanges)
                                      ? null
                                      : _updateProfile,
                                  child: _isLoading
                                      ? const Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 2,
                                              ),
                                            ),
                                            SizedBox(width: 12),
                                            Text(
                                              "Updating...",
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        )
                                      : Text(
                                          "Update Profile",
                                          style: GoogleFonts.nunitoSans(
                                            fontSize: 16,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required FocusNode focusNode,
    FocusNode? nextFocusNode,
    String? Function(String?)? validator,
    IconData? prefixIcon,
    TextInputType keyboardType = TextInputType.text,
    TextCapitalization textCapitalization = TextCapitalization.none,
    String? hintText,
    TextInputAction textInputAction = TextInputAction.next,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.nunitoSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.textColor,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          textInputAction: textInputAction,
          validator: validator,
          onFieldSubmitted: (_) {
            if (nextFocusNode != null) {
              FocusScope.of(context).requestFocus(nextFocusNode);
            }
          },
          style: TextStyle(
            fontSize: 16,
            color: AppTheme.textColor,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 14,
            ),
            prefixIcon: prefixIcon != null
                ? Icon(
                    prefixIcon,
                    color: focusNode.hasFocus
                        ? AppTheme.primaryTeal
                        : Colors.grey.shade400,
                    size: 20,
                  )
                : null,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.grey.shade200,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppTheme.primaryTeal,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Colors.red,
                width: 1,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Colors.red,
                width: 2,
              ),
            ),
            errorStyle: const TextStyle(fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildLevelDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Level",
          style: GoogleFonts.nunitoSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.textColor,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _levelController.text.isEmpty ? null : _levelController.text,
          focusNode: _levelFocus,
          decoration: InputDecoration(
            hintText: "Select your level",
            hintStyle: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 14,
            ),
            prefixIcon: Icon(
              Icons.school_outlined,
              color: _levelFocus.hasFocus
                  ? AppTheme.primaryTeal
                  : Colors.grey.shade400,
              size: 20,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.grey.shade200,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppTheme.primaryTeal,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Colors.red,
                width: 1,
              ),
            ),
          ),
          items: _levels.map((level) {
            return DropdownMenuItem<String>(
              value: level,
              child: Text('$level Level'),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _levelController.text = value ?? '';
            });
            FocusScope.of(context).requestFocus(_emailFocus);
          },
          validator: (value) => _validateRequired(value, "Level"),
        ),
      ],
    );
  }
}