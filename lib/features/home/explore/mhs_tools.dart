import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

class SleepEntry {
  final DateTime date;
  final DateTime bedtime;
  final DateTime wakeTime;
  final int sleepQuality;
  final int hoursSlept;
  final List<String> factors;
  final String? note;

  SleepEntry({
    required this.date,
    required this.bedtime,
    required this.wakeTime,
    required this.sleepQuality,
    required this.hoursSlept,
    required this.factors,
    this.note,
  });

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'bedtime': bedtime.toIso8601String(),
        'wakeTime': wakeTime.toIso8601String(),
        'sleepQuality': sleepQuality,
        'hoursSlept': hoursSlept,
        'factors': factors,
        'note': note,
      };

  factory SleepEntry.fromJson(Map<String, dynamic> json) => SleepEntry(
        date: DateTime.parse(json['date']),
        bedtime: DateTime.parse(json['bedtime']),
        wakeTime: DateTime.parse(json['wakeTime']),
        sleepQuality: json['sleepQuality'],
        hoursSlept: json['hoursSlept'],
        factors: List<String>.from(json['factors']),
        note: json['note'],
      );
}

class SleepAnalytics {
  final double dailyAverage;
  final double weeklyAverage;
  final double monthlyAverage;
  final DateTime lastUpdated;

  SleepAnalytics({
    required this.dailyAverage,
    required this.weeklyAverage,
    required this.monthlyAverage,
    required this.lastUpdated,
  });

  Map<String, dynamic> toJson() => {
        'dailyAverage': dailyAverage,
        'weeklyAverage': weeklyAverage,
        'monthlyAverage': monthlyAverage,
        'lastUpdated': lastUpdated.toIso8601String(),
      };

  factory SleepAnalytics.fromJson(Map<String, dynamic> json) => SleepAnalytics(
        dailyAverage: json['dailyAverage'],
        weeklyAverage: json['weeklyAverage'],
        monthlyAverage: json['monthlyAverage'],
        lastUpdated: DateTime.parse(json['lastUpdated']),
      );
}

// Tracker Provider
class SleepTrackerProvider with ChangeNotifier {
  static const Color primaryBlue = Color(0xFF6DAEDB);
  static const Color primaryPurple = Color(0xFF9370DB);
  
  List<SleepEntry> _sleepEntries = [];
  bool _isLoading = true;
  int _selectedSleepQuality = 0;
  List<String> _selectedFactors = [];
  TimeOfDay _bedtime = TimeOfDay.now();
  TimeOfDay _wakeTime = TimeOfDay.now();
  TextEditingController _noteController = TextEditingController();

  final List<String> predefinedFactors = [
    'Caffeine',
    'Alcohol',
    'Exercise',
    'Stress',
    'Screen Time',
    'Medication',
    'Nap',
    'Heavy Meal',
    'Noise',
    'Light',
    'Temperature',
    'Travel'
  ];

  // Getters
  List<SleepEntry> get sleepEntries => _sleepEntries;
  bool get isLoading => _isLoading;
  int get selectedSleepQuality => _selectedSleepQuality;
  List<String> get selectedFactors => _selectedFactors;
  TimeOfDay get bedtime => _bedtime;
  TimeOfDay get wakeTime => _wakeTime;
  TextEditingController get noteController => _noteController;
  Color get primaryColor => primaryPurple;

  // Constructor
  SleepTrackerProvider() {
    _initialize();
  }

  // Initialize data
  Future<void> _initialize() async {
    await loadSleepEntries();
  }

  // Load sleep entries from SharedPreferences
  Future<void> loadSleepEntries() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? entriesJson = prefs.getString('sleep_entries');
      
