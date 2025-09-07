
import 'package:aces_uniben/features/notifications/notification_service.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/todo_model.dart';

class TodoDBHelper {
  static Database? _db;
  static const int _version = 1;
  static const String _tableName = 'todos';
   static final NotificationService _notificationService = NotificationService();
   late final bool permissionsGranted;

   TodoDBHelper() {
     _initializePermissions();
   }

   Future<void> _initializePermissions() async {
     permissionsGranted = await _notificationService.requestPermissions();
   }
 
  static Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'todos.db');

    await _notificationService.initialize();

    return openDatabase(
      path,
      version: _version,
      onCreate: _createTables,
    );
  }

  static Future<void> _createTables(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableName(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        date INTEGER NOT NULL,
        startTime TEXT NOT NULL,
        endTime TEXT NOT NULL,
        isCompleted INTEGER DEFAULT 0,
        createdAt INTEGER NOT NULL
      )
    ''');
  }

  static Future<Database> get db async {
    _db ??= await _initDb();
    return _db!;
  }

  // Create a new todo
  static Future<int> insertTodo(Todo todo) async {
    final dbClient = await db;
    final id = await dbClient.insert(_tableName, todo.toMap());

    await _scheduleTodoNotification(todo.copyWith(id: id), todo.date);

    return id;
  }

  // Get all todos
  static Future<List<Todo>> getAllTodos() async {
    final dbClient = await db;
    final result = await dbClient.query(
      _tableName,
      orderBy: 'date ASC, startTime ASC',
    );
    return result.map((map) => Todo.fromMap(map)).toList();
  }

  // Get todos for a specific date
  static Future<List<Todo>> getTodosByDate(DateTime date) async {
    final dbClient = await db;
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    final result = await dbClient.query(
      _tableName,
      where: 'date BETWEEN ? AND ?',
      whereArgs: [startOfDay.millisecondsSinceEpoch, endOfDay.millisecondsSinceEpoch],
      orderBy: 'startTime ASC',
    );
    return result.map((map) => Todo.fromMap(map)).toList();
  }

  // Update a todo
  static Future<int> updateTodo(Todo todo) async {
    final dbClient = await db;

      await _notificationService.cancelNotification(todo.id!);
    
    // Schedule new notification if todo is not completed
    if (!todo.isCompleted) {
      final deadline = todo.date;
      await _scheduleTodoNotification(todo, deadline);
    }
    
    return await dbClient.update(
      _tableName,
      todo.toMap(),
      where: 'id = ?',
      whereArgs: [todo.id],
    );
  }

  // Toggle completion status
  static Future<int> toggleTodoCompletion(int id, bool isCompleted) async {
    final dbClient = await db;

    if (isCompleted) {
      // Cancel notification when todo is completed
      await _notificationService.cancelNotification(id);
    } else {
      // Reschedule notification when todo is uncompleted
      final todo = await getTodoById(id);
      if (todo != null) {
        final deadline = todo.date;
        await _scheduleTodoNotification(todo, deadline);
      }
    }
    
    return await dbClient.update(
      _tableName,
      {'isCompleted': isCompleted ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Delete a todo
  static Future<int> deleteTodo(int id) async {
    final dbClient = await db;

    await _notificationService.cancelNotification(id);
    return await dbClient.delete(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Delete all todos
  static Future<int> deleteAllTodos() async {
    final dbClient = await db;

    await _notificationService.cancelAllNotifications();
    return await dbClient.delete(_tableName);
  }

  // Get todo by id
  static Future<Todo?> getTodoById(int id) async {
    final dbClient = await db;
    final result = await dbClient.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isNotEmpty) {
      return Todo.fromMap(result.first);
    }
    return null;
  }

   // Helper method to schedule todo notification
  static Future<void> _scheduleTodoNotification(Todo todo, DateTime deadline) async {
    final payload = 'type:todo;id:${todo.id};title:${Uri.encodeComponent(todo.title)}';
    await _notificationService.scheduleTodoNotification(
      id: todo.id!,
      title: 'Todo Reminder: ${todo.title}',
      body: 'Your todo "${todo.title}" is due soon!',
      deadline: deadline,
      payload: payload
    );
  }

  // Method to reschedule all notifications (call this on app startup)
  static Future<void> rescheduleAllNotifications() async {
    final todos = await getAllTodos();
    final now = DateTime.now();
    
    for (final todo in todos) {
      if (!todo.isCompleted) {
        final deadline = todo.date;
        if (deadline.isAfter(now)) {
          await _scheduleTodoNotification(todo, deadline);
        }
      }
    }
  }

  // Close database
  static Future<void> close() async {
    if (_db != null) {
      await _db!.close();
      _db = null;
    }
  }
}