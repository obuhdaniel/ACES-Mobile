// Utility function to create JSON payloads
import 'dart:convert';

class NotificationPayload {
  static String createTodoPayload({String id = '', String title = '', String category = ''}) {
    return jsonEncode({
      'type': 'todo',
      'id': id,
      'title': title,
      'category': category,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }
  
  static String createLearnPayload({String topic = '', String difficulty = '', int duration = 0}) {
    return jsonEncode({
      'type': 'learn',
      'topic': topic,
      'difficulty': difficulty,
      'duration': duration,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }
  
  static String createTimetablePayload({String eventId = '', String title = '', DateTime? time}) {
    return jsonEncode({
      'type': 'timetable',
      'eventId': eventId,
      'title': title,
      'time': time?.toIso8601String(),
      'timestamp': DateTime.now().toIso8601String(),
    });
  }
}