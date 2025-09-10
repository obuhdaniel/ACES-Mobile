// services/background_init_service.dart
import 'package:aces_uniben/features/tools/timetable/services/timetable_db_helper.dart';
import 'package:aces_uniben/features/tools/timetable/services/timetable_api_services.dart';

class BackgroundInitService {
  final TimeTableApiService _apiService = TimeTableApiService();
  final TimeTableDatabaseHelper _databaseHelper = TimeTableDatabaseHelper();
  
  static bool _isInitialized = false;
  static bool _isInitializing = false;

  Future<void> initializeInBackground() async {
    if (_isInitialized || _isInitializing) return;
    
    _isInitializing = true;
    
    try {
      // First, ensure database is ready (this is fast)
      await _databaseHelper.database;
      
      // Check if we already have data
      final hasData = await _hasAnyData();
      
      if (!hasData) {
        // Start background fetch without blocking
        _startBackgroundFetch();
      } else {
        _isInitialized = true;
      }
    } catch (e) {
      print('Background init failed: $e');
    } finally {
      _isInitializing = false;
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
  }

  void _startBackgroundFetch() {
    // Use a separate isolate or future to avoid blocking
    Future(() async {
      try {
        print('Starting background timetable fetch...');
        
        // Fetch data in chunks if possible, or implement progress reporting
        final timeTableResponse = await _apiService.fetchTimeTable();
        
        // Sync to database
        await _databaseHelper.syncTimeTable(timeTableResponse);
        
        print('Background timetable fetch completed');
        _isInitialized = true;
      } catch (e) {
        print('Background fetch failed: $e');
        // You can retry later or just let it fail silently
      }
    });
  }

  static bool get isInitialized => _isInitialized;
}