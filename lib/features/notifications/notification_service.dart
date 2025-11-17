import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

// Top-level function for background notification handling
@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse response) {
  Logger().i('Background notification tapped: ${response.payload}');
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;

  bool _isTimezoneInitialized = false;
  Function(String?)? _onNotificationTapCallback;
  bool _isInitialized = false;

  NotificationService._internal() {
    _initializeTimeZone();
  }

  void _initializeTimeZone() {
    if (!_isTimezoneInitialized) {
      try {
        tz.initializeTimeZones();
        tz.setLocalLocation(tz.getLocation('Africa/Lagos'));
        _isTimezoneInitialized = true;
        print('Timezone initialized successfully');
      } catch (e) {
        print('Failed to initialize timezone $e');
      }
    }
  }

  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  // Enhanced initialization with notification channels
  Future<NotificationAppLaunchDetails?> initialize({
    Function(String?)? onNotificationTap,
  }) async {
    _onNotificationTapCallback = onNotificationTap;
    print('Initializing Notification Service');

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      requestCriticalPermission: true, // Enhanced for reliability
    );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    try {
      // Create notification channels (Android)
      await _createNotificationChannels();

      final NotificationAppLaunchDetails? launchDetails =
          await _notifications.getNotificationAppLaunchDetails();
      print('Notification launch details: ${launchDetails?.didNotificationLaunchApp}');

      await _notifications.initialize(
        settings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          print('Notification tapped: ${response.payload}');
          _onNotificationTapCallback?.call(response.payload);
        },
        onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
      );

      _isInitialized = true;
      print('Notification service initialized successfully');

      // Reschedule persistent notifications after initialization
      WidgetsBinding.instance.addPostFrameCallback((_) {
        reschedulePersistentNotifications();
      });

      return launchDetails;
    } catch (e, stackTrace) {
      print('Error initializing notifications $e');
      _isInitialized = false;
      return null;
    }
  }

  // Create notification channels for Android
  Future<void> _createNotificationChannels() async {
    try {
      final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

      if (androidPlugin != null) {
        // Scheduled notifications channel
        const AndroidNotificationChannel scheduledChannel = AndroidNotificationChannel(
          'scheduled_channel',
          'Scheduled Notifications',
          description: 'Scheduled notifications that work when app is killed',
          importance: Importance.high,
          playSound: true,
          enableVibration: true,
          showBadge: true,
        );

        // Daily notifications channel
        const AndroidNotificationChannel dailyChannel = AndroidNotificationChannel(
          'daily_channel',
          'Daily Notifications',
          description: 'Daily recurring notifications',
          importance: Importance.high,
          playSound: true,
          enableVibration: true,
          showBadge: true,
        );

        // Weekly notifications channel
        const AndroidNotificationChannel weeklyChannel = AndroidNotificationChannel(
          'weekly_channel',
          'Weekly Notifications',
          description: 'Weekly recurring notifications',
          importance: Importance.high,
          playSound: true,
          enableVibration: true,
          showBadge: true,
        );

        // Todo notifications channel
        const AndroidNotificationChannel todoChannel = AndroidNotificationChannel(
          'todo_channel',
          'Todo Notifications',
          description: 'Notifications for todo deadlines',
          importance: Importance.high,
          playSound: true,
          enableVibration: true,
          showBadge: true,
        );

        // Simple notifications channel
        const AndroidNotificationChannel simpleChannel = AndroidNotificationChannel(
          'simple_channel',
          'Simple Notifications',
          description: 'Instant notifications',
          importance: Importance.high,
          playSound: true,
          enableVibration: true,
          showBadge: true,
        );

        // Image notifications channel
        const AndroidNotificationChannel imageChannel = AndroidNotificationChannel(
          'image_channel',
          'Image Notifications',
          description: 'Notifications with images',
          importance: Importance.high,
          playSound: true,
          enableVibration: true,
          showBadge: true,
        );

        await androidPlugin.createNotificationChannel(scheduledChannel);
        await androidPlugin.createNotificationChannel(dailyChannel);
        await androidPlugin.createNotificationChannel(weeklyChannel);
        await androidPlugin.createNotificationChannel(todoChannel);
        await androidPlugin.createNotificationChannel(simpleChannel);
        await androidPlugin.createNotificationChannel(imageChannel);
        
        print('All notification channels created successfully');
      }
    } catch (e) {
      print('Error creating notification channels: $e');
    }
  }

  // Enhanced permission handling
  Future<bool> requestPermissions() async {
    print('Requesting notification permissions');
    
    try {
      if (!_isInitialized) {
        print('Notification service not initialized. Call initialize() first.');
        return false;
      }

      bool permissionsGranted = true;

      // Android specific permissions
      if (Platform.isAndroid) {
        final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
        
        if (androidPlugin != null) {
          print('Requesting Android permissions');
          final bool? notificationsGranted =
              await androidPlugin.requestNotificationsPermission();
          final bool? exactAlarmsGranted =
              await androidPlugin.requestExactAlarmsPermission();
          
          print('Android permissions - Notifications: $notificationsGranted, Exact Alarms: $exactAlarmsGranted');
          
          permissionsGranted = (notificationsGranted ?? false);
          
          if (!(exactAlarmsGranted ?? true)) {
            print('Warning: Exact alarms permission not granted - scheduled notifications may be delayed');
          }

          // Request battery optimization exemption
          await _requestBatteryOptimizationExemption();
        } else {
          print('Android notifications plugin not available');
        }
      }

      // iOS permissions
      final iosPlugin = _notifications.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      
      if (iosPlugin != null) {
        print('Requesting iOS permissions');
        final iosSettings = await iosPlugin.checkPermissions();
        
        if (iosSettings?.isEnabled != true) {
          final bool? iosGranted = await iosPlugin.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
            critical: true, // Enhanced for reliability
          );
          print('iOS permissions granted: $iosGranted');
          permissionsGranted = permissionsGranted && (iosGranted ?? false);
        } else {
          print('iOS permissions already granted');
        }
      } else {
        print('iOS notifications plugin not available');
      }

      print('Permission request completed: $permissionsGranted');
      return permissionsGranted;
    } catch (e, stackTrace) {
      print('Error requesting permissions ${e}');
      return false;
    }
  }

  // Battery optimization exemption for Android
  Future<void> _requestBatteryOptimizationExemption() async {
    if (Platform.isAndroid) {
      try {
        print('Consider implementing battery optimization exemption for better reliability on Android devices');
        // Note: This would typically require platform channels to access Android's PowerManager
        // You can implement this later without breaking existing functionality
      } catch (e) {
        print('Battery optimization request error: $e');
      }
    }
  }

  /// Checks if notification permissions are granted
  Future<bool> arePermissionsGranted() async {
    print('Checking notification permissions');
    
    try {
      if (!_isInitialized) {
        print('Notification service not initialized');
        return false;
      }

      bool allGranted = true;

      final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      
      if (androidPlugin != null) {
        final bool? notificationsGranted =
            await androidPlugin.areNotificationsEnabled();
        final bool? exactAlarmsGranted =
            await androidPlugin.canScheduleExactNotifications();
        
        print('Android permissions - Enabled: $notificationsGranted, Exact: $exactAlarmsGranted');
        
        if (!(notificationsGranted ?? false)) {
          allGranted = false;
        }
        
        if (!(exactAlarmsGranted ?? true)) {
          print('Warning: Exact alarms permission not granted');
        }
      }

      final iosPlugin = _notifications.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      
      if (iosPlugin != null) {
        final iosSettings = await iosPlugin.checkPermissions();
        print('iOS permissions: ${iosSettings?.isEnabled}');
        if (!(iosSettings?.isEnabled ?? false)) {
          allGranted = false;
        }
      }

      print('Permissions granted: $allGranted');
      return allGranted;
    } catch (e, stackTrace) {
      print('Error checking permissions ${e}');
      return false;
    }
  }

  // Enhanced notification methods with better reliability

  Future<void> showImageNotification({
    required int id,
    required String title,
    required String body,
    required String imageUrl,
    String? payload,
  }) async {
    print('Showing image notification: $title');

    if (!_isInitialized) {
      print('Notification service not initialized. Call initialize() first.');
      return;
    }

    final bool hasPermissions = await arePermissionsGranted();
    if (!hasPermissions) {
      print('No notification permissions, requesting...');
      final granted = await requestPermissions();
      if (!granted) {
        print('Cannot show notification: Permissions not granted');
        return;
      }
    }

    final Directory tempDir = await getTemporaryDirectory();
    final String filePath = '${tempDir.path}/notif_$id.jpg';

    try {
      print('Downloading image from: $imageUrl');
      final response = await http.get(Uri.parse(imageUrl));
      
      if (response.statusCode != 200) {
        print('Failed to download image. Status code: ${response.statusCode}');
        throw Exception('HTTP ${response.statusCode}');
      }

      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);
      print('Image saved to: $filePath');

      final bigPicture = BigPictureStyleInformation(
        FilePathAndroidBitmap(file.path),
        contentTitle: title,
        summaryText: body,
      );

      final androidDetails = AndroidNotificationDetails(
        'image_channel',
        'Image Notifications',
        channelDescription: 'Notifications with images',
        styleInformation: bigPicture,
        importance: Importance.high,
        priority: Priority.high,
        visibility: NotificationVisibility.public, // Enhanced for reliability
        playSound: true,
        enableVibration: true,
      );

      const iosDetails = DarwinNotificationDetails();

      final details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      print('Showing notification with ID: $id');
      await _notifications.show(id, title, body, details, payload: payload);
      print('Image notification shown successfully: $title');

    } catch (e, stackTrace) {
      print('Error showing image notification: $title error: $e');
      
      print('Falling back to simple notification');
      await showSimpleNotification(
        id: id, 
        title: title, 
        body: body, 
        payload: payload
      );
    }
  }

  // 1. Simple Notification (shows immediately)
  Future<void> showSimpleNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    print('Showing simple notification: $title');

    if (!_isInitialized) {
      print('Notification service not initialized. Call initialize() first.');
      return;
    }

    final bool hasPermissions = await arePermissionsGranted();
    if (!hasPermissions) {
      print('No notification permissions, requesting...');
      final granted = await requestPermissions();
      if (!granted) {
        print('Cannot show notification: Permissions not granted');
        return;
      }
    }

    try {
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'simple_channel',
        'Simple Notifications',
        channelDescription: 'Instant notifications',
        importance: Importance.high,
        priority: Priority.high,
        visibility: NotificationVisibility.public, // Enhanced for reliability
        playSound: true,
        enableVibration: true,
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();
      const NotificationDetails details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      print('Showing notification with ID: $id');
      await _notifications.show(id, title, body, details, payload: payload);
      print('Simple notification shown successfully: $title');

    } catch (e, stackTrace) {
      print('Error showing simple notification: $title Error: $e');
    }
  }

  // 2. Enhanced Schedule Notification (at specific DateTime)
  Future<bool> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
  }) async {
    try {
      if (!_isInitialized) {
        print('Notification service not initialized. Call initialize() first.');
        return false;
      }

      if (!await arePermissionsGranted()) {
        final granted = await requestPermissions();
        if (!granted) {
          print('Cannot schedule notification: Permissions not granted');
          return false;
        }
      }

      if (scheduledTime.isBefore(DateTime.now())) {
        print('Scheduled time is in the past');
        return false;
      }

      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'scheduled_channel',
        'Scheduled Notifications',
        channelDescription: 'Scheduled notifications that work when app is killed',
        importance: Importance.high,
        priority: Priority.high,
        visibility: NotificationVisibility.public,
        playSound: true,
        enableVibration: true,
        timeoutAfter: 0, // Never timeout
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();
      const NotificationDetails details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      final tz.TZDateTime tzScheduledTime = tz.TZDateTime.from(scheduledTime, tz.local);

      print('Scheduling notification for: $tzScheduledTime');

      await _notifications.zonedSchedule(
        id,
        title,
        body,
        tzScheduledTime,
        details,
        payload: payload,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,

      );

      print('Notification scheduled successfully with ID: $id');
      return true;
    } catch (e, stackTrace) {
      print('Error scheduling notification: $e');
      return false;
    }
  }

  // 3. Enhanced Daily Notification (at specific time each day)
  Future<bool> scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required TimeOfDay notificationTime,
    String? payload,
  }) async {
    try {
      if (!await arePermissionsGranted()) {
        final granted = await requestPermissions();
        if (!granted) {
          print('Cannot show notification: Permissions not granted');
          return false;
        }
      }

      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'daily_channel',
        'Daily Notifications',
        channelDescription: 'Daily recurring notifications',
        importance: Importance.high,
        priority: Priority.high,
        visibility: NotificationVisibility.public,
        playSound: true,
        enableVibration: true,
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();
      const NotificationDetails details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
      tz.TZDateTime scheduledTime = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        notificationTime.hour,
        notificationTime.minute,
        0,
      );

      if (scheduledTime.isBefore(now)) {
        scheduledTime = scheduledTime.add(const Duration(days: 1));
      }

      await _notifications.zonedSchedule(
        id,
        title,
        body,
        scheduledTime,
        details,
        payload: payload,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );

      print('Daily notification scheduled successfully with ID: $id');
      return true;
    } catch (e, stackTrace) {
      print('Error scheduling daily notification: $e');
      return false;
    }
  }

  // 4. Enhanced Weekly Notification (on specific day and time)
  Future<bool> scheduleWeeklyNotification({
    required int id,
    required String title,
    required String body,
    required Day day,
    required TimeOfDay notificationTime,
    String? payload,
  }) async {
    try {
      if (!await arePermissionsGranted()) {
        final granted = await requestPermissions();
        if (!granted) {
          print('Cannot show notification: Permissions not granted');
          return false;
        }
      }

      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'weekly_channel',
        'Weekly Notifications',
        channelDescription: 'Weekly recurring notifications',
        importance: Importance.high,
        priority: Priority.high,
        visibility: NotificationVisibility.public,
        playSound: true,
        enableVibration: true,
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();
      const NotificationDetails details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
      int daysUntilNext = ((day.value % 7) - now.weekday + 7) % 7;
      
      if (daysUntilNext == 0 &&
          (now.hour > notificationTime.hour ||
              (now.hour == notificationTime.hour &&
                  now.minute >= notificationTime.minute))) {
        daysUntilNext = 7;
      }

      tz.TZDateTime scheduledTime = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day + daysUntilNext,
        notificationTime.hour,
        notificationTime.minute,
        0,
      );

      await _notifications.zonedSchedule(
        id,
        title,
        body,
        scheduledTime,
        details,
        payload: payload,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );

      print('Weekly notification scheduled successfully with ID: $id');
      return true;
    } catch (e, stackTrace) {
      print('Error scheduling weekly notification: $e');
      return false;
    }
  }

  // 5. Enhanced Todo-specific notification (30 minutes before deadline)
  Future<bool> scheduleTodoNotification({
    required int id,
    required String title,
    required String body,
    required DateTime deadline,
    String? payload,
  }) async {
    try {
      if (!await arePermissionsGranted()) {
        final granted = await requestPermissions();
        if (!granted) {
          print('Cannot show notification: Permissions not granted');
          return false;
        }
      }

      final tz.TZDateTime notificationTime = tz.TZDateTime.from(
        deadline.subtract(const Duration(minutes: 30)),
        tz.local,
      );

      if (notificationTime.isBefore(tz.TZDateTime.now(tz.local))) {
        print('Todo notification time is in the past');
        return false;
      }

      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'todo_channel',
        'Todo Notifications',
        channelDescription: 'Notifications for todo deadlines',
        importance: Importance.high,
        priority: Priority.high,
        visibility: NotificationVisibility.public,
        playSound: true,
        enableVibration: true,
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();
      const NotificationDetails details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications.zonedSchedule(
        id,
        title,
        body,
        notificationTime,
        details,
        payload: payload,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );

      print('Todo notification scheduled successfully with ID: $id');
      return true;
    } catch (e, stackTrace) {
      print('Error scheduling todo notification: $e');
      return false;
    }
  }

  // Existing methods maintained for backward compatibility
  Future<void> handleColdStart() async {
    print('Handling cold start');
    
    try {
      final NotificationAppLaunchDetails? launchDetails =
          await _notifications.getNotificationAppLaunchDetails();

      if (launchDetails?.didNotificationLaunchApp ?? false) {
        final payload = launchDetails?.notificationResponse?.payload;
        print('App launched from notification with payload: $payload');
      } else {
        print('App not launched from notification');
      }
    } catch (e, stackTrace) {
      print('Error handling cold start $e');
    }
  }

  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }

  // NEW: Enhanced methods for better reliability

  /// Reschedule persistent notifications when app starts
  Future<void> reschedulePersistentNotifications() async {
    try {
      // This is where you would reschedule notifications from persistent storage
      // For now, it's a placeholder that you can customize based on your app's needs
      
      // Example: You might want to reschedule daily reminders here
      // await scheduleDailyNotification(
      //   id: 1001,
      //   title: 'Daily Reminder',
      //   body: 'Your daily notification',
      //   notificationTime: TimeOfDay(hour: 9, minute: 0),
      // );
      
      print('Persistent notifications rescheduled (if any)');
    } catch (e) {
      print('Error rescheduling persistent notifications: $e');
    }
  }

  /// Verify scheduled notifications (debugging tool)
  Future<void> verifyScheduledNotifications() async {
    try {
      final pending = await getPendingNotifications();
      print('=== PENDING NOTIFICATIONS ===');
      print('Count: ${pending.length}');
      
      for (final notification in pending) {
        print('ID: ${notification.id} | Title: ${notification.title} | Body: ${notification.body}');
      }
      print('=== END PENDING NOTIFICATIONS ===');
    } catch (e) {
      print('Error verifying scheduled notifications: $e');
    }
  }

  /// Check if a specific notification is scheduled
  Future<bool> isNotificationScheduled(int id) async {
    try {
      final pending = await getPendingNotifications();
      return pending.any((notification) => notification.id == id);
    } catch (e) {
      print('Error checking if notification is scheduled: $e');
      return false;
    }
  }

  void handleBackgroundNotification(String? payload) {
    if (payload != null) {
      print('Processing background notification payload: $payload');
      _onNotificationTapCallback?.call(payload);
    }
  }

  // Add these methods to your NotificationService class

