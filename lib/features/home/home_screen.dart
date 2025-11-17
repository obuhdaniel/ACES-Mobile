// aces_home_screen.dart
import 'package:aces_uniben/config/app_theme.dart' hide AppTheme;
import 'package:aces_uniben/features/auth/providers/auth_provider.dart';
import 'package:aces_uniben/features/home/test_page.dart';
import 'package:aces_uniben/features/home/widgets/auto_carousel_widgets.dart';
import 'package:aces_uniben/features/tools/timetable/models/timetabole_data_model.dart';
import 'package:aces_uniben/features/tools/timetable/providers/timetable_provider.dart';
import 'package:aces_uniben/features/tools/timetable/view_timetable_screen.dart';
import 'package:aces_uniben/features/tools/todo/providers/todo_providers.dart';
import 'package:aces_uniben/features/tools/todo/view_todo_screen.dart';
import 'package:aces_uniben/features/updates/models/updates_model.dart';
import 'package:aces_uniben/features/updates/providers/updates_provider.dart';
import 'package:aces_uniben/features/updates/updates_screen.dart';
import 'package:aces_uniben/services/check_notifications_permissions.dart';
import 'package:aces_uniben/services/webview_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ACESHomeScreen extends StatefulWidget {
  const ACESHomeScreen({super.key});

  @override
  State<ACESHomeScreen> createState() => _ACESHomeScreenState();
}

