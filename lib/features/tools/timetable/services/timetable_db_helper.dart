// database/time_table_database_helper.dart
import 'package:aces_uniben/features/notifications/notification_service.dart';
import 'package:aces_uniben/features/tools/timetable/models/timetabole_data_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class TimeTableDatabaseHelper {
  static final TimeTableDatabaseHelper _instance = TimeTableDatabaseHelper._internal();
  static Database? _database;

  factory TimeTableDatabaseHelper() => _instance;

  static final NotificationService _notificationService = NotificationService();

  TimeTableDatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'timetable.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE timetable(
        id TEXT PRIMARY KEY,
        courseTitle TEXT NOT NULL,
        level TEXT NOT NULL,
        session TEXT NOT NULL,
        semester TEXT NOT NULL,
        courseCode TEXT NOT NULL,
        creditUnits INTEGER NOT NULL,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE timetable_days(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        timetable_id TEXT NOT NULL,
        day TEXT NOT NULL,
        startTime TEXT NOT NULL,
        endTime TEXT NOT NULL,
        FOREIGN KEY (timetable_id) REFERENCES timetable (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE timetable_lecturers(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        timetable_id TEXT NOT NULL,
        lecturer TEXT NOT NULL,
        FOREIGN KEY (timetable_id) REFERENCES timetable (id) ON DELETE CASCADE
      )
    ''');
  }

  // Sync data from API to local database
  Future<void> syncTimeTable(TimeTableResponse timeTableResponse) async {
    final db = await database;
    
    // Cancel existing class notifications before syncing new ones
    await _notificationService.cancelAllClassNotifications();
    
    await db.transaction((txn) async {
      // Clear existing data
      await txn.delete('timetable_lecturers');
      await txn.delete('timetable_days');
      await txn.delete('timetable');

      // Insert new data
      for (final entry in timeTableResponse.entries) {
        await txn.insert('timetable', {
          'id': entry.id,
          'courseTitle': entry.courseTitle,
          'level': entry.level,
          'session': entry.session,
          'semester': entry.semester,
          'courseCode': entry.courseCode,
          'creditUnits': entry.creditUnits,
          'createdAt': entry.createdAt.toIso8601String(),
          'updatedAt': entry.updatedAt.toIso8601String(),
        });

        for (final day in entry.days) {
          await txn.insert('timetable_days', {
            'timetable_id': entry.id,
            'day': day.day,
            'startTime': day.startTime,
            'endTime': day.endTime,
          });

          // Schedule notifications for each class
          await _scheduleClassNotification(entry, day);
        }

        for (final lecturer in entry.lecturers) {
          await txn.insert('timetable_lecturers', {
            'timetable_id': entry.id,
            'lecturer': lecturer,
          });
        }
      }
    });

    // Schedule daily morning reminder
    await _notificationService.scheduleDailyMorningReminder();
    
    print('Timetable synced and notifications scheduled successfully');
  }

  // Get timetable by level and semester
  Future<List<TimeTableEntry>> getTimeTableByLevelAndSemester(
    String level, 
    String semester,
  ) async {
    final db = await database;
    
    final List<Map<String, dynamic>> timetableMaps = await db.query(
      'timetable',
      where: 'level = ? AND semester = ?',
      whereArgs: [level, semester],
    );

    final List<TimeTableEntry> entries = [];

    for (final timetableMap in timetableMaps) {
      final String timetableId = timetableMap['id'] as String;

      // Get days for this timetable entry
      final List<Map<String, dynamic>> dayMaps = await db.query(
        'timetable_days',
        where: 'timetable_id = ?',
        whereArgs: [timetableId],
      );

      final List<DaySchedule> days = dayMaps.map((dayMap) => DaySchedule(
        day: dayMap['day'] as String,
        startTime: dayMap['startTime'] as String,
        endTime: dayMap['endTime'] as String,
      )).toList();

      // Get lecturers for this timetable entry
      final List<Map<String, dynamic>> lecturerMaps = await db.query(
        'timetable_lecturers',
        where: 'timetable_id = ?',
        whereArgs: [timetableId],
      );

      final List<String> lecturers = lecturerMaps
          .map((lecturerMap) => lecturerMap['lecturer'] as String)
          .toList();

      entries.add(TimeTableEntry(
        id: timetableMap['id'] as String,
        courseTitle: timetableMap['courseTitle'] as String,
        level: timetableMap['level'] as String,
        session: timetableMap['session'] as String,
        semester: timetableMap['semester'] as String,
        courseCode: timetableMap['courseCode'] as String,
        creditUnits: timetableMap['creditUnits'] as int,
        days: days,
        lecturers: lecturers,
        createdAt: DateTime.parse(timetableMap['createdAt'] as String),
        updatedAt: DateTime.parse(timetableMap['updatedAt'] as String),
      ));
    }

    return entries;
  }

  // Get timetable by level, semester and day
  Future<List<TimeTableEntry>> getTimeTableByLevelSemesterAndDay(
    String level, 
    String semester,
    String day,
  ) async {
    final db = await database;
    
    final List<Map<String, dynamic>> timetableMaps = await db.rawQuery('''
      SELECT DISTINCT t.* 
      FROM timetable t
      JOIN timetable_days td ON t.id = td.timetable_id
      WHERE t.level = ? AND t.semester = ? AND td.day = ?
      ORDER BY td.startTime
    ''', [level, semester, day]);

    final List<TimeTableEntry> entries = [];

    for (final timetableMap in timetableMaps) {
      final String timetableId = timetableMap['id'] as String;

      // Get days for this timetable entry (filtered by the specific day)
      final List<Map<String, dynamic>> dayMaps = await db.query(
        'timetable_days',
        where: 'timetable_id = ? AND day = ?',
        whereArgs: [timetableId, day],
      );

      final List<DaySchedule> days = dayMaps.map((dayMap) => DaySchedule(
        day: dayMap['day'] as String,
        startTime: dayMap['startTime'] as String,
        endTime: dayMap['endTime'] as String,
      )).toList();

      // Get lecturers for this timetable entry
      final List<Map<String, dynamic>> lecturerMaps = await db.query(
        'timetable_lecturers',
        where: 'timetable_id = ?',
        whereArgs: [timetableId],
      );

      final List<String> lecturers = lecturerMaps
          .map((lecturerMap) => lecturerMap['lecturer'] as String)
          .toList();

      entries.add(TimeTableEntry(
        id: timetableMap['id'] as String,
        courseTitle: timetableMap['courseTitle'] as String,
        level: timetableMap['level'] as String,
        session: timetableMap['session'] as String,
        semester: timetableMap['semester'] as String,
        courseCode: timetableMap['courseCode'] as String,
        creditUnits: timetableMap['creditUnits'] as int,
        days: days,
        lecturers: lecturers,
        createdAt: DateTime.parse(timetableMap['createdAt'] as String),
        updatedAt: DateTime.parse(timetableMap['updatedAt'] as String),
      ));
    }

    return entries;
  }

  // Check if data exists for level and semester
  Future<bool> hasDataForLevelAndSemester(String level, String semester) async {
    final db = await database;
    final count = Sqflite.firstIntValue(await db.rawQuery(
      'SELECT COUNT(*) FROM timetable WHERE level = ? AND semester = ?',
      [level, semester],
    ));
    return count != null && count > 0;
  }

  // Close database
  Future<void> close() async {
    final db = await database;
    await db.close();
  }

  // Helper method to schedule class notifications
  Future<void> _scheduleClassNotification(TimeTableEntry entry, DaySchedule day) async {
    try {
      // Parse the start time (assuming format like "08:00")
      final timeParts = day.startTime.split(':');
      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);
      
      // Convert day string to DateTime
      DateTime classTime = _getNextClassDateTime(day.day, hour, minute);
      
      // Generate a unique ID for this class notification
      final notificationId = _generateClassNotificationId(entry.courseCode, day.day, day.startTime);
      
      // Schedule the notification (15 minutes before class)
      final success = await _notificationService.scheduleClassReminder(
        id: notificationId,
        courseTitle: entry.courseTitle,
        courseCode: entry.courseCode,
        classTime: classTime,
        day: day.day,
      );
      
      if (success) {
        print('✅ Scheduled notification for ${entry.courseCode} on ${day.day} at ${day.startTime}');
      } else {
        print('❌ Failed to schedule notification for ${entry.courseCode}');
      }
    } catch (e) {
      print('Error scheduling notification for ${entry.courseCode}: $e');
    }
  }

  // Generate unique notification ID for class reminders
  int _generateClassNotificationId(String courseCode, String day, String startTime) {
    // Create a hash that ensures IDs are between 1000-1999
    final baseId = courseCode.hashCode + day.hashCode + startTime.hashCode;
    return (baseId.abs() % 999) + 1000; // Ensures ID between 1000-1999
  }

  // Helper method to get the next occurrence of a class
  DateTime _getNextClassDateTime(String dayName, int hour, int minute) {
    final now = DateTime.now();
    final today = now.weekday;
    
    // Map day names to weekday numbers (1=Monday, 7=Sunday)
    final dayMap = {
      'monday': 1,
      'tuesday': 2,
      'wednesday': 3,
      'thursday': 4,
      'friday': 5,
      'saturday': 6,
      'sunday': 7,
    };
    
    final targetDay = dayMap[dayName.toLowerCase()] ?? 1;
    int daysToAdd = targetDay - today;
    
    if (daysToAdd < 0) {
      daysToAdd += 7; // Next week
    }
    
    // If it's the same day but time has passed, schedule for next week
    if (daysToAdd == 0 && (now.hour > hour || (now.hour == hour && now.minute >= minute))) {
      daysToAdd = 7;
    }
    
    return DateTime(now.year, now.month, now.day + daysToAdd, hour, minute);
  }

  // Method to reschedule all notifications (call this on app startup)
  Future<void> rescheduleAllNotifications() async {
    print('Rescheduling all timetable notifications...');
    
    final db = await database;
    
    // Cancel all existing class notifications first
    await _notificationService.cancelAllClassNotifications();
    
    // Get all timetable entries
    final List<Map<String, dynamic>> timetableMaps = await db.query('timetable');
    
    int scheduledCount = 0;
    
    for (final timetableMap in timetableMaps) {
      final String timetableId = timetableMap['id'] as String;
      
      // Get days for this timetable entry
      final List<Map<String, dynamic>> dayMaps = await db.query(
        'timetable_days',
        where: 'timetable_id = ?',
        whereArgs: [timetableId],
      );
      
      final entry = TimeTableEntry(
        id: timetableMap['id'] as String,
        courseTitle: timetableMap['courseTitle'] as String,
        level: timetableMap['level'] as String,
        session: timetableMap['session'] as String,
        semester: timetableMap['semester'] as String,
        courseCode: timetableMap['courseCode'] as String,
        creditUnits: timetableMap['creditUnits'] as int,
        days: dayMaps.map((dayMap) => DaySchedule(
          day: dayMap['day'] as String,
          startTime: dayMap['startTime'] as String,
          endTime: dayMap['endTime'] as String,
        )).toList(),
        lecturers: [], // We don't need lecturers for notifications
        createdAt: DateTime.parse(timetableMap['createdAt'] as String),
        updatedAt: DateTime.parse(timetableMap['updatedAt'] as String),
      );
      
      // Schedule notifications for each day
      for (final day in entry.days) {
        await _scheduleClassNotification(entry, day);
        scheduledCount++;
      }
    }
    
    // Reschedule daily morning reminder
    await _notificationService.scheduleDailyMorningReminder();
    
    print('✅ Rescheduled $scheduledCount class notifications and daily reminder');
  }

  // Method to get notification status for debugging
  Future<Map<String, dynamic>> getNotificationStatus() async {
    final pending = await _notificationService.getPendingNotifications();
    final classNotifications = pending.where((n) => n.id >= 1000 && n.id <= 1999).toList();
    final dailyReminder = pending.where((n) => n.id == 999).toList();
    
    return {
      'totalPending': pending.length,
      'classNotifications': classNotifications.length,
      'dailyReminder': dailyReminder.isNotEmpty,
      'classDetails': classNotifications.map((n) => {
        'id': n.id,
        'title': n.title,
        'body': n.body,
      }).toList(),
    };
  }
}