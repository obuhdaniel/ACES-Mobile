import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';

class AppTheme {
  static const Color textColor = Color(0xFF2C3E50);
  static const Color primaryTeal = Color(0xFF008B8B);
  static const Color accentOrange = Color(0xFFFF7043);
  static const Color accentPurple = Color(0xFF9C27B0);
}

class AutoCarouselWidget extends StatefulWidget {
  final VoidCallback? onQuizTap;
  final VoidCallback? onMentalHealthTestTap;

  const AutoCarouselWidget({
    Key? key,
    this.onQuizTap,
    this.onMentalHealthTestTap,
  }) : super(key: key);

  @override
  _AutoCarouselWidgetState createState() => _AutoCarouselWidgetState();
}

class _AutoCarouselWidgetState extends State<AutoCarouselWidget>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late Timer _autoSlideTimer;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  
  int _currentIndex = 0;
  bool _isAutoSliding = true;

  final List<CarouselItem> _items = [
    CarouselItem(
      title: 'Take a Quiz',
      description: 'Engage your Mind with\nFun and insightful Quizzes',
      imagePath: 'assets/images/quiz.png',
      gradientColors: [
        AppTheme.primaryTeal.withOpacity(0.05),
        AppTheme.primaryTeal.withOpacity(0.02),
      ],
      accentColor: AppTheme.primaryTeal,
      icon: Icons.quiz_outlined,
    ),
    CarouselItem(
      title: 'Take a Test',
      description: 'Assess your mental health with personalized tests',
      imagePath: 'assets/images/test-2.png', // Add your mental health image
      gradientColors: [
        AppTheme.accentPurple.withOpacity(0.05),
        AppTheme.accentPurple.withOpacity(0.02),
      ],
      accentColor: AppTheme.accentPurple,
      icon: Icons.psychology_outlined,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _startAutoSlide();
    _fadeController.forward();
  }

  void _startAutoSlide() {
    _autoSlideTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_isAutoSliding && mounted) {
        _nextPage();
      }
    });
  }

  void _nextPage() {
    if (_currentIndex < _items.length - 1) {
      _currentIndex++;
    } else {
      _currentIndex = 0;
    }
    
    _pageController.animateToPage(
      _currentIndex,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOutCubic,
    );
  }

  void _pauseAutoSlide() {
    setState(() {
      _isAutoSliding = false;
    });
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _isAutoSliding = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _autoSlideTimer.cancel();
    _pageController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        height: 180,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, 6),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Stack(
          children: [
            // Main carousel
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemCount: _items.length,
                itemBuilder: (context, index) {
                  return _buildCarouselItem(_items[index], index);
                },
              ),
            ),
            
            // Page indicators
            Positioned(
              bottom: 16,
              left: 20,
              child: Row(
                children: List.generate(_items.length, (index) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.only(right: 8),
                    width: _currentIndex == index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentIndex == index
                          ? _items[_currentIndex].accentColor
                          : Colors.white.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
            ),
            
            // Tap areas for navigation
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      _pauseAutoSlide();
                      if (_currentIndex == 0) {
                        widget.onQuizTap?.call();
                      } else {
                        // Navigate to quiz page
                        _pageController.animateToPage(
                          0,
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    child: Container(
                      color: Colors.transparent,
                      height: double.infinity,
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      _pauseAutoSlide();
                      if (_currentIndex == 1) {
                        widget.onMentalHealthTestTap?.call();
                      } else {
                        // Navigate to mental health test page
                        _pageController.animateToPage(
                          1,
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    child: Container(
                      color: Colors.transparent,
                      height: double.infinity,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCarouselItem(CarouselItem item, int index) {
    return GestureDetector(
      onTap: () {
        _pauseAutoSlide();
        if (index == 0) {
          widget.onQuizTap?.call();
        } else {
          widget.onMentalHealthTestTap?.call();
        }
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              ...item.gradientColors,
            ],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Icon and title row
                    Row(
                      children: [
                       
                        Expanded(
                          child: Text(
                            item.title,
                            style: GoogleFonts.nunito(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    
                    // Description
                    Text(
                      item.description,
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        color: AppTheme.textColor.withOpacity(0.7),
                        height: 1.4,
                        
                        
                      ),
                       overflow: TextOverflow.ellipsis,
                      maxLines: 2, 
                    ),
                    const SizedBox(height: 16),
                    
                    ],
                ),
              ),
              
              // Image section
              Expanded(
                flex: 2,
                child: Stack(
                  children: [
                    // Background decoration
                    Positioned(
                      right: 0,
                      top: 10,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: item.accentColor.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                    
                    // Main image
                    Center(
                      child: Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.asset(
                            item.imagePath,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              // Fallback when image is not found
                              return Container(
                                decoration: BoxDecoration(
                                  color: item.accentColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Icon(
                                  item.icon,
                                  size: 50,
                                  color: item.accentColor.withOpacity(0.7),
                                ),
                              );
                            },
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

class CarouselItem {
  final String title;
  final String description;
  final String imagePath;
  final List<Color> gradientColors;
  final Color accentColor;
  final IconData icon;

  CarouselItem({
    required this.title,
    required this.description,
    required this.imagePath,
    required this.gradientColors,
    required this.accentColor,
    required this.icon,
  });
}

