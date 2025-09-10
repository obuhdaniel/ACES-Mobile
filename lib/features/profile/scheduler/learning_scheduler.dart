import 'package:aces_uniben/features/profile/scheduler/reminder_provider.dart';
import 'package:aces_uniben/services/check_notifications_permissions.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class AppTheme {
  static const Color primaryTeal = Color(0xFF166D86); // Primary color
  static const Color textColor = Color(0xFF2F327D);
  static const Color lightTeal = Color(0xFFE0F2F1);
  static const Color darkTeal = Color(0xFF00695C);
  static const Color cardBackground = Color(0xFFF8F9FA);
  static const Color textPrimary = Color(0xFF2E3440);
  static const Color textSecondary = Color(0xFF64748B);
}

// Main Reminder Settings Screen
class ReminderSettingsScreen extends StatefulWidget {
  @override
  _ReminderSettingsScreenState createState() => _ReminderSettingsScreenState();
}

class _ReminderSettingsScreenState extends State<ReminderSettingsScreen> {
  bool isReminderEnabled = true;
 

  @override
  Widget build(BuildContext context) {
     final reminderProvider = Provider.of<ReminderProvider>(context);
    final settings = reminderProvider.settings;
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title:Text(
          'Learning Reminders',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppTheme.primaryTeal,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            _buildHeaderCard(),
            const SizedBox(height: 20),

            // Enable/Disable Toggle
            _buildToggleCard(reminderProvider, settings),
            const SizedBox(height: 16),

            // Days Selection
            _buildDaysCard(reminderProvider, settings),
            const SizedBox(height: 16),

            // Time Selection
            _buildTimeCard(reminderProvider, settings),
            const SizedBox(height: 16),

            // Tech Part Selection
            _buildTechPartCard(reminderProvider, settings),
            const SizedBox(height: 16),

            // Preview Card
            _buildPreviewCard(reminderProvider, settings),
            const SizedBox(height: 24),

          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primaryTeal, AppTheme.darkTeal],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.notifications_active,
            color: Colors.white,
            size: 32,
          ),
          const SizedBox(height: 12),
          Text(
            'Stay Consistent!',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Set up daily reminders to keep your learning on track',
            style: GoogleFonts.poppins(
              color: Colors.white.withOpacity(0.9),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleCard(ReminderProvider provider, ReminderSettings settings) {

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: AppTheme.cardBackground,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color:
                    isReminderEnabled ? AppTheme.lightTeal : Colors.grey[300]!,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                isReminderEnabled
                    ? Icons.notifications
                    : Icons.notifications_off,
                color:
                    isReminderEnabled ? AppTheme.primaryTeal : Colors.grey[600],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text(
                    'Daily Reminders',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  Text(
                    settings.isReminderEnabled ? 'Active' : 'Disabled',
                    style:  GoogleFonts.poppins(
                      color: AppTheme.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: settings.isReminderEnabled,
              onChanged: (value) async {
                await provider.setReminderEnabled(value);
                await provider.testNotification();
              },
              activeColor: AppTheme.primaryTeal,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDaysCard(ReminderProvider provider, ReminderSettings settings) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: AppTheme.cardBackground,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Row(
              children: [
                Icon(Icons.calendar_today, color: AppTheme.primaryTeal),
                SizedBox(width: 12),
                Text(
                  'Learning Days',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '${settings.selectedDays.length} day${settings.selectedDays.length != 1 ? 's' : ''} selected: ${settings.selectedDays.join(', ')}',
              style:  GoogleFonts.poppins(
                color: AppTheme.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => _showDaySelectionModal(provider, settings),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppTheme.primaryTeal),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child:Text(
                  'Select Days',
                  style: GoogleFonts.poppins(
                    color: AppTheme.primaryTeal,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeCard(ReminderProvider provider, ReminderSettings settings) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: AppTheme.cardBackground,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Row(
              children: [
                Icon(Icons.access_time, color: AppTheme.primaryTeal),
                SizedBox(width: 12),
                Text(
                  'Reminder Time',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Daily at ${settings.selectedTime.format(context)}',
              style:  GoogleFonts.poppins(
                color: AppTheme.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => _showTimeSelectionModal(provider, settings),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppTheme.primaryTeal),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child:Text(
                  'Change Time',
                  style: GoogleFonts.poppins(
                    color: AppTheme.primaryTeal,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTechPartCard(ReminderProvider provider, ReminderSettings settings) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: AppTheme.cardBackground,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Row(
              children: [
                Icon(Icons.code, color: AppTheme.primaryTeal),
                SizedBox(width: 12),
                Text(
                  'Tech Focus',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              settings.selectedTechPart,
              style: GoogleFonts.poppins(
                color: AppTheme.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => _showTechPartSelectionModal(provider, settings),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppTheme.primaryTeal),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child:Text(
                  'Change Focus',
                  style: GoogleFonts.poppins(
                    color: AppTheme.primaryTeal,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewCard(ReminderProvider provider, ReminderSettings settings) {
    if (!isReminderEnabled) return const SizedBox.shrink();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: AppTheme.lightTeal,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Row(
              children: [
                Icon(Icons.preview, color: AppTheme.darkTeal),
                SizedBox(width: 12),
                Text(
                  'Reminder Preview',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.darkTeal,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.notifications_active,
                    color: AppTheme.primaryTeal,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                       Text(
                          'Time to learn!',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        Text(
                          'Ready to practice ${settings.selectedTechPart}?',
                          style:  GoogleFonts.poppins(
                            color: AppTheme.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ],
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

  
  void _showDaySelectionModal(ReminderProvider provider, ReminderSettings settings) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DaySelectionModal(
        selectedDays: settings.selectedDays,
        onDaysChanged: (days) async{
          await provider.setSelectedDays(days);
        },
      ),
    );
  }

  void _showTimeSelectionModal(ReminderProvider provider, ReminderSettings settings) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TimeSelectionModal(
        selectedTime: settings.selectedTime,
        onTimeChanged: (time) async{
         await provider.setSelectedTime(time);
        },
      ),
    );
  }

  void _showTechPartSelectionModal(ReminderProvider provider, ReminderSettings settings) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TechPartSelectionModal(
        selectedTechPart: settings.selectedTechPart,
        onTechPartChanged: (techPart) async{
         await provider.setSelectedTechPart(techPart);
        },
      ),
    );
  }

  
}

// Day Selection Modal
class DaySelectionModal extends StatefulWidget {
  final List<String> selectedDays;
  final Function(List<String>) onDaysChanged;

  DaySelectionModal({required this.selectedDays, required this.onDaysChanged});

  @override
  _DaySelectionModalState createState() => _DaySelectionModalState();
}

class _DaySelectionModalState extends State<DaySelectionModal> {
  late List<String> tempSelectedDays;
  final List<String> weekDays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];

  @override
  void initState() {
    super.initState();
    tempSelectedDays = List.from(widget.selectedDays);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
           Padding(
            padding: EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(Icons.calendar_today, color: AppTheme.primaryTeal),
                SizedBox(width: 12),
                Text(
                  'Select Learning Days',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),

          // Quick selection buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        tempSelectedDays = [
                          'Monday',
                          'Tuesday',
                          'Wednesday',
                          'Thursday',
                          'Friday'
                        ];
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppTheme.primaryTeal),
                    ),
                    child:Text('Weekdays',
                        style: GoogleFonts.poppins(color: AppTheme.primaryTeal)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        tempSelectedDays = List.from(weekDays);
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppTheme.primaryTeal),
                    ),
                    child:Text('Every Day',
                        style: GoogleFonts.poppins(color: AppTheme.primaryTeal)),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Day selection list
          ...weekDays.map((day) => _buildDayTile(day)).toList(),

          const SizedBox(height: 16),

          // Action buttons
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey[700]!),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text('Cancel',
                        style: GoogleFonts.poppins(color: Colors.grey[700])),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: tempSelectedDays.isEmpty
                        ? null
                        : () {
                            widget.onDaysChanged(tempSelectedDays);
                            Navigator.pop(context);
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryTeal,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child:Text('Apply', style: GoogleFonts.poppins(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayTile(String day) {
    bool isSelected = tempSelectedDays.contains(day);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: InkWell(
        onTap: () {
          setState(() {
            if (isSelected) {
              tempSelectedDays.remove(day);
            } else {
              tempSelectedDays.add(day);
            }
          });
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.lightTeal : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? AppTheme.primaryTeal : Colors.grey[300]!,
            ),
          ),
          child: Row(
            children: [
              Icon(
                isSelected ? Icons.check_circle : Icons.circle_outlined,
                color: isSelected ? AppTheme.primaryTeal : Colors.grey[400],
              ),
              const SizedBox(width: 12),
              Text(
                day,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: isSelected ? AppTheme.darkTeal : AppTheme.textPrimary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Time Selection Modal
class TimeSelectionModal extends StatefulWidget {
  final TimeOfDay selectedTime;
  final Function(TimeOfDay) onTimeChanged;

  TimeSelectionModal({required this.selectedTime, required this.onTimeChanged});

  @override
  _TimeSelectionModalState createState() => _TimeSelectionModalState();
}

class _TimeSelectionModalState extends State<TimeSelectionModal> {
  late TimeOfDay tempSelectedTime;
  List<TimeOfDay> quickTimes = [
    const TimeOfDay(hour: 7, minute: 0),
    const TimeOfDay(hour: 9, minute: 0),
    const TimeOfDay(hour: 12, minute: 0),
    const TimeOfDay(hour: 18, minute: 0),
    const TimeOfDay(hour: 20, minute: 0),
  ];

  @override
  void initState() {
    super.initState();
    tempSelectedTime = widget.selectedTime;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
           Padding(
            padding: EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(Icons.access_time, color: AppTheme.primaryTeal),
                SizedBox(width: 12),
                Text(
                  'Select Reminder Time',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),

          // Current time display
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.lightTeal,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.schedule, color: AppTheme.darkTeal, size: 32),
                const SizedBox(width: 16),
                Text(
                  tempSelectedTime.format(context),
                  style:  GoogleFonts.poppins(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.darkTeal,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Quick time selection
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
               Text(
                  'Quick Select',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: quickTimes
                      .map((time) => _buildQuickTimeChip(time))
                      .toList(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Custom time button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  final TimeOfDay? picked = await showTimePicker(
                    context: context,
                    initialTime: tempSelectedTime,
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          primaryColor: AppTheme.primaryTeal,
                          colorScheme:
                              const ColorScheme.light(primary: AppTheme.primaryTeal),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (picked != null) {
                    setState(() {
                      tempSelectedTime = picked;
                    });
                  }
                },
                icon: const Icon(Icons.edit_calendar, color: AppTheme.primaryTeal),
                label:Text(
                  'Custom Time',
                  style: GoogleFonts.poppins(color: AppTheme.primaryTeal),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppTheme.primaryTeal),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Action buttons
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey[700]!),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text('Cancel',
                        style: GoogleFonts.poppins(color: Colors.grey[700])),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onTimeChanged(tempSelectedTime);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryTeal,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child:Text('Apply', style: GoogleFonts.poppins(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickTimeChip(TimeOfDay time) {
    bool isSelected = time.hour == tempSelectedTime.hour &&
        time.minute == tempSelectedTime.minute;
    return GestureDetector(
      onTap: () {
        setState(() {
          tempSelectedTime = time;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryTeal : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppTheme.primaryTeal : Colors.grey[300]!,
          ),
        ),
        child: Text(
          time.format(context),
          style: GoogleFonts.poppins(
            color: isSelected ? Colors.white : AppTheme.textPrimary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

// Tech Part Selection Modal
class TechPartSelectionModal extends StatefulWidget {
  final String selectedTechPart;
  final Function(String) onTechPartChanged;

  TechPartSelectionModal(
      {required this.selectedTechPart, required this.onTechPartChanged});

  @override
  _TechPartSelectionModalState createState() => _TechPartSelectionModalState();
}

class _TechPartSelectionModalState extends State<TechPartSelectionModal> {
  late String tempSelectedTechPart;
  List<Map<String, dynamic>> techParts = [
    {
      'name': 'Mobile App Development',
      'icon': Icons.phone_android,
      'color': Colors.blue
    },
    {'name': 'Web Development', 'icon': Icons.web, 'color': Colors.cyan},
    {'name': 'Cyber Security', 'icon': Icons.security, 'color': Colors.green},
    {
      'name': 'Product Design',
      'icon': Icons.design_services,
      'color': Colors.yellow[700]
    },
    {'name': 'AI/ML', 'icon': Icons.memory, 'color': Colors.orange},
    {'name': 'Data Science', 'icon': Icons.bar_chart, 'color': Colors.purple},
    {'name': 'Hardware', 'icon': Icons.memory, 'color': Colors.indigo},
  ];

  @override
  void initState() {
    super.initState();
    tempSelectedTechPart = widget.selectedTechPart;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
           Padding(
            padding: EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(Icons.code, color: AppTheme.primaryTeal),
                SizedBox(width: 12),
                Text(
                  'Select Tech Focus',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),

          // Tech parts list
          Container(
            height: 300,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: techParts.length,
              itemBuilder: (context, index) {
                final techPart = techParts[index];
                bool isSelected = techPart['name'] == tempSelectedTechPart;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        tempSelectedTechPart = techPart['name'];
                      });
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color:
                            isSelected ? AppTheme.lightTeal : Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? AppTheme.primaryTeal
                              : Colors.grey[200]!,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppTheme.primaryTeal.withOpacity(0.1)
                                  : (techPart['color'] as Color)
                                      .withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              techPart['icon'] as IconData,
                              color: isSelected
                                  ? AppTheme.primaryTeal
                                  : techPart['color'] as Color,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              techPart['name'],
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                                color: isSelected
                                    ? AppTheme.darkTeal
                                    : AppTheme.textPrimary,
                              ),
                            ),
                          ),
                          if (isSelected)
                            const Icon(
                              Icons.check_circle,
                              color: AppTheme.primaryTeal,
                              size: 20,
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // Action buttons
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey[700]!),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text('Cancel',
                        style: GoogleFonts.poppins(color: Colors.grey[700])),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onTechPartChanged(tempSelectedTechPart);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryTeal,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child:Text('Apply', style: GoogleFonts.poppins(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Quick Setup Screen for First-Time Users
class QuickReminderSetupScreen extends StatefulWidget {

  final VoidCallback onContinue;
  final bool isSoftware;

  QuickReminderSetupScreen({
    required this.onContinue,
    required this.isSoftware,
  });

  @override
  _QuickReminderSetupScreenState createState() =>
      _QuickReminderSetupScreenState();
}

class _QuickReminderSetupScreenState extends State<QuickReminderSetupScreen> {
  int currentStep = 0;
  List<String> selectedDays = [];
  TimeOfDay selectedTime = const TimeOfDay(hour: 9, minute: 0);
  String selectedTechPart = 'Web Development';


  @override
  void initState(){
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title:Text(
          'Setup Learning Reminders',
          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppTheme.primaryTeal,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Progress indicator
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: List.generate(3, (index) {
                bool isActive = index <= currentStep;
                bool isCompleted = index < currentStep;

                return Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: isCompleted
                              ? AppTheme.primaryTeal
                              : isActive
                                  ? AppTheme.primaryTeal
                                  : Colors.grey[300],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          isCompleted
                              ? Icons.check
                              : index == 0
                                  ? Icons.calendar_today
                                  : index == 1
                                      ? Icons.access_time
                                      : Icons.code,
                          color: isActive ? Colors.white : Colors.grey[600],
                          size: 16,
                        ),
                      ),
                      if (index < 2)
                        Expanded(
                          child: Container(
                            height: 2,
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            color: index < currentStep
                                ? AppTheme.primaryTeal
                                : Colors.grey[300],
                          ),
                        ),
                    ],
                  ),
                );
              }),
            ),
          ),

          // Step content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: _buildStepContent(),
            ),
          ),

          // Navigation buttons
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                if (currentStep > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          currentStep--;
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppTheme.primaryTeal),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child:Text(
                        'Back',
                        style: GoogleFonts.poppins(color: AppTheme.primaryTeal),
                      ),
                    ),
                  ),
                if (currentStep > 0) const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _canProceed() ? _handleNext : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryTeal,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      currentStep == 2 ? 'Finish Setup' : 'Next',
                      style:  GoogleFonts.poppins(
                          color: Colors.white, fontWeight: FontWeight.w600),
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

  Widget _buildStepContent() {
    switch (currentStep) {
      case 0:
        return _buildDaySelectionStep();
      case 1:
        return _buildTimeSelectionStep();
      case 2:
        return _buildTechPartSelectionStep();
      default:
        return Container();
    }
  }

  Widget _buildDaySelectionStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
       Text(
          'When do you want to learn?',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
       Text(
          'Choose the days when you want to receive learning reminders',
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 32),

        // Quick selection buttons
        Row(
          children: [
            Expanded(
              child: _buildQuickSelectButton(
                'Weekdays',
                ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'],
                Icons.business_center,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildQuickSelectButton(
                'Weekends',
                ['Saturday', 'Sunday'],
                Icons.weekend,
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Individual day selection
       Text(
          'Or select individual days:',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 16),

        Expanded(
          child: GridView.count(
            crossAxisCount: 2,
            childAspectRatio: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: [
              'Monday',
              'Tuesday',
              'Wednesday',
              'Thursday',
              'Friday',
              'Saturday',
              'Sunday'
            ].map((day) => _buildDayCard(day)).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSelectionStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16), // optional padding
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
         Text(
            'What time works best?',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
         Text(
            'Pick a time when you\'re usually free to learn',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 32),

          // Current selected time
          Center(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.lightTeal,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.access_time,
                    size: 48,
                    color: AppTheme.darkTeal,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    selectedTime.format(context),
                    style:  GoogleFonts.poppins(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.darkTeal,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Suggested times
         Text(
            'Suggested Times:',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),

          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildTimeOption('Morning', const TimeOfDay(hour: 8, minute: 0),
                  Icons.wb_sunny),
              _buildTimeOption('Lunch', const TimeOfDay(hour: 12, minute: 0),
                  Icons.lunch_dining),
              _buildTimeOption('Evening', const TimeOfDay(hour: 18, minute: 0),
                  Icons.nightlight_round),
              _buildTimeOption(
                  'Night', const TimeOfDay(hour: 20, minute: 0), Icons.bedtime),
            ],
          ),

          const SizedBox(height: 24),

          // Custom time button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () async {
                final TimeOfDay? picked = await showTimePicker(
                  context: context,
                  initialTime: selectedTime,
                );
                if (picked != null) {
                  setState(() {
                    selectedTime = picked;
                  });
                }
              },
              icon: const Icon(Icons.edit, color: AppTheme.primaryTeal),
              label:Text(
                'Choose Custom Time',
                style: GoogleFonts.poppins(color: AppTheme.primaryTeal),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppTheme.primaryTeal),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTechPartSelectionStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
       Text(
          'What do you want to learn?',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
       Text(
          'Choose your main tech focus area',
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 32),
        Expanded(
          child: GridView.count(
            crossAxisCount: 2,
            childAspectRatio: 1.2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              {
                'name': 'Mobile App Development',
                'icon': Icons.phone_android,
                'color': Colors.blue
              },
              {
                'name': 'Web Development',
                'icon': Icons.web,
                'color': Colors.cyan
              },
              {
                'name': 'Cyber Security',
                'icon': Icons.security,
                'color': Colors.green
              },
              {
                'name': 'Product Design',
                'icon': Icons.design_services,
                'color': Colors.yellow[700]
              },
              {'name': 'AI/ML', 'icon': Icons.memory, 'color': Colors.orange},
              {
                'name': 'Data Science',
                'icon': Icons.bar_chart,
                'color': Colors.purple
              },
              {
                'name': 'Hardware',
                'icon': Icons.memory,
                'color': Colors.indigo
              },
            ].map((tech) => _buildTechCard(tech)).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickSelectButton(
      String title, List<String> days, IconData icon) {
    bool isSelected = _listsEqual(selectedDays, days);
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            selectedDays.clear();
          } else {
            selectedDays = List.from(days);
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryTeal : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.primaryTeal : Colors.grey[300]!,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : AppTheme.primaryTeal,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: GoogleFonts.poppins(
                color: isSelected ? Colors.white : AppTheme.primaryTeal,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayCard(String day) {
    bool isSelected = selectedDays.contains(day);
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            selectedDays.remove(day);
          } else {
            selectedDays.add(day);
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryTeal : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppTheme.primaryTeal : Colors.grey[300]!,
          ),
        ),
        child: Center(
          child: Text(
            day,
            style: GoogleFonts.poppins(
              color: isSelected ? Colors.white : AppTheme.textPrimary,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeOption(String label, TimeOfDay time, IconData icon) {
    bool isSelected =
        time.hour == selectedTime.hour && time.minute == selectedTime.minute;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTime = time;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryTeal : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppTheme.primaryTeal : Colors.grey[300]!,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : AppTheme.primaryTeal,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              '$label\n${time.format(context)}',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: isSelected ? Colors.white : AppTheme.textPrimary,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTechCard(Map<String, dynamic> tech) {
    bool isSelected = selectedTechPart.contains(tech['name']);
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTechPart = '${tech['name']} Development';
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryTeal : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.primaryTeal : Colors.grey[300]!,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              tech['icon'] as IconData,
              color: isSelected ? Colors.white : tech['color'] as Color,
              size: 40,
            ),
            const SizedBox(height: 12),
            Text(
              tech['name'],
              style: GoogleFonts.poppins(
                color: isSelected ? Colors.white : AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 16,
                
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
            ),
          ],
        ),
      ),
    );
  }

  bool _canProceed() {
    switch (currentStep) {
      case 0:
        return selectedDays.isNotEmpty;
      case 1:
        return true; // Time is always selected
      case 2:
        return selectedTechPart.isNotEmpty;
      default:
        return false;
    }
  }

  void _handleNext() {
    if (currentStep < 2) {
      setState(() {
        currentStep++;
      });
    } else {
      

      _completeSetup();
     
    }
  }

  void _completeSetup() {
    
    NotificationPermissionDialog.show(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Learning reminders set up successfully!'),
        backgroundColor: AppTheme.primaryTeal,
        behavior: SnackBarBehavior.floating,
      ),
    );

    

     widget.onContinue();

    Navigator.pushNamed(context, widget.isSoftware? '/learn': '/learn2');
  }

  bool _listsEqual(List<String> list1, List<String> list2) {
    if (list1.length != list2.length) return false;
    for (String item in list1) {
      if (!list2.contains(item)) return false;
    }
    return true;
  }
}
