import 'package:aces_uniben/config/app_theme.dart';
import 'package:aces_uniben/features/auth/login.dart';
import 'package:aces_uniben/features/auth/providers/auth_provider.dart';
import 'package:aces_uniben/features/notifications/notification_service.dart';
import 'package:aces_uniben/features/profile/edit_profile_screen.dart';
import 'package:aces_uniben/features/profile/scheduler/learning_scheduler.dart'
    hide AppTheme;
import 'package:aces_uniben/features/profile/widgets/first_aid_screen.dart';
import 'package:aces_uniben/features/profile/widgets/help_screen.dart';
import 'package:aces_uniben/services/check_notifications_permissions.dart';
import 'package:aces_uniben/services/webview_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void _initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      authProvider.loadUser();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: _buildAppBar(),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) => SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfileSection(context, authProvider),
              const SizedBox(height: 32),
              _buildSupportSection(),
              const SizedBox(height: 32),
              _buildNotifSection(),
              const SizedBox(height: 32),
              _buildAccountSection(),
              const SizedBox(height: 40),
              // AppSectionWidget(),
              
              _buildLogoutButton(context, authProvider),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      automaticallyImplyLeading: false,
      title: Text(
        'Profile',
        style: GoogleFonts.poppins(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: AppTheme.primaryTeal,
        ),
      ),
    );
  }

  Widget _buildProfileSection(BuildContext context, AuthProvider authProvider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Profile Avatar
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Color(0xFFC5DBE1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                authProvider.user?.name[0] ?? 'U',
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryTeal,
                ),
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Profile Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  authProvider.user?.name ?? 'User',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  authProvider.user?.level ?? '100L',

                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),

                 Text(
                  "${authProvider.semester} Semester "?? '',
                  
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),

          // Edit Icon
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _handleEditProfile(context),
                borderRadius: BorderRadius.circular(8),
                child: Icon(
                  Icons.edit_outlined,
                  size: 18,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Support & Resources',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryTeal,
          ),
        ),
        const SizedBox(height: 16),
        _buildMenuItem(
          icon: Icons.help_outline,
          title: 'Resources',
          subtitle: 'Find help when you need it',
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (context) => FirstAidScreen())),
        ),
        const SizedBox(height: 12),
        _buildMenuItem(
          icon: Icons.account_balance_outlined,
          title: 'ACES Next-Wave Executives',
          subtitle: 'Meet the visionaries supporting this app',
          onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const WebviewWidget(
                      url: 'https://acesuniben.org/about#executives',
                      title: 'ACES Next-Wave Executives'))),
        ),
      ],
    );
  }

  Widget _buildNotifSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Notifications and Reminders',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryTeal,
          ),
        ),
        const SizedBox(height: 16),
        _buildMenuItem(
          icon: Icons.notifications_active_outlined,
          title: 'Enable Notifications',
          subtitle: 'Stay updated with reminders and alerts',
          onTap: () => NotificationPermissionDialog.show(context, shouldShowAlreadyEnabledDialog: true),),
        const SizedBox(height: 12),
        _buildMenuItem(
          icon: Icons.schedule_outlined,
          title: 'Learning Scheduler',
          subtitle: 'Plan and manage your learning time',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ReminderSettingsScreen(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAccountSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Account',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 16),
        _buildMenuItem(
          icon: Icons.help_outline,
          title: 'Help & FAQ',
          onTap: () => Navigator.push(
              context, MaterialPageRoute(builder: (context) => HelpFAQPage())),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    String? subtitle,
    Color? titleColor,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFD1D1E9),
            width: 1,
          ),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 40,
                  height: 40,
                  child: Icon(
                    icon,
                    size: 20,
                    color: AppTheme.primaryTeal,
                  ),
                ),

                const SizedBox(width: 16),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: titleColor ?? AppTheme.textColor,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: Color(0xFF8F9BB3),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Arrow
                Icon(
                  Icons.arrow_forward_outlined,
                  size: 24,
                  color: AppTheme.primaryTeal,
                  fontWeight: FontWeight.w400,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, AuthProvider authProvider) {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: AppTheme.primaryTeal,
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _handleLogout(context, authProvider),
          borderRadius: BorderRadius.circular(25),
          child: Center(
            child: Text(
              'Log Out',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryTeal,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleEditProfile(BuildContext context) {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => ProfileEditScreen()));
  }

  void _handleMenuTap(String menuItem) {
    // TODO: Handle menu item navigation
    print('$menuItem tapped');

    // Example navigation:
    // switch (menuItem) {
    //   case 'Resources':
    //     Navigator.push(context, MaterialPageRoute(builder: (context) => ResourcesPage()));
    //     break;
    //   case 'ACES MHS':
    //     Navigator.push(context, MaterialPageRoute(builder: (context) => MHSPage()));
    //     break;
    //   case 'Help & FAQ':
    //     Navigator.push(context, MaterialPageRoute(builder: (context) => HelpFAQPage()));
    //     break;
    // }
  }

  void _handleDeleteAccount() {
    // TODO: Show delete account confirmation dialog
    print('Delete Account tapped');
  }

  void _handleLogout(BuildContext context, AuthProvider authProvider) {
    // TODO: Show logout confirmation dialog and handle logout
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Log Out',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            'Are you sure you want to log out?',
            style: GoogleFonts.poppins(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(
                  color: Colors.grey.shade600,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                await authProvider.logout();

                Navigator.of(context).pop();
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SignInScreen()));
              },
              child: Text(
                'Log Out',
                style: GoogleFonts.poppins(
                  color: Colors.teal.shade600,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// Profile model for backend integration
class UserProfile {
  final String id;
  final String name;
  final String email;
  final String role;
  final String? avatar;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.avatar,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      role: json['role'],
      avatar: json['avatar'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'avatar': avatar,
    };
  }
}

class ProfileService {
  static Future<UserProfile> getCurrentUser() async {
    // TODO: Replace with actual API call
    await Future.delayed(const Duration(seconds: 1));
    return UserProfile(
      id: '1',
      name: 'Daniel Obuh',
      email: 'daniel.obuh@example.com',
      role: 'Student',
    );
  }

  static Future<void> updateProfile(UserProfile profile) async {
    // TODO: Replace with actual API call
    await Future.delayed(const Duration(seconds: 1));
  }

  static Future<void> deleteAccount() async {
    // TODO: Replace with actual API call
    await Future.delayed(const Duration(seconds: 1));
  }

  static Future<void> logout() async {
    // TODO: Replace with actual logout logic (clear tokens, etc.)
    await Future.delayed(const Duration(milliseconds: 500));
  }
}
