import 'package:aces_uniben/config/app_theme.dart';
import 'package:aces_uniben/features/profile/widgets/panic_attack_guide.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class FirstAidScreen extends StatelessWidget {
  // Define consistent colors
  static final Color primaryColor = AppTheme.primaryTeal;
  static final Color emergencyColor = Color(0xFFFF6B6B);
  static final Color backgroundColor = Colors.white;
  static final Color cardColor = Colors.white;
  static final Color textColor = Color(0xFF2D3142);
  static final Color subtextColor = Color(0xFF9BA0B3);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0,
        title: Text(
          'Resources',
          style: GoogleFonts.nunito(
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: primaryColor,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildEmergencySection(context),
                SizedBox(height: 24),
                _buildResourcesSection(context),
                // SizedBox(height: 24),
                // _buildSelfCareSection(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmergencySection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          'Emergency Contacts',
          'For immediate assistance',
          Icons.emergency,
          true,
        ),
        SizedBox(height: 12),
        _buildEmergencyCard(
          context,
          'Emergency Hotline',
          '112 or 739',
          'Edo State Emergency Services',
          () => _handleEmergencyContact(context, '112'),
        ),
        _buildEmergencyCard(
          context,
          'UBTH Emergency',
          '09152209819',
          'University of Benin Teaching Hospital',
          () => _handleEmergencyContact(context, '09152209819'),
        ),
        _buildEmergencyCard(
          context,
          'Emergency Line, Health Centre Ugbowo',
          '08062936058',
          'University Health Center',
          () => _handleEmergencyContact(context, '08062936058'),
        ),
         _buildEmergencyCard(
          context,
          'Emergency Line, Health Centre Ekehuan',
          '08153602899',
          'University Health Center',
          () => _handleEmergencyContact(context, '08153602899'),
        ),
      ],
    );
  }

  Widget _buildResourcesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          'Emotional Support',
          'Professional guidance and resources',
          Icons.psychology,
          false,
        ),
        SizedBox(height: 12),
        _buildResourceCard(
          context,
          'Managing Anxiety',
          'Learn effective coping techniques',
          Icons.healing,
          destinationBuilder: (context) => AnxietyGuideScreen(),
        ),
        _buildResourceCard(
          context,
          'Panic Attack Guide',
          'Step-by-step support during panic attacks',
          Icons.health_and_safety,
          destinationBuilder: (context) => PanicAttackGuideScreen(),
        ),
      ],
    );
  }

  // Widget _buildSelfCareSection(BuildContext context) {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       _buildSectionHeader(
  //         'Self-Care Tools',
  //         'Take care of your mental well-being',
  //         Icons.self_improvement,
  //         false,
  //       ),
  //       SizedBox(height: 12),
  //       _buildResourceCard(
  //         context,
  //         'Guided Meditation',
  //         'Find peace with guided sessions',
  //         Icons.spa,
  //         () => _navigateToSelfCare(context, 'Guided Meditations'),
  //       ),
  //       _buildResourceCard(
  //         context,
  //         'Breathing Exercises',
  //         'Simple techniques for instant calm',
  //         Icons.air,
  //         () => Navigator.push(
  //             context,
  //             MaterialPageRoute(
  //                 builder: (context) => PanicAttackGuideScreen())),
  //       ),
  //     ],
  //   );
  // }

  Widget _buildSectionHeader(
    String title,
    String subtitle,
    IconData icon,
    bool isEmergency,
  ) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isEmergency ? emergencyColor : primaryColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.nunito(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
              Text(
                subtitle,
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  color: subtextColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmergencyCard(
    BuildContext context,
    String title,
    String phone,
    String description,
    VoidCallback onTap,
  ) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      color: Colors.transparent,
      shape: RoundedRectangleBorder(
        
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: emergencyColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: emergencyColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.phone,
                  color: emergencyColor,
                  size: 24,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.nunito(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                    Text(
                      phone,
                      style: GoogleFonts.nunito(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: emergencyColor,
                      ),
                    ),
                    Text(
                      description,
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        color: subtextColor,
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

  Widget _buildResourceCard(
    BuildContext context,
    String title,
    String description,
    IconData icon, {
    required Widget Function(BuildContext) destinationBuilder,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 0,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => destinationBuilder(context)),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.nunito(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                    Text(
                      description,
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        color: subtextColor,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: primaryColor,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleEmergencyContact(BuildContext context, String number) async {
    final Uri url = Uri.parse('tel:$number');

    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Initiating emergency call...',
              style: GoogleFonts.nunito(),
            ),
            backgroundColor: emergencyColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        throw 'Could not launch $url';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unable to make call. Please dial $number manually.',
            style: GoogleFonts.nunito(),
          ),
          backgroundColor: emergencyColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _navigateToResource(BuildContext context, String resourceName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Opening $resourceName guide...',
          style: GoogleFonts.nunito(),
        ),
        backgroundColor: primaryColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _navigateToSelfCare(BuildContext context, String selfCareType) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Loading $selfCareType...',
          style: GoogleFonts.nunito(),
        ),
        backgroundColor: primaryColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
