import 'dart:convert';

import 'package:aces_uniben/features/notifications/notification_service.dart';
import 'package:aces_uniben/services/notification_payload.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;

class ReminderSettings {
  final bool isReminderEnabled;
  final List<String> selectedDays;
  final TimeOfDay selectedTime;
  final String selectedTechPart;

  ReminderSettings({
    required this.isReminderEnabled,
    required this.selectedDays,
    required this.selectedTime,
    required this.selectedTechPart,
  });

  ReminderSettings copyWith({
    bool? isReminderEnabled,
    List<String>? selectedDays,
    TimeOfDay? selectedTime,
    String? selectedTechPart,
  }) {
    return ReminderSettings(
      isReminderEnabled: isReminderEnabled ?? this.isReminderEnabled,
      selectedDays: selectedDays ?? this.selectedDays,
      selectedTime: selectedTime ?? this.selectedTime,
      selectedTechPart: selectedTechPart ?? this.selectedTechPart,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'isReminderEnabled': isReminderEnabled,
      'selectedDays': selectedDays,
      'selectedTime': {
        'hour': selectedTime.hour,
        'minute': selectedTime.minute,
      },
      'selectedTechPart': selectedTechPart,
    };
  }

  static ReminderSettings fromMap(Map<String, dynamic> map) {
    return ReminderSettings(
      isReminderEnabled: map['isReminderEnabled'] ?? false,
      selectedDays: List<String>.from(map['selectedDays'] ?? []),
      selectedTime: TimeOfDay(
        hour: map['selectedTime']['hour'] ?? 9,
        minute: map['selectedTime']['minute'] ?? 0,
      ),
      selectedTechPart: map['selectedTechPart'] ?? 'Flutter Development',
    );
  }

  

  @override
  String toString() {
    return 'ReminderSettings(isReminderEnabled: $isReminderEnabled, selectedDays: $selectedDays, selectedTime: $selectedTime, selectedTechPart: $selectedTechPart)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is ReminderSettings &&
        other.isReminderEnabled == isReminderEnabled &&
        listEquals(other.selectedDays, selectedDays) &&
        other.selectedTime == selectedTime &&
        other.selectedTechPart == selectedTechPart;
  }

  @override
  int get hashCode {
    return isReminderEnabled.hashCode ^
        selectedDays.hashCode ^
        selectedTime.hashCode ^
        selectedTechPart.hashCode;
  }
}

class ReminderProvider with ChangeNotifier {
  final NotificationService _notificationService = NotificationService();
  late final SharedPreferences _prefs;
  
  late ReminderSettings _settings;

  ReminderProvider() {
    _initialize();
  }

    final lpl = NotificationPayload.createLearnPayload(
    topic: '999',
    difficulty: 'Test Todo',
    duration: 30
  );

  Future<void> _initialize() async {
    _prefs = await SharedPreferences.getInstance();
    final jsonString = _prefs.getString('reminder_settings');
    if (jsonString != null) {
      final map = Map<String, dynamic>.from(json.decode(jsonString));
      _settings = ReminderSettings.fromMap(map);
    } else {
      _settings = ReminderSettings(
        isReminderEnabled: false,
        selectedDays: ['Monday', 'Wednesday', 'Friday'],
        selectedTime: TimeOfDay(hour: 9, minute: 0),
        selectedTechPart: 'Web Development',
      );
    }
    notifyListeners();
  }

  ReminderSettings get settings => _settings;

  Future<void> _loadSettings() async {
    try {
      final jsonString = _prefs.getString('reminder_settings');
      if (jsonString != null) {
        final map = Map<String, dynamic>.from(
          Map<String, dynamic>.from(json.decode(jsonString))
        );
        _settings = ReminderSettings.fromMap(map);
        notifyListeners();
        
        // Schedule notifications if enabled
        if (_settings.isReminderEnabled) {
          await _scheduleNotifications();
        }
      }
    } catch (e) {
      print('Error loading reminder settings: $e');
    }
  }

  Future<void> _saveSettings() async {
    try {
      final jsonString = json.encode(_settings.toMap());
      await _prefs.setString('reminder_settings', jsonString);
    } catch (e) {
      print('Error saving reminder settings: $e');
    }
  }