      if (entriesJson != null) {
        final List<dynamic> decoded = json.decode(entriesJson);
        _sleepEntries = decoded.map((e) => SleepEntry.fromJson(e)).toList();
        _sleepEntries.sort((a, b) => b.date.compareTo(a.date));
      }
    } catch (e) {
      print('Error loading sleep entries: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // Save sleep entry
  Future<void> saveSleepEntry() async {
    final prefs = await SharedPreferences.getInstance();

    // Calculate hours slept
    final now = DateTime.now();
    final bedtimeDateTime = DateTime(now.year, now.month, now.day, _bedtime.hour, _bedtime.minute);
    final wakeTimeDateTime = DateTime(now.year, now.month, now.day, _wakeTime.hour, _wakeTime.minute);
    
    DateTime adjustedBedtime = bedtimeDateTime;
    DateTime adjustedWakeTime = wakeTimeDateTime;
    
    if (wakeTimeDateTime.isBefore(bedtimeDateTime)) {
      adjustedWakeTime = wakeTimeDateTime.add(const Duration(days: 1));
    }
    
    final hoursSlept = adjustedWakeTime.difference(adjustedBedtime).inHours.toDouble();

    // Create new entry
    final newEntry = SleepEntry(
      date: DateTime.now(),
      bedtime: adjustedBedtime,
      wakeTime: adjustedWakeTime,
      sleepQuality: 5 - _selectedSleepQuality,
      hoursSlept: hoursSlept.round(),
      factors: List.from(_selectedFactors),
      note: _noteController.text.trim(),
    );

    // Add to entries
    _sleepEntries.add(newEntry);
    _sleepEntries.sort((a, b) => b.date.compareTo(a.date));

    // Save to storage
    await prefs.setString(
      'sleep_entries',
      json.encode(_sleepEntries.map((e) => e.toJson()).toList()),
    );

    notifyListeners();
  }

  // Update methods
  void setSleepQuality(int quality) {
    _selectedSleepQuality = quality;
    notifyListeners();
  }

  void toggleFactor(String factor) {
    if (_selectedFactors.contains(factor)) {
      _selectedFactors.remove(factor);
    } else {
      _selectedFactors.add(factor);
    }
    notifyListeners();
  }

  void setBedtime(TimeOfDay time) {
    _bedtime = time;
    notifyListeners();
  }

  void setWakeTime(TimeOfDay time) {
    _wakeTime = time;
    notifyListeners();
  }

  void resetForm() {
    _selectedSleepQuality = 0;
    _selectedFactors.clear();
    _bedtime = TimeOfDay.now();
    _wakeTime = TimeOfDay.now();
    _noteController.clear();
    notifyListeners();
  }

  // Analytics methods
  SleepAnalytics getAnalytics({String period = '7 Days'}) {
    final filteredEntries = _getFilteredEntries(period);
    
    if (filteredEntries.isEmpty) {
      return SleepAnalytics(
        dailyAverage: 0,
        weeklyAverage: 0,
        monthlyAverage: 0,
        lastUpdated: DateTime.now(),
      );
    }

    final double averageQuality = filteredEntries
        .map((e) => e.sleepQuality)
        .reduce((a, b) => a + b) / filteredEntries.length;

    final double averageHours = filteredEntries
        .map((e) => e.hoursSlept)
        .reduce((a, b) => a + b) / filteredEntries.length;

    return SleepAnalytics(
      dailyAverage: averageQuality,
      weeklyAverage: averageHours,
      monthlyAverage: averageQuality,
      lastUpdated: DateTime.now(),
    );
  }

  List<SleepEntry> _getFilteredEntries(String period) {
    final now = DateTime.now();
    DateTime cutoffDate;

    switch (period) {
      case '7 Days':
        cutoffDate = now.subtract(const Duration(days: 7));
        break;
      case '30 Days':
        cutoffDate = now.subtract(const Duration(days: 30));
        break;
      case '3 Months':
        cutoffDate = now.subtract(const Duration(days: 90));
        break;
      case '6 Months':
        cutoffDate = now.subtract(const Duration(days: 180));
        break;
      default:
        cutoffDate = now.subtract(const Duration(days: 7));
    }

    return _sleepEntries
        .where((entry) => entry.date.isAfter(cutoffDate) || entry.date.isAtSameMomentAs(cutoffDate))
        .toList();
  }

  // Utility methods
  String getSleepQualityEmoji(int sleepQuality) {
    switch (sleepQuality) {
      case 1: return '😫';
      case 2: return '😣';
      case 3: return '😐';
      case 4: return '🙂';
      case 5: return '😴';
      default: return '😐';
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }
}

// Sleep Tracker Page
class SleepTrackerPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SleepTrackerProvider(),
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF9370DB)),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Sleep Tracker',
            style: GoogleFonts.poppins(
              color: Colors.black87,
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        body: Consumer<SleepTrackerProvider>(
          builder: (context, tracker, child) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormat('EEEE, MMMM d').format(DateTime.now()),
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'How was your sleep?',
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildSleepQualitySelector(tracker),
                        const SizedBox(height: 32),
                        Text(
                          'Sleep Timing',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildTimeSelectors(context, tracker),
                        const SizedBox(height: 32),
                        Text(
                          'What affected your sleep?',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildFactorChips(tracker),
                        const SizedBox(height: 32),
                        Text(
                          'Add a note',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildNoteInput(tracker),
                        const SizedBox(height: 32),
                        _buildSaveButton(context, tracker),
                      ],
                    ),
                  ),
                  SleepAnalysisWidget(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSleepQualitySelector(SleepTrackerProvider tracker) {
    final List<Map<String, dynamic>> sleepQualities = [
      {'emoji': '😴', 'label': 'Excellent'},
      {'emoji': '🙂', 'label': 'Good'},
      {'emoji': '😐', 'label': 'Average'},
      {'emoji': '😣', 'label': 'Poor'},
      {'emoji': '😫', 'label': 'Terrible'},
    ];

    return Container(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: sleepQualities.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => tracker.setSleepQuality(index),
            child: Container(
              width: 80,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: tracker.selectedSleepQuality == index
                    ? tracker.primaryColor.withOpacity(0.1)
                    : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: tracker.selectedSleepQuality == index
                      ? tracker.primaryColor
                      : Colors.grey.withOpacity(0.3),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    sleepQualities[index]['emoji'],
                    style:   GoogleFonts.poppins(fontSize: 32),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    sleepQualities[index]['label'],
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: tracker.selectedSleepQuality == index 
                          ? tracker.primaryColor 
                          : Colors.black54,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimeSelectors(BuildContext context, SleepTrackerProvider tracker) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bedtime',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => _selectTime(context, tracker, true),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.access_time, size: 20, color: Color(0xFF9370DB)),
                      const SizedBox(width: 8),
                      Text(
                        tracker.bedtime.format(context),
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Wake Time',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => _selectTime(context, tracker, false),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.access_time, size: 20, color: Color(0xFF9370DB)),
                      const SizedBox(width: 8),
                      Text(
                        tracker.wakeTime.format(context),
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _selectTime(BuildContext context, SleepTrackerProvider tracker, bool isBedtime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isBedtime ? tracker.bedtime : tracker.wakeTime,
    );
    
    if (picked != null) {
      if (isBedtime) {
        tracker.setBedtime(picked);
      } else {
        tracker.setWakeTime(picked);
      }
    }
  }

  Widget _buildFactorChips(SleepTrackerProvider tracker) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: tracker.predefinedFactors.map((factor) {
        final isSelected = tracker.selectedFactors.contains(factor);
        return FilterChip(
          label: Text(
            factor,
            style: GoogleFonts.poppins(
              color: isSelected ? Colors.white : Colors.black87,
            ),
          ),
          selected: isSelected,
          onSelected: (selected) => tracker.toggleFactor(factor),
          selectedColor: tracker.primaryColor,
          backgroundColor: Colors.white,
          checkmarkColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: isSelected ? tracker.primaryColor : Colors.grey.withOpacity(0.3),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildNoteInput(SleepTrackerProvider tracker) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
      ),
      child: TextField(
        controller: tracker.noteController,
        maxLines: 4,
        style: GoogleFonts.poppins(
          fontSize: 16,
          color: Colors.black87,
        ),
        decoration: InputDecoration(
          hintText: 'Write about your sleep...',
          hintStyle: GoogleFonts.poppins(
            color: Colors.black38,
          ),
          contentPadding: const EdgeInsets.all(16),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildSaveButton(BuildContext context, SleepTrackerProvider tracker) {
    return Container(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () async {
          await tracker.saveSleepEntry();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Sleep saved successfully!',
                style: GoogleFonts.poppins(),
              ),
              backgroundColor: tracker.primaryColor,
            ),
          );
          tracker.resetForm();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: tracker.primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: Text(
          'Save Entry',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

// SleepAnalysis Widget
class SleepAnalysisWidget extends StatefulWidget {
  @override
  _SleepAnalysisWidgetState createState() => _SleepAnalysisWidgetState();
}

class _SleepAnalysisWidgetState extends State<SleepAnalysisWidget> {
  String selectedPeriod = '7 Days';
  List<String> timePeriods = ['7 Days', '30 Days', '3 Months', '6 Months'];

  @override
  Widget build(BuildContext context) {
    return Consumer<SleepTrackerProvider>(
      builder: (context, tracker, child) {
        if (tracker.isLoading) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF9370DB)));
        }

        if (tracker.sleepEntries.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: Text(
                'No sleep entries yet. Start tracking your sleep!',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        final filteredEntries = _getFilteredEntries(tracker);
        final analytics = tracker.getAnalytics(period: selectedPeriod);

        // Calculate average sleep quality
        double averageQuality = filteredEntries.isEmpty
            ? 0
            : filteredEntries.map((e) => e.sleepQuality).reduce((a, b) => a + b) /
                filteredEntries.length;

        // Calculate average hours slept
        double averageHours = filteredEntries.isEmpty
            ? 0
            : filteredEntries.map((e) => e.hoursSlept).reduce((a, b) => a + b) /
                filteredEntries.length;

        // Get most common factors
        Map<String, int> factorCount = {};
        for (var entry in filteredEntries) {
          for (var factor in entry.factors) {
            factorCount[factor] = (factorCount[factor] ?? 0) + 1;
          }
        }

        List<MapEntry<String, int>> sortedFactors = factorCount.entries
            .toList()
          ..sort((a, b) => b.value.compareTo(a.value));

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Sleep Analysis',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Time period selector
            Container(
              height: 40,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: timePeriods.length,
                itemBuilder: (context, index) {
                  final period = timePeriods[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(
                        period,
                        style: GoogleFonts.poppins(
                          color: selectedPeriod == period
                              ? Colors.white
                              : Colors.black87,
                        ),
                      ),
                      selected: selectedPeriod == period,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() => selectedPeriod = period);
                        }
                      },
                      selectedColor: tracker.primaryColor,
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: selectedPeriod == period
                              ? tracker.primaryColor
                              : Colors.grey.withOpacity(0.3),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            ModernizedSleepStats(averageQuality: averageQuality, averageHours: averageHours, tracker: tracker),
            const SizedBox(height: 24),
            // Top factors
            if (sortedFactors.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Common Factors',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                height: 40,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: sortedFactors.length.clamp(0, 5),
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Chip(
                        label: Text(
                          '${sortedFactors[index].key} (${sortedFactors[index].value})',
                          style: GoogleFonts.poppins(color: Colors.black87),
                        ),
                        backgroundColor: Colors.grey[100],
                      ),
                    );
                  },
                ),
              ),
            ],
            const SizedBox(height: 24),
            // Recent entries
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Recent Entries',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 12),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredEntries.length.clamp(0, 5),
              itemBuilder: (context, index) {
                final entry = filteredEntries[index];
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.withOpacity(0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            tracker.getSleepQualityEmoji(entry.sleepQuality),
                            style:   GoogleFonts.poppins(fontSize: 24),
                          ),
                          Text(
                            DateFormat('MMM d, y').format(entry.date),
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            '${entry.hoursSlept} hours',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: tracker.primaryColor,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            '${DateFormat('h:mm a').format(entry.bedtime)} - ${DateFormat('h:mm a').format(entry.wakeTime)}',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                      if (entry.factors.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: entry.factors.map((factor) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: tracker.primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                factor,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: tracker.primaryColor,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                      if (entry.note?.isNotEmpty ?? false) ...[
                        const SizedBox(height: 8),
                        Text(
                          entry.note!,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        );
      },
    );
  }

  List<SleepEntry> _getFilteredEntries(SleepTrackerProvider tracker) {
    final now = DateTime.now();
    DateTime cutoffDate;

    switch (selectedPeriod) {
      case '7 Days':
        cutoffDate = now.subtract(const Duration(days: 7));
        break;
      case '30 Days':
        cutoffDate = now.subtract(const Duration(days: 30));
        break;
      case '3 Months':
        cutoffDate = now.subtract(const Duration(days: 90));
        break;
      case '6 Months':
        cutoffDate = now.subtract(const Duration(days: 180));
        break;
      default:
        cutoffDate = now.subtract(const Duration(days: 7));
    }

    return tracker.sleepEntries
        .where((entry) =>
            entry.date.isAfter(cutoffDate) ||
            entry.date.isAtSameMomentAs(cutoffDate))
        .toList();
  }
}




// Model class for mood entries
class MoodEntry {
  final DateTime date;
  final int moodLevel;
  final List<String> activities;
  final String? note;

  MoodEntry({
    required this.date,
    required this.moodLevel,
    required this.activities,
    this.note,
  });

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'moodLevel': moodLevel,
        'activities': activities,
        'note': note,
      };

  factory MoodEntry.fromJson(Map<String, dynamic> json) => MoodEntry(
        date: DateTime.parse(json['date']),
        moodLevel: json['moodLevel'],
        activities: List<String>.from(json['activities']),
        note: json['note'],
      );
}

class MoodAnalytics {
  final double dailyAverage;
  final double weeklyAverage;
  final double monthlyAverage;
  final DateTime lastUpdated;

  MoodAnalytics({
    required this.dailyAverage,
    required this.weeklyAverage,
    required this.monthlyAverage,
    required this.lastUpdated,
  });

  Map<String, dynamic> toJson() => {
        'dailyAverage': dailyAverage,
        'weeklyAverage': weeklyAverage,
        'monthlyAverage': monthlyAverage,
        'lastUpdated': lastUpdated.toIso8601String(),
      };

  factory MoodAnalytics.fromJson(Map<String, dynamic> json) => MoodAnalytics(
        dailyAverage: json['dailyAverage'],
        weeklyAverage: json['weeklyAverage'],
        monthlyAverage: json['monthlyAverage'],
        lastUpdated: DateTime.parse(json['lastUpdated']),
      );
}

class MoodTrackerProvider with ChangeNotifier {
  static const Color primaryBlue = Color(0xFF6DAEDB);
  
  List<MoodEntry> _moodEntries = [];
  bool _isLoading = true;
  int _selectedMood = 0;
  List<String> _selectedActivities = [];
  TextEditingController _noteController = TextEditingController();

  final List<String> predefinedActivities = [
    'Exercise',
    'Work',
    'Family',
    'Friends',
    'Sleep',
    'Study',
    'Meditation',
    'Reading',
    'Music',
    'Nature',
    'Shopping',
    'Gaming'
  ];

  // Getters
  List<MoodEntry> get moodEntries => _moodEntries;
  bool get isLoading => _isLoading;
  int get selectedMood => _selectedMood;
  List<String> get selectedActivities => _selectedActivities;
  TextEditingController get noteController => _noteController;
  Color get primaryColor => primaryBlue;

  // Constructor
  MoodTrackerProvider() {
    _initialize();
  }

  // Initialize data
  Future<void> _initialize() async {
    await loadMoodEntries();
  }

  // Load mood entries from SharedPreferences
  Future<void> loadMoodEntries() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? entriesJson = prefs.getString('mood_entries');
      
      if (entriesJson != null) {
        final List<dynamic> decoded = json.decode(entriesJson);
        _moodEntries = decoded.map((e) => MoodEntry.fromJson(e)).toList();
        _moodEntries.sort((a, b) => b.date.compareTo(a.date));
      }
    } catch (e) {
      print('Error loading mood entries: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // Save mood entry
  Future<void> saveMoodEntry() async {
    final prefs = await SharedPreferences.getInstance();

    // Create new entry
    final newEntry = MoodEntry(
      date: DateTime.now(),
      moodLevel: 5 - _selectedMood,
      activities: List.from(_selectedActivities),
      note: _noteController.text.trim(),
    );

    // Add to entries
    _moodEntries.add(newEntry);
    _moodEntries.sort((a, b) => b.date.compareTo(a.date));

    // Save to storage
    await prefs.setString(
      'mood_entries',
      json.encode(_moodEntries.map((e) => e.toJson()).toList()),
    );

    notifyListeners();
  }

  // Update methods
  void setMood(int mood) {
    _selectedMood = mood;
    notifyListeners();
  }

  void toggleActivity(String activity) {
    if (_selectedActivities.contains(activity)) {
      _selectedActivities.remove(activity);
    } else {
      _selectedActivities.add(activity);
    }
    notifyListeners();
  }

  void resetForm() {
    _selectedMood = 0;
    _selectedActivities.clear();
    _noteController.clear();
    notifyListeners();
  }

  // Analytics methods
  MoodAnalytics getAnalytics({String period = '7 Days'}) {
    final filteredEntries = _getFilteredEntries(period);
    
    if (filteredEntries.isEmpty) {
      return MoodAnalytics(
        dailyAverage: 0,
        weeklyAverage: 0,
        monthlyAverage: 0,
        lastUpdated: DateTime.now(),
      );
    }

    final double averageMood = filteredEntries
        .map((e) => e.moodLevel)
        .reduce((a, b) => a + b) / filteredEntries.length;

    return MoodAnalytics(
      dailyAverage: averageMood,
      weeklyAverage: averageMood,
      monthlyAverage: averageMood,
      lastUpdated: DateTime.now(),
    );
  }

  List<MoodEntry> _getFilteredEntries(String period) {
    final now = DateTime.now();
    DateTime cutoffDate;

    switch (period) {
      case '7 Days':
        cutoffDate = now.subtract(const Duration(days: 7));
        break;
      case '30 Days':
        cutoffDate = now.subtract(const Duration(days: 30));
        break;
      case '3 Months':
        cutoffDate = now.subtract(const Duration(days: 90));
        break;
      case '6 Months':
        cutoffDate = now.subtract(const Duration(days: 180));
        break;
      default:
        cutoffDate = now.subtract(const Duration(days: 7));
    }

    return _moodEntries
        .where((entry) => entry.date.isAfter(cutoffDate) || entry.date.isAtSameMomentAs(cutoffDate))
        .toList();
  }

  // Utility methods
  String getMoodEmoji(int moodLevel) {
    switch (moodLevel) {
      case 1: return '😢';
      case 2: return '☹️';
      case 3: return '😐';
      case 4: return '🙂';
      case 5: return '😄';
      default: return '😐';
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }
}

// Mood Tracker Page
class MoodTrackerPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MoodTrackerProvider(),
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF6DAEDB)),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Mood Tracker',
            style: GoogleFonts.poppins(
              color: Colors.black87,
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        body: Consumer<MoodTrackerProvider>(
          builder: (context, tracker, child) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormat('EEEE, MMMM d').format(DateTime.now()),
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'How are you feeling?',
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildMoodSelector(tracker),
                        const SizedBox(height: 32),
                        Text(
                          'What affected your mood today?',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildActivityChips(tracker),
                        const SizedBox(height: 32),
                        Text(
                          'Add a note',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildNoteInput(tracker),
                        const SizedBox(height: 32),
                        _buildSaveButton(context, tracker),
                      ],
                    ),
                  ),
                  MoodAnalysisWidget(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMoodSelector(MoodTrackerProvider tracker) {
    final List<Map<String, dynamic>> moods = [
      {'emoji': '😄', 'label': 'Very Happy'},
      {'emoji': '🙂', 'label': 'Happy'},
      {'emoji': '😐', 'label': 'Neutral'},
      {'emoji': '☹️', 'label': 'Sad'},
      {'emoji': '😢', 'label': 'Very Sad'},
    ];

    return Container(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: moods.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => tracker.setMood(index),
            child: Container(
              width: 80,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: tracker.selectedMood == index
                    ? tracker.primaryColor.withOpacity(0.1)
                    : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: tracker.selectedMood == index
                      ? tracker.primaryColor
                      : Colors.grey.withOpacity(0.3),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    moods[index]['emoji'],
                    style:   GoogleFonts.poppins(fontSize: 32),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    moods[index]['label'],
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: tracker.selectedMood == index 
                          ? tracker.primaryColor 
                          : Colors.black54,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildActivityChips(MoodTrackerProvider tracker) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: tracker.predefinedActivities.map((activity) {
        final isSelected = tracker.selectedActivities.contains(activity);
        return FilterChip(
          label: Text(
            activity,
            style: GoogleFonts.poppins(
              color: isSelected ? Colors.white : Colors.black87,
            ),
          ),
          selected: isSelected,
          onSelected: (selected) => tracker.toggleActivity(activity),
          selectedColor: tracker.primaryColor,
          backgroundColor: Colors.white,
          checkmarkColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: isSelected ? tracker.primaryColor : Colors.grey.withOpacity(0.3),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildNoteInput(MoodTrackerProvider tracker) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
      ),
      child: TextField(
        controller: tracker.noteController,
        maxLines: 4,
        style: GoogleFonts.poppins(
          fontSize: 16,
          color: Colors.black87,
        ),
        decoration: InputDecoration(
          hintText: 'Write about your day...',
          hintStyle: GoogleFonts.poppins(
            color: Colors.black38,
          ),
          contentPadding: const EdgeInsets.all(16),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildSaveButton(BuildContext context, MoodTrackerProvider tracker) {
    return Container(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () async {
          await tracker.saveMoodEntry();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Mood saved successfully!',
                style: GoogleFonts.poppins(),
              ),
              backgroundColor: tracker.primaryColor,
            ),
          );
          tracker.resetForm();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: tracker.primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: Text(
          'Save Entry',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

// MoodAnalysis Widget
class MoodAnalysisWidget extends StatefulWidget {
  @override
  _MoodAnalysisWidgetState createState() => _MoodAnalysisWidgetState();
}

class _MoodAnalysisWidgetState extends State<MoodAnalysisWidget> {
  String selectedPeriod = '7 Days';
  List<String> timePeriods = ['7 Days', '30 Days', '3 Months', '6 Months'];

  @override
  Widget build(BuildContext context) {
    return Consumer<MoodTrackerProvider>(
      builder: (context, tracker, child) {
        if (tracker.isLoading) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF6DAEDB)));
        }

        if (tracker.moodEntries.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: Text(
                'No mood entries yet. Start tracking your mood!',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        final filteredEntries = _getFilteredEntries(tracker);
        final analytics = tracker.getAnalytics(period: selectedPeriod);

        // Calculate average mood
        double averageMood = filteredEntries.isEmpty
            ? 0
            : filteredEntries.map((e) => e.moodLevel).reduce((a, b) => a + b) /
                filteredEntries.length;

        // Get most common activities
        Map<String, int> activityCount = {};
        for (var entry in filteredEntries) {
          for (var activity in entry.activities) {
            activityCount[activity] = (activityCount[activity] ?? 0) + 1;
          }
        }

        List<MapEntry<String, int>> sortedActivities = activityCount.entries
            .toList()
          ..sort((a, b) => b.value.compareTo(a.value));

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Mood Analysis',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Time period selector
            Container(
              height: 40,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: timePeriods.length,
                itemBuilder: (context, index) {
                  final period = timePeriods[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(
                        period,
                        style: GoogleFonts.poppins(
                          color: selectedPeriod == period
                              ? Colors.white
                              : Colors.black87,
                        ),
                      ),
                      selected: selectedPeriod == period,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() => selectedPeriod = period);
                        }
                      },
                      selectedColor: tracker.primaryColor,
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: selectedPeriod == period
                              ? tracker.primaryColor
                              : Colors.grey.withOpacity(0.3),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            // Mood statistics
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Average Mood',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        tracker.getMoodEmoji(averageMood.round()),
                        style:   GoogleFonts.poppins(fontSize: 32),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        averageMood.toStringAsFixed(1),
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: tracker.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Top activities
            if (sortedActivities.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Top Activities',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                height: 40,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: sortedActivities.length.clamp(0, 5),
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Chip(
                        label: Text(
                          '${sortedActivities[index].key} (${sortedActivities[index].value})',
                          style: GoogleFonts.poppins(color: Colors.black87),
                        ),
                        backgroundColor: Colors.grey[100],
                      ),
                    );
                  },
                ),
              ),
            ],
            const SizedBox(height: 24),
            // Recent entries
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Recent Entries',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 12),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredEntries.length.clamp(0, 5),
              itemBuilder: (context, index) {
                final entry = filteredEntries[index];
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.withOpacity(0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            tracker.getMoodEmoji(entry.moodLevel),
                            style:   GoogleFonts.poppins(fontSize: 24),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            DateFormat('MMM d, y').format(entry.date),
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      if (entry.activities.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: entry.activities.map((activity) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: tracker.primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                activity,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: tracker.primaryColor,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                      if (entry.note?.isNotEmpty ?? false) ...[
                        const SizedBox(height: 8),
                        Text(
                          entry.note!,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        );
      },
    );
  }

  List<MoodEntry> _getFilteredEntries(MoodTrackerProvider tracker) {
    final now = DateTime.now();
    DateTime cutoffDate;

    switch (selectedPeriod) {
      case '7 Days':
        cutoffDate = now.subtract(const Duration(days: 7));
        break;
      case '30 Days':
        cutoffDate = now.subtract(const Duration(days: 30));
        break;
      case '3 Months':
        cutoffDate = now.subtract(const Duration(days: 90));
        break;
      case '6 Months':
        cutoffDate = now.subtract(const Duration(days: 180));
        break;
      default:
        cutoffDate = now.subtract(const Duration(days: 7));
    }

    return tracker.moodEntries
        .where((entry) =>
            entry.date.isAfter(cutoffDate) ||
            entry.date.isAtSameMomentAs(cutoffDate))
        .toList();
  }
}






class ModernizedSleepStats extends StatefulWidget {
  final double averageQuality;
  final double averageHours;
  final dynamic tracker; // Your tracker object

  const ModernizedSleepStats({
    Key? key,
    required this.averageQuality,
    required this.averageHours,
    required this.tracker,
  }) : super(key: key);

  @override
  _ModernizedSleepStatsState createState() => _ModernizedSleepStatsState();
}

class _ModernizedSleepStatsState extends State<ModernizedSleepStats>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    _slideController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _scaleController.forward();
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Colors.grey.shade50,
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
              spreadRadius: 0,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with subtle animation
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 1000),
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: widget.tracker.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.insights,
                          color: widget.tracker.primaryColor,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Sleep Overview',
                        style: GoogleFonts. poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            
            // Modern stats cards
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    title: 'Sleep Quality',
                    value: widget.averageQuality.toStringAsFixed(1),
                    emoji: widget.tracker.getSleepQualityEmoji(widget.averageQuality.round()),
                    color: _getQualityColor(widget.averageQuality),
                    delay: 0,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    title: 'Hours Slept',
                    value: widget.averageHours.toStringAsFixed(1),
                    icon: Icons.access_time_rounded,
                    color: const Color(0xFF9370DB),
                    delay: 200,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Progress indicators
            _buildProgressIndicators(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    String? emoji,
    IconData? icon,
    required Color color,
    required int delay,
  }) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 800 + delay),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, animValue, child) {
        return Transform.scale(
          scale: animValue,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: color.withOpacity(0.1),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.1),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon/Emoji container
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: emoji != null
                        ? Text(
                            emoji,
                            style:   GoogleFonts.poppins(fontSize: 24),
                          )
                        : Icon(
                            icon,
                            color: color,
                            size: 24,
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Title
                Text(
                  title,
                  style: GoogleFonts. poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade600,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 4),
                
                // Value with animated counter
                TweenAnimationBuilder<double>(
                  duration: Duration(milliseconds: 1200 + delay),
                  tween: Tween(begin: 0.0, end: double.parse(value)),
                  builder: (context, animatedValue, child) {
                    return Text(
                      animatedValue.toStringAsFixed(1),
                      style: GoogleFonts. poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: color,
                        height: 1.2,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProgressIndicators() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 1500),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Weekly Progress',
                    style: GoogleFonts. poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getQualityColor(widget.averageQuality).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getQualityLabel(widget.averageQuality),
                      style: GoogleFonts. poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _getQualityColor(widget.averageQuality),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Animated progress bars
              Row(
                children: List.generate(7, (index) {
                  return Expanded(
                    child: Container(
                      margin: EdgeInsets.only(right: index < 6 ? 4 : 0),
                      child: TweenAnimationBuilder<double>(
                        duration: Duration(milliseconds: 800 + (index * 100)),
                        tween: Tween(begin: 0.0, end: 1.0),
                        builder: (context, barValue, child) {
                          final height = 6.0 + (index * 2.0 % 8.0); // Varied heights
                          return Container(
                            height: height * barValue,
                            decoration: BoxDecoration(
                              color: widget.tracker.primaryColor.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getQualityColor(double quality) {
    if (quality >= 4.0) return Colors.green.shade500;
    if (quality >= 3.0) return Colors.orange.shade500;
    return Colors.red.shade400;
  }

  String _getQualityLabel(double quality) {
    if (quality >= 4.0) return 'Excellent';
    if (quality >= 3.0) return 'Good';
    if (quality >= 2.0) return 'Fair';
    return 'Poor';
  }
}