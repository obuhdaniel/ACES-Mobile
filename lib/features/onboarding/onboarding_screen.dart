// Improved Onboarding Screen
import 'package:aces_uniben/config/app_theme.dart';
import 'package:aces_uniben/features/auth/login.dart';
import 'package:aces_uniben/features/home/home_screen.dart';
import 'package:aces_uniben/features/onboarding/models/onboardiing_model.dart';
import 'package:aces_uniben/providers/onboarding_provider.dart';
import 'package:aces_uniben/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late PageController _pageController;
  int _currentPage = 0;

  final List<OnboardingData> _onboardingData = [
    OnboardingData(
      title: 'Welcome to ACES Uniben',
      description: 'Stay connected with your fellow Computer Engineering students and receive important updates from executives.',
      imagePath: 'assets/images/ob1.png', 
      icon: Icons.people_outline,
    ),
    OnboardingData(
      title: 'Organize Your Student Life',
      description: 'Keep track of your tasks, maintain journals, and manage your class schedule all in one place.',
      imagePath: 'assets/images/ob2.png',
      icon: Icons.schedule_outlined,
    ),
    OnboardingData(
      title: 'Learn & Grow Together',
      description: 'Access tech learning guides, get study notifications, and support your mental health journey.',
      imagePath: 'assets/images/ob2.png',
      icon: Icons.school_outlined,
    ),
    OnboardingData(
      title: 'Mental Health Support',
      description: 'Take care of your wellbeing with our built-in mental health tools and resources.',
      imagePath: 'assets/images/ob2.png',
      icon: Icons.favorite_outline,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final onboardingProvider = Provider.of<OnboardingProvider>(context);
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenHeight < 700;
    final isWideScreen = screenWidth > 600;

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              children: [
                // Header with skip button (only show on non-last pages)
                if (_currentPage != _onboardingData.length - 1)
                  _buildHeader(context),
                
                // Flexible content area
                Expanded(
                  flex: isSmallScreen ? 7 : 8,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _onboardingData.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      return OnboardingPage(
                        data: _onboardingData[index],
                        isSmallScreen: isSmallScreen,
                        isWideScreen: isWideScreen,
                      );
                    },
                  ),
                ),
                
                // Fixed bottom section
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isWideScreen ? 40 : 20,
                    vertical: isSmallScreen ? 16 : 24,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Page indicator
                      _buildPageIndicator(context),
                      
                      SizedBox(height: isSmallScreen ? 20 : 32),
                      
                      // Action buttons
                      _buildActionButtons(context, onboardingProvider, isWideScreen),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () {
              _navigateToMain();
              Provider.of<OnboardingProvider>(context, listen: false)
                  .completeOnboarding();
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            child:  Text(
              'Skip',
              style:  GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _onboardingData.length,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 6),
          height: 8,
          width: _currentPage == index ? 32 : 8,
          decoration: BoxDecoration(
            color: _currentPage == index
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.primary.withOpacity(0.25),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, OnboardingProvider onboardingProvider, bool isWideScreen) {
    final isLastPage = _currentPage == _onboardingData.length - 1;
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Main action button
        SizedBox(
          width: isWideScreen ? 280 : double.infinity,
          child: ElevatedButton(
            onPressed: () {
              if (isLastPage) {
                _navigateToMain();
                onboardingProvider.completeOnboarding();
              } else {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            child: Text(
              isLastPage ? 'Get Started' : 'Continue',
              style:   GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        
       
      ],
    );
  }

  void _navigateToMain() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const SignInScreen()),
    );
  }
}

// Improved Onboarding Page Widget
class OnboardingPage extends StatelessWidget {
  final OnboardingData data;
  final bool isSmallScreen;
  final bool isWideScreen;

  const OnboardingPage({
    super.key, 
    required this.data,
    required this.isSmallScreen,
    required this.isWideScreen,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    
    


    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 16,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Image container with improved design
          Container(
            width: double.infinity,
            height: 400,
            margin: EdgeInsets.only(bottom: isSmallScreen ? 24 : 40),

            child: ClipRRect(
              child: Image.asset(
                data.imagePath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  // Fallback to icon if image fails to load
                  return Icon(
                    data.icon,
                    size: 320 * 0.4,
                    color: theme.colorScheme.primary.withOpacity(0.6),
                  );
                },
              ),
            ),
          ),
          
          // Title with improved typography
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isWideScreen ? 40 : 0,
            ),
            child: Text(
              data.title,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: AppTheme.textColor,
                height: 1.2,
              ),
            ),
          ),
          
          SizedBox(height: isSmallScreen ? 16 : 24),
          
          // Description with better spacing
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isWideScreen ? 60 : 16,
            ),
            child: Text(
              data.description,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Color(0xFF696984),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}