/// Schedule class reminder 15 minutes before class
Future<bool> scheduleClassReminder({
  required int id,
  required String courseTitle,
  required String courseCode,
  required DateTime classTime,
  required String day,
}) async {
  try {
    if (!_isInitialized) {
      print('Notification service not initialized');
      return false;
    }

    // Schedule notification 15 minutes before class
    final notificationTime = classTime.subtract(const Duration(minutes: 15));
    
    // Skip if the notification time has already passed
    if (notificationTime.isBefore(DateTime.now())) {
      print('Class notification time has passed for $courseCode');
      return false;
    }

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'class_reminder_channel',
      'Class Reminders',
      channelDescription: 'Notifications for upcoming classes',
      importance: Importance.high,
      priority: Priority.high,
      visibility: NotificationVisibility.public,
      playSound: true,
      enableVibration: true,
      timeoutAfter: 0,
      channelShowBadge: true,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();
    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final tz.TZDateTime tzScheduledTime = 
        tz.TZDateTime.from(notificationTime, tz.local);

    print('Scheduling class reminder for $courseCode at $tzScheduledTime');

    await _notifications.zonedSchedule(
      id,
      'Upcoming Class: $courseCode',
      '$courseTitle starts in 15 minutes',
      tzScheduledTime,
      details,
      payload: 'class_reminder|$courseCode|$day',
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );

    print('Class reminder scheduled successfully for $courseCode');
    return true;
  } catch (e, stackTrace) {
    print('Error scheduling class reminder for $courseCode: $e');
    return false;
  }
}

