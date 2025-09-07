// database/time_table_database_helper.dart
import 'package:aces_uniben/features/tools/timetable/models/timetabole_data_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class TimeTableDatabaseHelper {
  static final TimeTableDatabaseHelper _instance = TimeTableDatabaseHelper._internal();
  static Database? _database;

  factory TimeTableDatabaseHelper() => _instance;

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
        }

        for (final lecturer in entry.lecturers) {
          await txn.insert('timetable_lecturers', {
            'timetable_id': entry.id,
            'lecturer': lecturer,
          });
        }
      }
    });
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

  // Add this method to your TimeTableDatabaseHelper class
Future<List<TimeTableEntry>> getTimeTableByLevelSemesterAndDay(
  String level, 
  String semester,
  String day,
) async {
  final db = await database;
  
  // Use a JOIN to efficiently filter by day
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
}