class _ACESHomeScreenState extends State<ACESHomeScreen> {
  Future<void> _loadGreetingMessage() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.loadUser();
  }

  @override
  void initState() {
    super.initState();
    _loadGreetingMessage();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TodoProvider>(context, listen: false).loadTodayStats();
      Provider.of<AuthProvider>(context, listen: false).loadUser();
      Provider.of<AuthProvider>(context, listen: false).getCurrentSemester();
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final timetableProvider =
          Provider.of<TimeTableProvider>(context, listen: false);
      final userLevel = authProvider.user?.level ?? '500L';
      final userSemester = authProvider.semester ?? 'First';
      NotificationPermissionDialog.show(context);

      timetableProvider.getEntriesForToday(userLevel, userSemester);
    });
  }

  String _getGreeting() {
    int hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Morning';
    } else if (hour < 17) {
      return 'Afternoon';
    } else {
      return 'Evening';
    }
  }

  final exploreItems = [
    {
      'icon': 'assets/images/h.png',
      'route': '/learn2',
      'label': 'Hardware Club',
      'color': const Color(0xFF0FACAC).withOpacity(0.1)
    },
    {
      'icon': 'assets/images/s.png',
      'route': '/learn',
      'label': 'Software Club',
      'color': const Color(0xFF98FF98).withOpacity(0.1)
    },
    {
      'icon': 'assets/images/m.png',
      'route': '/mhs',
      'label': 'MHS',
      'color': const Color(0xFF0FACAC).withOpacity(0.05)
    },
    {
      'icon': 'assets/images/j.png',
      'route': '/journal',
      'label': 'Journal',
      'color': const Color(0xFFFFFFFF).withOpacity(0.2)
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Consumer<TodoProvider>(
        builder: (context, todoProvider, child) => SafeArea(
          child: Consumer<AuthProvider>(
            builder: (context, authProvider, child) => CustomScrollView(
              slivers: [
                // Custom App Bar
                SliverToBoxAdapter(
                  child: _buildHeader(context, authProvider),
                ),

                // Main Content
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      const SizedBox(height: 20),

                      // Task Progress Card
                      _buildTaskProgressCard(
                          context,
                          todoProvider.todayCompletionPercentage,
                          todoProvider.todayPendingTasks),

                      const SizedBox(height: 30),

                      // Today's Classes Section
                      _buildTodayClassesSection(context, authProvider),

                      const SizedBox(height: 30),

                      // Mental Health Section
                      _buildMentalHealthSection(context),

                      const SizedBox(height: 30),

                      // Explore Section
                      _buildExploreSection(context),

                      const SizedBox(height: 30),

                      // Announcements & News Section
                      _buildAnnouncementsSection(),

                      const SizedBox(
                          height: 100), // Bottom padding for navigation
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AuthProvider authProvider) {
    final userName = authProvider.user?.name ?? '';
    final firstName =
        userName.split(' ').isNotEmpty ? userName.split(' ')[1] : '';

    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          const Icon(
            Icons.wb_sunny_outlined,
            color: AppTheme.primaryTeal,
            size: 28,
          ),
          const SizedBox(width: 10),

          // Greeting text with responsiveness
          Flexible(
            child: Text(
              '${_getGreeting()}, $firstName!',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.textColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskProgressCard(
      BuildContext context, double taskProgress, int pendingTasks) {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pendingTasks == 0
                      ? 'All tasks completed!\nGreat job!'
                      : 'You have $pendingTasks task${pendingTasks == 1 ? '' : 's'}\nleft to do today',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: AppTheme.primaryTeal,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // Navigate to todo screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const TodoDisplayPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D8F),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'View Task',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Progress Circle
          SizedBox(
            width: 80,
            height: 80,
            child: Stack(
              children: [
                const SizedBox(
                  width: 80,
                  height: 80,
                  child: CircularProgressIndicator(
                    value: 1.0,
                    strokeWidth: 12,
                    backgroundColor: Color(0xffE3F2F2),
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Colors.transparent),
                  ),
                ),
                // Progress circle
                SizedBox(
                  width: 80,
                  height: 80,
                  child: CircularProgressIndicator(
                    value: taskProgress,
                    strokeWidth: 12,
                    strokeCap: StrokeCap.round,
                    backgroundColor: Colors.transparent,
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Color(0xFF2E7D8F)),
                  ),
                ),
                // Percentage text
                Center(
                  child: Text(
                    '${(taskProgress * 100).toInt()}%',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryTeal,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayClassesSection(
      BuildContext context, AuthProvider authProvider) {
    return Consumer<TimeTableProvider>(
        builder: (context, timetableProvider, child) {
      final now = DateTime.now();
      final userLevel = authProvider.user?.level ?? '100L';
      final userSemester = authProvider.semester ?? 'First';
      final dayOfWeek = _getDayName(now.weekday);

      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(
          'Today Classes',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppTheme.textColor,
          ),
        ),
        const SizedBox(height: 16),

        if (timetableProvider.isLoading)
          const Center(child: CircularProgressIndicator()),

        // Error state
        if (timetableProvider.error != null)
          _buildErrorState(context, timetableProvider, userLevel, userSemester),

        if (!timetableProvider.isLoading &&
            timetableProvider.error == null &&
            timetableProvider.timeTableEntries.isEmpty)
          _buildEmptyState(),

        // Classes list (horizontal scroll)
        if (!timetableProvider.isLoading &&
            timetableProvider.error == null &&
            timetableProvider.timeTableEntries.isNotEmpty)
          SizedBox(
            height: 260,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: timetableProvider.timeTableEntries.length,
              itemBuilder: (context, index) {
                final entry = timetableProvider.timeTableEntries[index];

                // Find the schedule for today
                final todaySchedule = entry.days.firstWhere(
                  (day) => day.day == dayOfWeek,
                  orElse: () =>
                      DaySchedule(day: '', startTime: '', endTime: ''),
                );

                return _buildClassCard(
                  context,
                  courseCode: entry.courseCode,
                  // courseTitle: entry.courseTitle,
                  time:
                      '${_formatTime(todaySchedule.startTime)} - ${_formatTime(todaySchedule.endTime)}',
                  date:
                      '${dayOfWeek.substring(0, 3)} ${now.day} ${_getMonthName(now.month)}',
                  // lecturers: entry.lecturers.join(', '),
                  isFirst: index == 0,
                );
              },
            ),
          ),

        // Refresh button
        if (!timetableProvider.isLoading)
          _buildRefreshButton(
              context, timetableProvider, userLevel, userSemester),
      ]);
    });
  }

  Widget _buildClassCard(
    BuildContext context, {
    required String courseCode,
    required String time,
    required String date,
    bool isFirst = false,
    String? location,
    String? instructor,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 320,
        margin: EdgeInsets.only(right: 16, left: isFirst ? 16 : 0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              const Color(0xFF98FF98).withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFF98FF98).withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryTeal.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
              spreadRadius: 0,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with date and status indicator
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildDateChip(date),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Main content area
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Course code
                              Text(
                                courseCode,
                                style: GoogleFonts.poppins(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.textColor,
                                  letterSpacing: -0.5,
                                ),
                              ),

                              const SizedBox(height: 8),

                              // Time
                              _buildInfoRow(
                                Icons.access_time_rounded,
                                time,
                                AppTheme.primaryTeal,
                              ),

                              const SizedBox(height: 6),

                              // Location (if provided)
                              if (location != null)
                                _buildInfoRow(
                                  Icons.location_on_rounded,
                                  location,
                                  Colors.orange.shade600,
                                ),

                              const SizedBox(height: 6),

                              // Instructor (if provided)
                              if (instructor != null)
                                _buildInfoRow(
                                  Icons.person_rounded,
                                  instructor,
                                  Colors.purple.shade600,
                                ),
                            ],
                          ),
                        ),

                        // Decorative illustration
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryTeal.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Image.asset(
                            'assets/images/timetable.png',
                            width: 64,
                            height: 64,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: _buildActionButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => TimeTableScreen(),
                                  ));
                            },
                            label: 'View Timetable',
                            icon: Icons.calendar_view_day_rounded,
                            isPrimary: true,
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(
      BuildContext context,
      TimeTableProvider timetableProvider,
      String userLevel,
      String userSemester) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Colors.red.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.red.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 50, color: Colors.red),
          const SizedBox(height: 12),
          Text(
            'Error loading timetable',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            timetableProvider.error ?? '',
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.black54),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () =>
                timetableProvider.getEntriesForToday(userLevel, userSemester),
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Colors.grey.shade100],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(Icons.event_busy, size: 50, color: Colors.grey),
          const SizedBox(height: 12),
          Text(
            'No classes today!',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Enjoy your free time 🎉',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRefreshButton(
      BuildContext context,
      TimeTableProvider timetableProvider,
      String userLevel,
      String userSemester) {
    return Align(
      alignment: Alignment.centerRight,
      child: ElevatedButton.icon(
        onPressed: () =>
            timetableProvider.fetchAndSyncTimeTable(s: userSemester, l: userLevel),
        icon: const Icon(Icons.refresh, size: 18),
        label: const Text('Sync'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryTeal,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildDateChip(String date) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.primaryTeal.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.primaryTeal.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.calendar_today_rounded,
            size: 14,
            color: AppTheme.primaryTeal,
          ),
          const SizedBox(width: 6),
          Text(
            date,
            style: GoogleFonts.poppins(
              color: AppTheme.primaryTeal,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 14,
            color: color,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: AppTheme.textColor.withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required VoidCallback? onPressed,
    required String label,
    required IconData icon,
    bool isPrimary = false,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(
        icon,
        size: 16,
      ),
      label: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor:
            isPrimary ? AppTheme.primaryTeal : Colors.grey.shade100,
        foregroundColor: isPrimary ? Colors.white : AppTheme.textColor,
        elevation: isPrimary ? 2 : 0,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: isPrimary
              ? BorderSide.none
              : BorderSide(color: Colors.grey.shade300),
        ),
      ),
    );
  }

  Widget _buildMentalHealthSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mental Health',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppTheme.textColor,
          ),
        ),
        const SizedBox(height: 16),
        AutoCarouselWidget(
          onQuizTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => WebviewWidget(
                        url: "https://xavierscript.github.io/ACES-MHS/trivia",
                        title: 'Take a Quiz',
                      )), // Replace with your QuizPage
            );
          },
          onMentalHealthTestTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      TestPage()), // Replace with your TestPage
            );
          },
        ),
      ],
    );
  }

  Widget _buildExploreSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Explore',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppTheme.textColor,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16.w,
            mainAxisSpacing: 16.h,
            childAspectRatio: 1.2, // keeps nice square-ish cards
          ),
          itemCount: exploreItems.length,
          itemBuilder: (context, index) {
            final item = exploreItems[index];
            return GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, item['route'] as String);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: item['color'] as Color,
                  borderRadius: BorderRadius.circular(20.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8.r,
                      offset: Offset(0, 4.h),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 48.w,
                      height: 48.w,
                      child: Image.asset(
                        item['icon'] as String,
                        fit: BoxFit.contain,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      item['label'] as String,
                      style: GoogleFonts.poppins(
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          },
        )
      ],
    );
  }

  Widget _buildSectionTitle(String title, VoidCallback? onSeeAll) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryTeal,
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: onSeeAll,
            child: Text(
              'See All',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textColor.withOpacity(0.6),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildMainAnnouncementCard(
      AnnouncementItem announcement, UpdatesProvider provider, VoidCallback onViewMore) {
    return GestureDetector(
      onTap: onViewMore,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.grey.withOpacity(0.2),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              child: announcement.imageUrl != null
                  ? Image.network(
                      announcement.imageUrl!,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 200,
                        width: double.infinity,
                        color: Colors.orangeAccent.withOpacity(0.2),
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.image,
                          size: 40,
                          color: Colors.grey,
                        ),
                      ),
                    )
                  : Container(
                      height: 200,
                      width: double.infinity,
                      color: Colors.orangeAccent.withOpacity(0.2),
                      child: _buildImagePlaceholder(),
                    ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    announcement.title,
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    announcement.description,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      color: AppTheme.textColor,
                      height: 1.4,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: onViewMore,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'View More',
                      style: TextStyle(
                        color: Color(0xFF2E7D8F),
                        fontWeight: FontWeight.w600,
                      ),
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

  Widget _buildImagePlaceholder() {
    return Container(
      color: Colors.grey.shade200,
      child: Icon(
        Icons.image_outlined,
        color: Colors.grey.shade400,
        size: 32,
      ),
    );
  }

  Widget _buildAnnouncementsSection() {
    return Consumer<UpdatesProvider>(
      builder: (context, updatesProvider, child) {
        final announcementResponse = updatesProvider.announcementPosts;
        final announcements = announcementResponse?.entries.posts ?? [];

        final mainAnnouncement =
            announcements.isNotEmpty ? announcements.first : null;
        final otherAnnouncements =
            announcements.length > 1 ? announcements.sublist(1) : [];

        // Show error state
        if (updatesProvider.error != null && announcements.isEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Announcements', () {
                updatesProvider.refresh();
              }),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: Colors.grey.withOpacity(0.2), width: 1.5),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.error_outline,
                        color: Colors.red, size: 40),
                    const SizedBox(height: 8),
                    Text(
                      updatesProvider.error!,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(color: Colors.grey),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => updatesProvider.refresh(),
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
            ],
          );
        }

        // Show empty state
        if (announcements.isEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Announcements', () {
                updatesProvider.refresh();
              }),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: Colors.grey.withOpacity(0.2), width: 1.5),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.announcement,
                        color: Colors.grey, size: 40),
                    const SizedBox(height: 8),
                    Text(
                      'No announcements available',
                      style: GoogleFonts.poppins(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          );
        }

        // Show announcements data
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Announcements', () {
              Navigator.push(context, MaterialPageRoute(builder: (_) {
                return const UpdatesPage();
              }));
            }),
            const SizedBox(height: 16),
            if (mainAnnouncement != null)
              _buildMainAnnouncementCard(mainAnnouncement, updatesProvider, () {
             UpdatesNavigationHandler.navigateToPostDetail(context, mainAnnouncement, 'announcement');
            }),
          ],
        );
      },
    );
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'Monday';
      case DateTime.tuesday:
        return 'Tuesday';
      case DateTime.wednesday:
        return 'Wednesday';
      case DateTime.thursday:
        return 'Thursday';
      case DateTime.friday:
        return 'Friday';
      case DateTime.saturday:
        return 'Saturday';
      case DateTime.sunday:
        return 'Sunday';
      default:
        return 'Monday';
    }
  }

  String _getMonthName(int month) {
    switch (month) {
      case 1:
        return 'Jan';
      case 2:
        return 'Feb';
      case 3:
        return 'Mar';
      case 4:
        return 'Apr';
      case 5:
        return 'May';
      case 6:
        return 'Jun';
      case 7:
        return 'Jul';
      case 8:
        return 'Aug';
      case 9:
        return 'Sep';
      case 10:
        return 'Oct';
      case 11:
        return 'Nov';
      case 12:
        return 'Dec';
      default:
        return '';
    }
  }

  String _formatTime(String time) {
    try {
      final timeParts = time.split(':');
      final hour = int.parse(timeParts[0]);
      final minute = timeParts[1];

      if (hour == 0) {
        return '12:$minute AM';
      } else if (hour < 12) {
        return '$hour:$minute AM';
      } else if (hour == 12) {
        return '12:$minute PM';
      } else {
        return '${hour - 12}:$minute PM';
      }
    } catch (e) {
      return time;
    }
  }
}