  Future<void> updateSettings(ReminderSettings newSettings) async {
    _settings = newSettings;
    await _saveSettings();
    notifyListeners();
    
    // Cancel existing notifications
    await _notificationService.cancelAllNotifications();
    
    // Schedule new notifications if enabled
    if (_settings.isReminderEnabled) {
      await _scheduleNotifications();
    }
  }

  Future<void> setReminderEnabled(bool enabled) async {
    _settings = _settings.copyWith(isReminderEnabled: enabled);
    await _saveSettings();
    notifyListeners();
    
    if (enabled) {
      await _scheduleNotifications();
    } else {
      await _notificationService.cancelAllNotifications();
    }
  }

  Future<void> setSelectedDays(List<String> days) async {
    _settings = _settings.copyWith(selectedDays: days);
    await _saveSettings();
    notifyListeners();
    
    if (_settings.isReminderEnabled) {
      await _notificationService.cancelAllNotifications();
      await _scheduleNotifications();
    }
  }

  Future<void> setSelectedTime(TimeOfDay time) async {
    _settings = _settings.copyWith(selectedTime: time);
    await _saveSettings();
    notifyListeners();
    
    if (_settings.isReminderEnabled) {
      await _notificationService.cancelAllNotifications();
      await _scheduleNotifications();
    }
  }

  Future<void> setSelectedTechPart(String techPart) async {
    _settings = _settings.copyWith(selectedTechPart: techPart);
    await _saveSettings();
    notifyListeners();
    
    if (_settings.isReminderEnabled) {
      await _notificationService.cancelAllNotifications();
      await _scheduleNotifications();
    }
  }

  void testLocalNotifications() async {
  final notificationService = NotificationService();
  
  // Test simple notification
  await notificationService.showSimpleNotification(
    id: 999,
    title: 'Test Notification',
    body: 'This is a test notification',
    payload: '{"type": "todo", "id": "test_123", "title": "Test Todo"}',
  );
  
  // Test with different payloads
  final testPayloads = [
    '{"type": "learn", "topic": "Mathematics", "difficulty": "easy"}',
    '{"type": "timetable", "eventId": "class_456", "title": "Math Class"}',
    'simple_string_payload', // Test error handling
  ];
  
  for (var i = 0; i < testPayloads.length; i++) {
    await notificationService.showSimpleNotification(
      id: 1000 + i,
      title: 'Test ${i + 1}',
      body: 'Notification with different payload',
      payload: testPayloads[i],
    );
  }
}

  Future<void> _scheduleNotifications() async {
    if (!_settings.isReminderEnabled || _settings.selectedDays.isEmpty) {
      return;
    }

    // Request notification permissions
    final permissionsGranted = await _notificationService.requestPermissions();
    if (!permissionsGranted) {
      print('Notification permissions not granted');
      return;
    }

    // Map day names to Day enum values
    final dayMap = {
      'Monday': Day.monday,
      'Tuesday': Day.tuesday,
      'Wednesday': Day.wednesday,
      'Thursday': Day.thursday,
      'Friday': Day.friday,
      'Saturday': Day.saturday,
      'Sunday': Day.sunday,
    };

    // Schedule notifications for each selected day
    for (final dayName in _settings.selectedDays) {
      final day = dayMap[dayName];
      if (day != null) {
        await _notificationService.scheduleWeeklyNotification(
          id: _generateNotificationId(dayName),
          title: 'Time to learn!',
          body: 'Ready to practice ${_settings.selectedTechPart}?',
          day: day,
          notificationTime: _settings.selectedTime,
          payload: lpl,
        );
      }
    }
  }

  int _generateNotificationId(String dayName) {
    // Generate unique ID based on day name
    final dayIds = {
      'Monday': 1001,
      'Tuesday': 1002,
      'Wednesday': 1003,
      'Thursday': 1004,
      'Friday': 1005,
      'Saturday': 1006,
      'Sunday': 1007,
    };
    return dayIds[dayName] ?? 1000;
  }

  Future<void> testNotification() async {

 

  

    await _notificationService.showSimpleNotification(
      id: 9999,
      title: 'Daily Reminders Settings',
      body: ' Your reminder Settings for ${_settings.selectedTechPart} is now ${_settings.isReminderEnabled? 'Active': 'Disabled'}',
      payload: lpl
    );
  }

  Future<void> cancelAllNotifications() async {
    await _notificationService.cancelAllNotifications();
  }

  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notificationService.getPendingNotifications();
  }
}