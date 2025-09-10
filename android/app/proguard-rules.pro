# Flutter Local Notifications
-keep class com.dexterous.flutterlocalnotifications.** { *; }
-keep class * extends com.dexterous.flutterlocalnotifications.NotificationBroadcastReceiver { *; }

# TimeZone
-keep class tzdata.** { *; }

# Keep platform channels
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.embedding.** { *; }