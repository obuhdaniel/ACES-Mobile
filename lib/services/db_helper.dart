import 'package:aces_uniben/features/auth/models/student_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static Database? _db;
  static const int _version = 1; // Add version constant

  static Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'auth.db');

    return openDatabase(
      path,
      version: _version,
      onCreate: _createTables, // Use separate method
      onUpgrade: _upgradeDatabase, // Add upgrade handler
    );
  }

  static Future<void> _createTables(Database db, int version) async {
    // Create profile table
    await db.execute('''
      CREATE TABLE profile(
        id TEXT PRIMARY KEY,
        name TEXT,
        email TEXT,
        matNo TEXT,
        uniEmail TEXT,
        level TEXT,
        token TEXT,
        createdAt INTEGER DEFAULT (strftime('%s', 'now'))
      )
    ''');
    
    print('Profile table created successfully');
  }

  static Future<void> _upgradeDatabase(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 1) {
      await _createTables(db, newVersion);
    }
    // Add more version upgrades here if needed in the future
  }

  static Future<Database> get db async {
    if (_db != null) return _db!;
    
    _db = await _initDb();
    
    // Verify table exists, if not create it
    try {
      await _db!.rawQuery('SELECT COUNT(*) FROM profile');
    } catch (e) {
      print('Profile table missing, creating now...');
      await _createTables(_db!, _version);
    }
    
    return _db!;
  }

  static Future<void> saveProfile(AcesStudent user, {String? token}) async {
    final dbClient = await db; // This ensures table exists
    
    final profileData = {
      ...user.toMap(),
      if (token != null) 'token': token,
      'createdAt': DateTime.now().millisecondsSinceEpoch,
    };
    
    await dbClient.insert(
      'profile',
      profileData,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<AcesStudent?> getProfile() async {
    try {
      final dbClient = await db;
      final result = await dbClient.query('profile');
      if (result.isNotEmpty) {
        return AcesStudent.fromMap(result.first);
      }
      return null;
    } catch (e) {
      print('Error getting profile: $e');
      return null;
    }
  }
  static Future<String?> getToken() async {
    final dbClient = await db;
    final result = await dbClient.query('profile', columns: ['token']);
    if (result.isNotEmpty && result.first['token'] != null) {
      return result.first['token'] as String;
    }
    return null;
  }

  static Future<void> updateToken(String token) async {
    final dbClient = await db;
    await dbClient.update(
      'profile',
      {'token': token},
      where: 'id IS NOT NULL',
    );
  }

  static Future<void> clearProfile() async {
    final dbClient = await db;
    await dbClient.delete('profile');
  }

  static Future<bool> profileExists() async {
    final dbClient = await db;
    final result = await dbClient.query('profile');
    return result.isNotEmpty;
  }

  // Optional: Get complete profile data including token
  static Future<Map<String, dynamic>?> getCompleteProfile() async {
    final dbClient = await db;
    final result = await dbClient.query('profile');
    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }
}