/// Schedule daily morning reminder at 7:00 AM
Future<bool> scheduleDailyMorningReminder() async {
  try {
    if (!_isInitialized) {
      print('Notification service not initialized');
      return false;
    }

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'daily_reminder_channel',
      'Daily Reminders',
      channelDescription: 'Daily morning reminders',
      importance: Importance.high,
      priority: Priority.high,
      visibility: NotificationVisibility.public,
      playSound: true,
      enableVibration: true,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();
    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Schedule for 7:00 AM daily
    final now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledTime = tz.TZDateTime(tz.local, now.year, now.month, now.day, 7, 0);

    // If it's already past 7:00 AM today, schedule for tomorrow
    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }

    await _notifications.zonedSchedule(
      999, // Fixed ID for daily reminder
      '📚 Your Classes Today',
      'Check your timetable for today\'s classes',
      scheduledTime,
      details,
      payload: 'daily_reminder',
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );

    print('Daily morning reminder scheduled successfully');
    return true;
  } catch (e, stackTrace) {
    print('Error scheduling daily morning reminder: $e');
    return false;
  }
}

/// Cancel all class-related notifications
Future<void> cancelAllClassNotifications() async {
  try {
    final pending = await getPendingNotifications();
    
    for (final notification in pending) {
      // Cancel notifications with IDs in the class notification range (1000-1999)
      // and the daily reminder (999)
      if ((notification.id >= 1000 && notification.id <= 1999) || notification.id == 999) {
        await cancelNotification(notification.id);
        print('Cancelled class notification: ${notification.id}');
      }
    }
    
    print('All class notifications cancelled');
  } catch (e) {
    print('Error cancelling class notifications: $e');
  }
}
}

