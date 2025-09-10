import 'package:aces_uniben/features/home/home_screen.dart';
import 'package:aces_uniben/features/learn/page.dart';
import 'package:aces_uniben/features/profile/profile_screen.dart';
import 'package:aces_uniben/features/tools/tools_screen.dart';
import 'package:aces_uniben/features/updates/updates_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class MainNavigationScreen extends StatefulWidget {
  final int initialIndex;
  final bool initialIsSoftware;

  const MainNavigationScreen({
    super.key,
    this.initialIndex = 0,
    this.initialIsSoftware = true,
  });

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  late int _currentIndex;
  late bool _currentIsSoftware;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _currentIsSoftware = widget.initialIsSoftware;
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _screens = [
      const HomeScreen(),
      TechLearningPage(
        isSoftware: _currentIsSoftware,
      ),
      const UpdatesPage(),
      const ToolsPage(),
      const ProfileScreen(),
    ];
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10.r,
            offset: Offset(0, -2.h),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: _buildNavItem(
                  context,
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home,
                  label: 'Home',
                  index: 0,
                ),
              ),
              Flexible(
                child: _buildNavItem(
                  context,
                  icon: Icons.school_outlined,
                  activeIcon: Icons.school,
                  label: 'Learn',
                  index: 1,
                ),
              ),
              Flexible(
                child: _buildNavItem(
                  context,
                  icon: Icons.notifications_outlined,
                  activeIcon: Icons.notifications,
                  label: 'Updates',
                  index: 2,
                ),
              ),
              Flexible(
                child: _buildNavItem(
                  context,
                  icon: Icons.build_outlined,
                  activeIcon: Icons.build,
                  label: 'Tools',
                  index: 3,
                ),
              ),
              Flexible(
                child: _buildNavItem(
                  context,
                  icon: Icons.person_outline,
                  activeIcon: Icons.person,
                  label: 'Profile',
                  index: 4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
  }) {
    final isSelected = currentIndex == index;

    return GestureDetector(
      onTap: () => onTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF2E7D8F).withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                isSelected ? activeIcon : icon,
                key: ValueKey(isSelected),
                color: isSelected ? const Color(0xFF2E7D8F) : Colors.grey[600],
                size: 22.sp,
              ),
            ),
            SizedBox(height: 4.h),
            FittedBox(
              child: Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 11.sp,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color:
                      isSelected ? const Color(0xFF2E7D8F) : Colors.grey[600],
                ),
              ),
            ),
            if (isSelected) ...[
              SizedBox(height: 2.h),
              Container(
                width: 4.w,
                height: 4.w,
                decoration: const BoxDecoration(
                  color: Color(0xFF2E7D8F),
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Placeholder Screens (replace with your actual screens)
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ACESHomeScreen(); // We'll create this next
  }
}
