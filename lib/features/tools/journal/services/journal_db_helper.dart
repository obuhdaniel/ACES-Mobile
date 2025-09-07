// journal_db_helper.dart
import 'package:aces_uniben/features/tools/journal/models/journal_entry_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class JournalDatabaseHelper {
  static final JournalDatabaseHelper instance = JournalDatabaseHelper._init();
  static Database? _database;

  JournalDatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('journal.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    const idType = 'TEXT PRIMARY KEY';
    const textType = 'TEXT NOT NULL';
    const integerType = 'INTEGER NOT NULL';
    const realType = 'REAL NOT NULL';

    await db.execute('''
      CREATE TABLE $tableJournals (
        ${JournalFields.id} $idType,
        ${JournalFields.title} $textType,
        ${JournalFields.content} $textType,
        ${JournalFields.date} $integerType,
        ${JournalFields.timeHour} $integerType,
        ${JournalFields.timeMinute} $integerType,
        ${JournalFields.category} $textType,
        ${JournalFields.colorValue} $integerType
      )
    ''');
  }

  Future<JournalEntry> create(JournalEntry journal) async {
    final db = await instance.database;

    final id = journal.id.isEmpty ? DateTime.now().millisecondsSinceEpoch.toString() : journal.id;
    final journalWithId = journal.copyWith(id: id);

    await db.insert(tableJournals, journalWithId.toJson());
    return journalWithId;
  }

  Future<JournalEntry> read(String id) async {
    final db = await instance.database;

    final maps = await db.query(
      tableJournals,
      columns: JournalFields.values,
      where: '${JournalFields.id} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return JournalEntry.fromJson(maps.first);
    } else {
      throw Exception('ID $id not found');
    }
  }

  Future<List<JournalEntry>> readAll() async {
    final db = await instance.database;

    final orderBy = '${JournalFields.date} DESC, ${JournalFields.timeHour} DESC, ${JournalFields.timeMinute} DESC';
    final result = await db.query(tableJournals, orderBy: orderBy);

    return result.map((json) => JournalEntry.fromJson(json)).toList();
  }

  Future<int> update(JournalEntry journal) async {
    final db = await instance.database;

    return await db.update(
      tableJournals,
      journal.toJson(),
      where: '${JournalFields.id} = ?',
      whereArgs: [journal.id],
    );
  }

  Future<int> delete(String id) async {
    final db = await instance.database;

    return await db.delete(
      tableJournals,
      where: '${JournalFields.id} = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteAll() async {
    final db = await instance.database;
    return await db.delete(tableJournals);
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}

const String tableJournals = 'journals';

class JournalFields {
  static final List<String> values = [
    id, title, content, date, timeHour, timeMinute, category, colorValue
  ];

  static const String id = 'id';
  static const String title = 'title';
  static const String content = 'content';
  static const String date = 'date';
  static const String timeHour = 'time_hour';
  static const String timeMinute = 'time_minute';
  static const String category = 'category';
  static const String colorValue = 'color_value';
}