// Extension to your NotificationService class (maintained for backward compatibility)
extension NotificationServiceExtension on NotificationService {
  /// Checks if notifications are enabled at both system and app level
  Future<bool> areNotificationsEnabled() async {
    try {
      final bool areEnabled = await _checkPlatformNotificationsEnabled();
      return areEnabled;
    } catch (e) {
      return false;
    }
  }

  Future<bool> _checkPlatformNotificationsEnabled() async {
    if (Platform.isAndroid) {
      return await _checkAndroidNotificationsEnabled();
    } else if (Platform.isIOS) {
      return await _checkIOSNotificationsEnabled();
    }
    return false;
  }

  /// Android-specific notification checks
  Future<bool> _checkAndroidNotificationsEnabled() async {
    try {
      final androidPlugin = NotificationService._notifications.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      
      if (androidPlugin == null) {
        return false;
      }

      final bool? systemEnabled = await androidPlugin.areNotificationsEnabled();
      final bool? exactAlarmsEnabled = 
          await androidPlugin.canScheduleExactNotifications();
      final bool? appEnabled = await androidPlugin.areNotificationsEnabled();

      return (systemEnabled ?? false) && 
             (exactAlarmsEnabled ?? true) && 
             (appEnabled ?? false);
    } catch (e) {
      return false;
    }
  }

  /// iOS-specific notification checks
  Future<bool> _checkIOSNotificationsEnabled() async {
    try {
      final iosPlugin = NotificationService._notifications.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      
      if (iosPlugin == null) {
        return false;
      }

      final notificationSettings = await iosPlugin.checkPermissions();
      return notificationSettings?.isEnabled ?? false;
    } catch (e) {
      return false;
    }
  }
}