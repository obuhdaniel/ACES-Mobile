// providers/todo_provider.dart
import 'package:aces_uniben/features/tools/todo/services/todo_db_helper.dart';
import 'package:aces_uniben/services/notification_payload.dart';
import 'package:flutter/foundation.dart';

class TodoProvider with ChangeNotifier {
  int _todayTotalTasks = 0;
  int _todayCompletedTasks = 0;

  int get todayTotalTasks => _todayTotalTasks;
  int get todayCompletedTasks => _todayCompletedTasks;
  int get todayPendingTasks => _todayTotalTasks - _todayCompletedTasks;
  double get todayCompletionPercentage => _todayTotalTasks > 0 
      ? _todayCompletedTasks / _todayTotalTasks 
      : 0.0;


  Future<void> loadTodayStats() async {
    try {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);

      // Get all todos for today
      final todos = await TodoDBHelper.getTodosByDate(today);
      
      _todayTotalTasks = todos.length;
      _todayCompletedTasks = todos.where((todo) => todo.isCompleted).length;
      
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error loading today stats: $e');
      }
      // Reset values on error
      _todayTotalTasks = 0;
      _todayCompletedTasks = 0;
      notifyListeners();
    }
  }

  Future<void> refreshStats() async {
    await loadTodayStats();
  }
}