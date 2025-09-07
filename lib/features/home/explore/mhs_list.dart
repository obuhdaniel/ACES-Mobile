import 'package:aces_uniben/config/app_theme.dart';
import 'package:aces_uniben/features/home/explore/mhs_tools.dart';
import 'package:aces_uniben/features/profile/widgets/first_aid_screen.dart';
import 'package:aces_uniben/features/updates/providers/updates_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class MentalHealthToolsScreen extends StatefulWidget {
  @override
  _MentalHealthToolsScreenState createState() =>
      _MentalHealthToolsScreenState();
}

class _MentalHealthToolsScreenState extends State<MentalHealthToolsScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: Duration(milliseconds: 1200),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.3),
      end: Offset(0, 0),
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body:
          Consumer3<SleepTrackerProvider, MoodTrackerProvider, UpdatesProvider>(
              builder: (context, sleepProvider, moodProvider, updatesProvider,
                  child) {
        final sleepdata = sleepProvider.getAnalytics(period: '7 Days');
        final mooddata = moodProvider.getAnalytics(period: '7 Days');
        return SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: CustomScrollView(
                slivers: [
                  _buildHeader(),
                  _buildToolsGrid(
                    sleepdata,
                    mooddata,
                    updatesProvider,
                  ),
                  _buildEmergencySection(),
                  SliverToBoxAdapter(child: SizedBox(height: 20)),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildHeader() {
    return SliverToBoxAdapter(
      child: Container(
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primaryTeal,
              AppTheme.primaryTeal.withOpacity(0.8),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'MHS Support Tools',
              style: GoogleFonts.nunito(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Your daily companion for mental health',
              style: GoogleFonts.nunito(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolsGrid(SleepAnalytics sleepProvider,
      MoodAnalytics moodProvider, UpdatesProvider updatesProvider) {
    final tools = [
      ToolItem(
        'Sleep Tracker',
        'Monitor your sleep patterns',
        Icons.bedtime,
        AppTheme.primaryTeal,
        '${sleepProvider.dailyAverage.toStringAsFixed(1)} hours',
      ),
      ToolItem(
        'Mood Tracker',
        'Track daily emotional wellness',
        Icons.sentiment_satisfied,
        AppTheme.accentOrange,
        'Mood: ${getMoodEmoji(moodProvider.dailyAverage.toInt())}',
      ),
      ToolItem(
        'Articles',
        'MHS Articles',
        Icons.article,
        AppTheme.accentOrange,
        '${updatesProvider.mhsPosts?.total} Articles',
      ),
    ];

    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.8,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) => _buildToolCard(tools[index], index),
          childCount: tools.length,
        ),
      ),
    );
  }

  Widget _buildToolCard(ToolItem tool, int index) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 800 + (index * 100)),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: GestureDetector(
            onTap: () => _onToolTap(tool.title),
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.cardBackground,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: tool.color.withOpacity(0.1),
                    blurRadius: 20,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: tool.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        tool.icon,
                        color: tool.color,
                        size: 28,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      tool.title,
                      style: GoogleFonts.nunito(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textColor,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      tool.subtitle,
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: AppTheme.textColor.withOpacity(0.6),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          tool.status,
                          style: GoogleFonts.nunito(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: tool.color,
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: AppTheme.textColor.withOpacity(0.4),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmergencySection() {
    return SliverToBoxAdapter(
      child: Container(
        margin: EdgeInsets.all(20),
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.red.shade400, Colors.red.shade600],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.red.withOpacity(0.3),
              blurRadius: 20,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.emergency, color: Colors.white, size: 24),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Emergency Resources',
                    style: GoogleFonts.nunito(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              'Need immediate help? Access crisis helplines and emergency support.',
              style: GoogleFonts.nunito(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _onEmergencyTap(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.red.shade600,
                elevation: 0,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.phone, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Get Help Now',
                    style: GoogleFonts.nunito(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onToolTap(String toolName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Opening $toolName...',
          style: GoogleFonts.nunito(fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppTheme.primaryTeal,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );

    switch (toolName) {
      case 'Sleep Tracker':
        Navigator.pushNamed(context, '/sleep');
        break;
      case 'Mood Tracker':
        Navigator.pushNamed(context, '/mood');
        break;
      case 'Articles':
        Navigator.pushNamed(context, '/mhs2');
        break;

      default:
        Navigator.pushNamed(context, '/mhs2');
    }
  }

  void _onEmergencyTap() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => FirstAidScreen()));
  }
}

class ToolItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String status;

  ToolItem(this.title, this.subtitle, this.icon, this.color, this.status);
}

String getMoodEmoji(int moodLevel) {
  switch (moodLevel) {
    case 1:
      return '😢';
    case 2:
      return '☹️';
    case 3:
      return '😐';
    case 4:
      return '🙂';
    case 5:
      return '😄';
    default:
      return '😐';
  }
}
