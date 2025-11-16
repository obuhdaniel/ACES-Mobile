import 'package:aces_uniben/config/app_theme.dart';
import 'package:aces_uniben/features/tools/timetable/models/timetabole_data_model.dart';
import 'package:aces_uniben/features/tools/timetable/providers/timetable_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:aces_uniben/features/auth/providers/auth_provider.dart';

class TimeTableScreen extends StatefulWidget {
  @override
  _TimeTableScreenState createState() => _TimeTableScreenState();
}

class _TimeTableScreenState extends State<TimeTableScreen> {
  String selectedDay = 'Mon';
  String selectedSemester = 'Second';
  String selectedLevel = '500L';

  final List<String> days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'];
  final List<String> semesters = ['First', 'Second'];
  final List<String> levels = ['100L', '200L', '300L', '400L', '500L'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTimeTable();
    });
  }

  void _loadTimeTable() {
    final timetableProvider = context.read<TimeTableProvider>();
    timetableProvider.getEntriesForDay(
        selectedLevel, selectedSemester, _getFullDayName(selectedDay));
  }

  void _loadTimeTableWithParameters(String level, String semester) {
    final timetableProvider = context.read<TimeTableProvider>();
    timetableProvider.getEntriesForDay(
        level, semester, _getFullDayName(selectedDay));
  }

  String _getFullDayName(String shortDay) {
    switch (shortDay) {
      case 'Mon':
        return 'Monday';
      case 'Tue':
        return 'Tuesday';
      case 'Wed':
        return 'Wednesday';
      case 'Thu':
        return 'Thursday';
      case 'Fri':
        return 'Friday';
      case 'Sat':
        return 'Saturday';
      case 'Sun':
        return 'Sunday';
      default:
        return 'Monday';
    }
  }

  String _getShortDayName(String fullDay) {
    switch (fullDay) {
      case 'Monday':
        return 'Mon';
      case 'Tuesday':
        return 'Tue';
      case 'Wednesday':
        return 'Wed';
      case 'Thursday':
        return 'Thu';
      case 'Friday':
        return 'Fri';
      case 'Saturday':
        return 'Sat';
      case 'Sunday':
        return 'Sun';
      default:
        return 'Mon';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<TimeTableProvider, AuthProvider>(
      builder: (context, timetableProvider, authProvider, child) {
        // Auto-select current user's level if available
        final userLevel = authProvider.user?.level;
        final userSemester = authProvider.semester;
        if (userLevel != null && userLevel != selectedLevel) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() {
              selectedLevel = userLevel;
              selectedSemester = userSemester ?? 'Second';
            });
            _loadTimeTable();
          });
        }

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: Container(
              margin: const EdgeInsets.only(left: 16),
              decoration: BoxDecoration(
                color: Color(0xFFE5FFE5),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.grey[600]),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            title: Text(
              'Time Table',
              style: GoogleFonts.poppins(
                color: AppTheme.primaryTeal,
                fontSize: 24,
                fontWeight: FontWeight.w500,
              ),
            ),
            centerTitle: true,
            actions: [
              if (timetableProvider.isLoading)
                const Padding(
                  padding: EdgeInsets.only(right: 16),
                  child: Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(Color(0xFF2E8B7B)),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          body: Column(
            children: [
              SizedBox(height: 10),
              Container(
                margin: const EdgeInsets.only(left: 10),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: days.map((day) {
                      bool isSelected = day == selectedDay;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedDay = day;
                          });
                          _loadTimeTable();
                        },
                        child: Container(
                          width: 80, // fixed width for equal sizing
                          height: 80, // fixed height for square/box look
                          margin: const EdgeInsets.only(right: 8),
                          alignment: Alignment.center, // centers text inside
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppTheme.primaryTeal
                                : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 5,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            day,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              color: isSelected
                                  ? Colors.white
                                  : AppTheme.textColor,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

              // Dropdowns
              Container(
                color: Colors.white,
                margin: const EdgeInsets.only(top: 20),
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Color(0xFF8F9BB3)),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedSemester,
                            isExpanded: true,
                            icon: const Icon(Icons.keyboard_arrow_down,
                                color: Color(0xFF2E8B7B)),
                            style: GoogleFonts.poppins(
                              color: AppTheme.primaryTeal,
                              fontSize: 14,
                            ),
                            items: semesters.map((String semester) {
                              return DropdownMenuItem<String>(
                                value: semester,
                                child: Text('$semester Semester'),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                selectedSemester = newValue!;
                              });
                              _loadTimeTableWithParameters(
                                  selectedLevel, newValue!);
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFF8F9BB3)),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            selectedLevel, // just display the chosen level
                            style: GoogleFonts.poppins(
                              color: const Color(0xFF2E8B7B),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Icon(
                            Icons
                                .lock, // optional: show a lock to indicate it's fixed
                            color: Color(0xFF2E8B7B),
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Error message
              if (timetableProvider.error != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.red[50],
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          timetableProvider.error!,
                          style: GoogleFonts.poppins(color: Colors.red),
                        ),
                      ),
                      TextButton(
                        onPressed: _loadTimeTable,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),

              // Empty state
              if (!timetableProvider.isLoading &&
                  timetableProvider.error == null &&
                  timetableProvider.timeTableEntries.isEmpty)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.event_busy,
                            size: 64, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text(
                          'No classes on $selectedDay',
                          style: GoogleFonts.poppins(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Select another day or check your filters',
                          style: GoogleFonts.poppins(
                            color: Colors.grey[500],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Schedule cards
              if (!timetableProvider.isLoading &&
                  timetableProvider.error == null &&
                  timetableProvider.timeTableEntries.isNotEmpty)
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      ...timetableProvider.timeTableEntries.map((entry) {
                        // Find the schedule for the selected day
                        final daySchedule = entry.days.firstWhere(
                          (day) => _getShortDayName(day.day) == selectedDay,
                          orElse: () =>
                              DaySchedule(day: '', startTime: '', endTime: ''),
                        );

                        // Check if this is the current class (for highlighting)
                        final now = DateTime.now();
                        final currentTime =
                            '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
                        final isCurrentClass = _isCurrentClass(
                            daySchedule.startTime,
                            daySchedule.endTime,
                            currentTime);
                        final isToday = selectedDay ==
                            _getShortDayName(_getDayName(now.weekday));

                        return Column(
                          children: [
                            _buildScheduleCard(
                              time:
                                  _formatTimeForDisplay(daySchedule.startTime),
                              endTime:
                                  _formatTimeForDisplay(daySchedule.endTime),
                              course: entry.courseCode,
                              title: entry.courseTitle,
                              lecturers: entry.lecturers,
                              isHighlighted: isToday && isCurrentClass,
                            ),
                          ],
                        );
                      }).toList(),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  bool _isCurrentClass(String startTime, String endTime, String currentTime) {
    try {
      final start = _timeToMinutes(startTime);
      final end = _timeToMinutes(endTime);
      final current = _timeToMinutes(currentTime);
      return current >= start && current <= end;
    } catch (e) {
      return false;
    }
  }

  int _timeToMinutes(String time) {
    final parts = time.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    return hour * 60 + minute;
  }

  String _formatTimeForDisplay(String time) {
    try {
      final parts = time.split(':');
      final hour = int.parse(parts[0]);
      final minute = parts[1];

      if (hour == 0) return '12:$minute AM';
      if (hour < 12) return '$hour:$minute AM';
      if (hour == 12) return '12:$minute PM';
      return '${hour - 12}:$minute PM';
    } catch (e) {
      return time;
    }
  }

  Widget _buildScheduleCard({
    required String time,
    required String endTime,
    required String course,
    required String title,
    required List<String> lecturers,
    required bool isHighlighted,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Time section
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    time
                        .split(' ')[0]
                        .padLeft(5, '0'), // Ensure time is in 08:00 format
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF212525),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    endTime,
                    style: GoogleFonts.poppins(
                      color: const Color(0xFFBCC1CD),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),

            // Vertical divider
            Container(
              width: 2,
              color: Color(0xFFE8F0F3),
            ),
            const SizedBox(width: 16),

            // Course details container
            Expanded(
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: isHighlighted
                          ? AppTheme.primaryTeal
                          : const Color(0xFF98FF98).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            course,
                            style: GoogleFonts.poppins(
                              color: isHighlighted
                                  ? Colors.white
                                  : const Color(0xFF2F327D),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            title,
                            style: GoogleFonts.poppins(
                              color: isHighlighted
                                  ? Colors.white
                                  : const Color(0xFF2F327D),
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),

                          // Lecturers
                          ...lecturers
                              .map((lecturer) => Padding(
                                    padding: const EdgeInsets.only(bottom: 2),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 6,
                                          height: 6,
                                          decoration: BoxDecoration(
                                            color: isHighlighted
                                                ? Colors.white
                                                : const Color(0xFF2F327D),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            lecturer,
                                            style: GoogleFonts.poppins(
                                              color: isHighlighted
                                                  ? Colors.white70
                                                  : const Color(0xFF2F327D),
                                              fontSize: 12,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ))
                              .toList(),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 14,
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  } // Helper method to get day name from weekday number

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
}
