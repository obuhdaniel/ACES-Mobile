import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;

  bool _isTimezoneInitialized = false;
   Function(String?)? _onNotificationTapCallback;

  NotificationService._internal() {
    _initializeTimeZone();
  }

  // Initialize timezone only once
  void _initializeTimeZone() {
    if (!_isTimezoneInitialized) {
      tz.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation('Africa/Lagos'));
      _isTimezoneInitialized = true;
    }
  }

  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  Future<NotificationAppLaunchDetails?> initialize(
      {Function(String?)? onNotificationTap}) async {
        _onNotificationTapCallback = onNotificationTap;

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
      // Get launch details first
      final NotificationAppLaunchDetails? launchDetails =
          await _notifications.getNotificationAppLaunchDetails();

      await _notifications.initialize(
        settings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          print('Notification response received: ${response.payload}');
          if (_onNotificationTapCallback != null) {
            _onNotificationTapCallback!(response.payload);
          }
        },
        onDidReceiveBackgroundNotificationResponse: (NotificationResponse response) {
          print('Background notification response: ${response.payload}');
          // This handles background notifications on iOS
          if (_onNotificationTapCallback != null) {
            _onNotificationTapCallback!(response.payload);
          }
        },
      );


      return launchDetails;
    } catch (e) {
      print('Error initializing notifications: $e');
      return null;
    }
  }

  /// Requests notification permissions for both Android and iOS
  Future<bool> requestPermissions() async {
    try {
      bool permissionsGranted = true;

      final androidPlugin =
          _notifications.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        final bool? notificationsGranted =
            await androidPlugin.requestNotificationsPermission();
        final bool? exactAlarmsGranted =
            await androidPlugin.requestExactAlarmsPermission();
        permissionsGranted =
            (notificationsGranted ?? false) && (exactAlarmsGranted ?? true);
      }

      final iosPlugin = _notifications.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      if (iosPlugin != null) {
        final iosSettings = await iosPlugin.checkPermissions();
        if (iosSettings?.isEnabled != true) {
          final bool? iosGranted = await iosPlugin.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
            critical: false,
          );
          permissionsGranted = iosGranted ?? false;
        }
      }

      return permissionsGranted;
    } catch (e) {
      print('Error requesting permissions: $e');
      return false;
    }
  }

  /// Checks if notification permissions are granted
  Future<bool> arePermissionsGranted() async {
    try {
      final androidPlugin =
          _notifications.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        final bool? notificationsGranted =
            await androidPlugin.areNotificationsEnabled();
        final bool? exactAlarmsGranted =
            await androidPlugin.canScheduleExactNotifications();
        if (!(notificationsGranted ?? false) || !(exactAlarmsGranted ?? true)) {
          return false;
        }
      }

      final iosPlugin = _notifications.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      if (iosPlugin != null) {
        final iosSettings = await iosPlugin.checkPermissions();
        return iosSettings?.isEnabled ?? false;
      }

      return true;
    } catch (e) {
      print('Error checking permissions: $e');
      return false;
    }
  }

  // Add to NotificationService class
  Future<void> handleColdStart() async {
    try {
      final NotificationAppLaunchDetails? launchDetails =
          await _notifications.getNotificationAppLaunchDetails();

      if (launchDetails?.didNotificationLaunchApp ?? false) {
        final payload = launchDetails?.notificationResponse?.payload;
        if (payload != null) {
          // You might want to pass this to a callback or store it
          print('App launched from notification with payload: $payload');
          // You can trigger navigation from here or return the payload
        }
      }
    } catch (e) {
      print('Error handling cold start: $e');
    }
  }

  Future<void> showImageNotification({
    required int id,
    required String title,
    required String body,
    required String imageUrl,
    String? payload,
  }) async {
    if (!await arePermissionsGranted()) {
      final granted = await requestPermissions();
      if (!granted) return;
    }

    // 1. Download the image to a temp file
    final Directory tempDir = await getTemporaryDirectory();
    final String filePath = '${tempDir.path}/notif_$id.jpg';

    try {
      final response = await http.get(Uri.parse(imageUrl));
      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);

      // 2. Use BigPicture with downloaded file
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

      await _notifications.show(id, title, body, details, payload: payload);
    } catch (e) {
      print("Error loading image: $e");
      // fallback to simple notification if image fails
      await showSimpleNotification(
          id: id, title: title, body: body, payload: payload);
    }
  }

  // 1. Simple Notification (shows immediately)
  Future<void> showSimpleNotification({
    required int id,
    required String title,
    required String body,
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

    await _notifications.show(id, title, body, details, payload: payload);
  }

  // 2. Schedule Notification (at specific DateTime)
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
  }) async {
    if (!await arePermissionsGranted()) {
      final granted = await requestPermissions();
      if (!granted) {
        print('Cannot show notification: Permissions not granted');
        return;
      }
    }

    // Don't schedule if the time has already passed
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

    // Convert DateTime to TZDateTime using the local timezone
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

  // 3. Interval-based Notification (repeats at intervals)
  // Future<void> scheduleIntervalNotification({
  //   required int id,
  //   required String title,
  //   required String body,
  //   required RepeatInterval interval,
  //   String? payload,
  // }) async {
  //   if (!await arePermissionsGranted()) {
  //     final granted = await requestPermissions();
  //     if (!granted) {
  //       print('Cannot show notification: Permissions not granted');
  //       return;
  //     }
  //   }

  //   const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
  //     'interval_channel',
  //     'Interval Notifications',
  //     channelDescription: 'Repeating interval notifications',
  //     importance: Importance.high,
  //     priority: Priority.high,
  //   );

  //   const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

  //   const NotificationDetails details = NotificationDetails(
  //     android: androidDetails,
  //     iOS: iosDetails,
  //   );

  //   await _notifications.zonedSchedule(
  //     id,
  //     title,
  //     body,
  //     details,
  //     payload: payload,
  //   );
  // }

  // 4. Daily Notification (at specific time each day)
  Future<void> scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
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

    // Calculate first notification time
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

    // Calculate first notification time
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

    // Don't schedule if the time has already passed
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
