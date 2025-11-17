// providers/time_table_provider.dart
import 'package:aces_uniben/features/tools/timetable/models/timetabole_data_model.dart';
import 'package:aces_uniben/features/tools/timetable/services/timetable_api_services.dart';
import 'package:aces_uniben/features/tools/timetable/services/timetable_db_helper.dart';
import 'package:aces_uniben/services/background_initializers.dart';
import 'package:flutter/foundation.dart';

class TimeTableProvider with ChangeNotifier {
  
  final TimeTableApiService _apiService = TimeTableApiService();
  final TimeTableDatabaseHelper _databaseHelper = TimeTableDatabaseHelper();

  List<TimeTableEntry> _timeTableEntries = [];
  bool _isLoading = false;
  String? _error;
  bool _isInitialized = false;

  TimeTableProvider();

  // Initialize the provider with dependencies
  // In your TimeTableProvider
Future<void> initialize() async {
  if (_isInitialized) return;
  
  _isLoading = true;
  notifyListeners();

  try {
    await _databaseHelper.database;
    
    // Check if background service has already loaded data
    if (!BackgroundInitService.isInitialized) {
      // If not, check if we have any data at all
      final hasData = await _hasAnyData();
      
      if (!hasData) {
        // Show a gentle message that data is loading in background
        _error = 'Timetable data is loading in background...';
        notifyListeners();
      }
    }
    
    _isInitialized = true;
    _isLoading = false;
    notifyListeners();
  } catch (e) {
    _isLoading = false;
    _error = 'Failed to initialize: $e';
    notifyListeners();
    rethrow;
  }
}

Future<bool> _hasAnyData() async {
  try {
    final db = await _databaseHelper.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM timetable LIMIT 1'
    );
    return (result.first['count'] as int) > 0;
  } catch (e) {
    return false;
  }
}  List<TimeTableEntry> get timeTableEntries => _timeTableEntries;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isInitialized => _isInitialized;

  // Helper function to convert time string to minutes for sorting
  int _timeToMinutes(String time) {
    final parts = time.split(':');
    if (parts.length != 2) return 0;
    
    final hours = int.tryParse(parts[0]) ?? 0;
    final minutes = int.tryParse(parts[1]) ?? 0;
    
    return hours * 60 + minutes;
  }

  // Sort timetable entries by their earliest start time for the day
  List<TimeTableEntry> _sortEntriesByStartTime(List<TimeTableEntry> entries, String? targetDay) {
    return entries..sort((a, b) {
      // Get the start times for the target day (or first day if no target)
      final aStartTime = targetDay != null 
          ? a.days.firstWhere((day) => day.day == targetDay, orElse: () => DaySchedule(day: '', startTime: '23:59', endTime: '')).startTime
          : a.days.map((day) => _timeToMinutes(day.startTime)).reduce((a, b) => a < b ? a : b);
      
      final bStartTime = targetDay != null 
          ? b.days.firstWhere((day) => day.day == targetDay, orElse: () => DaySchedule(day: '', startTime: '23:59', endTime: '')).startTime
          : b.days.map((day) => _timeToMinutes(day.startTime)).reduce((a, b) => a < b ? a : b);
      
      // Convert to minutes for comparison
      final aMinutes = targetDay != null ? _timeToMinutes(aStartTime.toString()) : _timeToMinutes(aStartTime as String);
      final bMinutes = targetDay != null ? _timeToMinutes(bStartTime.toString()) : _timeToMinutes(bStartTime as String);
      
      return aMinutes.compareTo(bMinutes);
    });
  }

  // Fetch timetable from API and sync to local database
  Future<void> fetchAndSyncTimeTable({String? s, String? l}) async {
    if (!_isInitialized) await initialize();
    
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final timeTableResponse = await _apiService.fetchTimeTable(level: l, semester: s);
      await _databaseHelper.syncTimeTable(timeTableResponse);
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Network Error, You seems not to be connected to an Internet Connection, Give it another short';
      notifyListeners();
      rethrow;
    }
  }

  // Get timetable by level and semester from local database - sorted by start time
  Future<void> getTimeTableByLevelAndSemester(
  String level, 
  String semester,
) async {
  if (!_isInitialized) await initialize();
  
  _isLoading = true;
  _error = null;
  notifyListeners();

  try {
    final entries = await _databaseHelper.getTimeTableByLevelAndSemester(
      level, 
      semester,
    );
    
    // Add debug logging for release mode
    if (kReleaseMode) {
      print('Fetched ${entries.length} entries from database');
      if (entries.isEmpty) {
        print('No entries found for level: $level, semester: $semester');
        
      }
    }
    
    _timeTableEntries = _sortEntriesByStartTime(entries, null);
    _isLoading = false;
    notifyListeners();
  } catch (e) {
    _isLoading = false;
    _error = 'Failed to fetch timetable: $e';
    
    if (kReleaseMode) {
      print('Error fetching timetable: $e');
      print('Stack trace: ${StackTrace.current}');
    }
    
    notifyListeners();
    rethrow;
  }
}  // Get entries for a specific day of the week - sorted by start time
  Future<List<TimeTableEntry>> getEntriesForDay(
    String level,
    String semester,
    String dayOfWeek,
  ) async {
    if (!_isInitialized) await initialize();
    
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // First get all entries for the level and semester
      final allEntries = await _databaseHelper.getTimeTableByLevelAndSemester(
        level, 
        semester,
      );

      // Filter entries that have classes on the specified day
      final dayEntries = allEntries.where((entry) {
        return entry.days.any((daySchedule) => 
          daySchedule.day.toLowerCase() == dayOfWeek.toLowerCase());
      }).toList();

      // Sort entries by start time for the specific day
      _timeTableEntries = _sortEntriesByStartTime(dayEntries, dayOfWeek);
      _isLoading = false;
      notifyListeners();
      
      return _timeTableEntries;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Get entries for today - sorted by start time
  Future<List<TimeTableEntry>> getEntriesForToday(
    String level,
    String semester,
  ) async {
    final today = DateTime.now();
    final dayOfWeek = _getDayName(today.weekday);
    return await getEntriesForDay(level, semester, dayOfWeek);
  }

  // Helper method to convert weekday number to day name
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

  // Get all unique days that have classes for a level and semester
  Future<List<String>> getAvailableDays(
    String level,
    String semester,
  ) async {
    if (!_isInitialized) await initialize();

    try {
      final allEntries = await _databaseHelper.getTimeTableByLevelAndSemester(
        level, 
        semester,
      );

      // Get all unique days from all entries
      final allDays = allEntries.expand((entry) => 
        entry.days.map((day) => day.day)
      ).toSet().toList();

      // Sort days in chronological order
      final dayOrder = {
        'Monday': 1,
        'Tuesday': 2,
        'Wednesday': 3,
        'Thursday': 4,
        'Friday': 5,
        'Saturday': 6,
        'Sunday': 7,
      };

      allDays.sort((a, b) => (dayOrder[a] ?? 8).compareTo(dayOrder[b] ?? 8));
      
      return allDays;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Check if local data exists for level and semester
  Future<bool> hasLocalData(String level, String semester) async {
    if (!_isInitialized) await initialize();
    return await _databaseHelper.hasDataForLevelAndSemester(level, semester);
  }

  // Clear current entries
  void clearEntries() {
    _timeTableEntries = [];
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Dispose method to clean up resources
  @override
  void dispose() {
    _databaseHelper.close();
    super.dispose();
  }
}