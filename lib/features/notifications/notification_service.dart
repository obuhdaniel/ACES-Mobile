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
  // This function must be top-level or static
  // You can't use instance methods here, so we'll need to handle this differently
  Logger().i('Background notification tapped: ${response.payload}');
  
  // If you need to route based on the payload, you might need to use
  // platform channels or store the payload for when the app resumes
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
        print('Failed to initialize timezone $e',);
      }
    }
  }

  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();



      


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
      requestCriticalPermission: false,
    );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    try {

      final NotificationAppLaunchDetails? launchDetails =
          await _notifications.getNotificationAppLaunchDetails();
      print('Notification launch details: ${launchDetails?.didNotificationLaunchApp}');

      await _notifications.initialize(
        settings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          print('Notification tapped: ${response.payload}');
          _onNotificationTapCallback?.call(response.payload);
        },
        // Use the top-level function for background handling
        onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
      );

      _isInitialized = true;
      print('Notification service initialized successfully');
      return launchDetails;
    } catch (e, stackTrace) {
      print('Error initializing notifications $e');
      _isInitialized = false;
      return null;
    }
  }

  // Add this method to handle background notifications when app is in foreground
  void handleBackgroundNotification(String? payload) {
    if (payload != null) {
      print('Processing background notification payload: $payload');
      _onNotificationTapCallback?.call(payload);
    }
  }
  
    /// Requests notification permissions for both Android and iOS
    Future<bool> requestPermissions() async {
    print('Requesting notification permissions');
    
    try {

      if (!_isInitialized) {
        print('Notification service not initialized. Call initialize() first.');
        return false;
      }

      bool permissionsGranted = true;

      final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      
      if (androidPlugin != null) {
        print('Requesting Android permissions');
        final bool? notificationsGranted =
            await androidPlugin.requestNotificationsPermission();
        final bool? exactAlarmsGranted =
            await androidPlugin.requestExactAlarmsPermission();
        
        print('Android permissions - Notifications: $notificationsGranted, Exact Alarms: $exactAlarmsGranted');
        
        permissionsGranted =
            (notificationsGranted ?? false) && (exactAlarmsGranted ?? true);
      } else {
        print('Android notifications plugin not available');
      }

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
            critical: false,
          );
          print('iOS permissions granted: $iosGranted');
          permissionsGranted = iosGranted ?? false;
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
  }  /// Checks if notification permissions are granted
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
        
        if (!(notificationsGranted ?? false) || !(exactAlarmsGranted ?? true)) {
          allGranted = false;
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
      print('Error showing image notification: $title error: $e',);
      
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
      print('Error showing simple notification: $title Error: $e',);
    }
  }

  // 2. Schedule Notification (at specific DateTime)
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
  }) async {
    // Skip scheduling in release mode


    if (!await arePermissionsGranted()) {
      final granted = await requestPermissions();
      if (!granted) {
        print('Cannot show notification: Permissions not granted');
        return;
      }
    }

    if (scheduledTime.isBefore(DateTime.now())) {
      return;
    }

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'scheduled_channel',
      'Scheduled Notifications',
      channelDescription: 'Scheduled notifications',
      importance: Importance.high,
      priority: Priority.high,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final tz.TZDateTime tzScheduledTime =
        tz.TZDateTime.from(scheduledTime, tz.local);

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tzScheduledTime,
      details,
      payload: payload,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  // 4. Daily Notification (at specific time each day)
  Future<void> scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required TimeOfDay notificationTime,
    String? payload,
  }) async {
    // Skip scheduling in release mode



    if (!await arePermissionsGranted()) {
      final granted = await requestPermissions();
      if (!granted) {
        print('Cannot show notification: Permissions not granted');
        return;
      }
    }

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'daily_channel',
      'Daily Notifications',
      channelDescription: 'Daily recurring notifications',
      importance: Importance.high,
      priority: Priority.high,
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
  }

  // 5. Weekly Notification (on specific day and time)
  Future<void> scheduleWeeklyNotification({
    required int id,
    required String title,
    required String body,
    required Day day,
    required TimeOfDay notificationTime,
    String? payload,
  }) async {


    if (!await arePermissionsGranted()) {
      final granted = await requestPermissions();
      if (!granted) {
        print('Cannot show notification: Permissions not granted');
        return;
      }
    }

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'weekly_channel',
      'Weekly Notifications',
      channelDescription: 'Weekly recurring notifications',
      importance: Importance.high,
      priority: Priority.high,
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
  }

  // 6. Todo-specific notification (30 minutes before deadline)
  Future<void> scheduleTodoNotification({
    required int id,
    required String title,
    required String body,
    required DateTime deadline,
    String? payload,
  }) async {


    if (!await arePermissionsGranted()) {
      final granted = await requestPermissions();
      if (!granted) {
        print('Cannot show notification: Permissions not granted');
        return;
      }
    }

    final tz.TZDateTime notificationTime = tz.TZDateTime.from(
      deadline.subtract(const Duration(minutes: 30)),
      tz.local,
    );

    if (notificationTime.isBefore(tz.TZDateTime.now(tz.local))) {
      return;
    }

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'todo_channel',
      'Todo Notifications',
      channelDescription: 'Notifications for todo deadlines',
      importance: Importance.high,
      priority: Priority.high,
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



  
}


// Extension to your NotificationService class
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
      final androidPlugin =NotificationService. _notifications.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      
      if (androidPlugin == null) {
        return false;
      }

      // Check if notifications are enabled system-wide
      final bool? systemEnabled = await androidPlugin.areNotificationsEnabled();
      
      // Check if exact alarms are permitted (for scheduling)
      final bool? exactAlarmsEnabled = 
          await androidPlugin.canScheduleExactNotifications();
      
      // Check if app notifications are enabled in system settings
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
      final iosPlugin =NotificationService. _notifications.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      
      if (iosPlugin == null) {
        return false;
      }

      // Check iOS notification permissions
      final notificationSettings = await iosPlugin.checkPermissions();

      return notificationSettings?.isEnabled ?? false;
    } catch (e) {
      return false;
    }
  }
}