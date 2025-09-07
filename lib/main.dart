import 'dart:convert';

import 'package:aces_uniben/config/app_theme.dart';
import 'package:aces_uniben/features/auth/providers/auth_provider.dart';
import 'package:aces_uniben/features/home/explore/mhs_list.dart';
import 'package:aces_uniben/features/home/explore/mhs_tools.dart';
import 'package:aces_uniben/features/learn/page.dart';
import 'package:aces_uniben/features/notifications/notification_service.dart';
import 'package:aces_uniben/features/onboarding/onboarding_screen.dart';
import 'package:aces_uniben/features/onboarding/splash_screen.dart';
import 'package:aces_uniben/features/profile/scheduler/reminder_provider.dart';
import 'package:aces_uniben/features/tools/journal/providers/journal_provider.dart';
import 'package:aces_uniben/features/tools/journal/view_journal_list_screen.dart';
import 'package:aces_uniben/features/tools/timetable/providers/timetable_provider.dart';
import 'package:aces_uniben/features/tools/timetable/view_timetable_screen.dart';
import 'package:aces_uniben/features/tools/todo/providers/todo_providers.dart';
import 'package:aces_uniben/features/tools/todo/services/todo_db_helper.dart';
import 'package:aces_uniben/features/tools/todo/view_todo_screen.dart';
import 'package:aces_uniben/features/updates/providers/updates_provider.dart';
import 'package:aces_uniben/features/updates/widgets/mhs_articles_page.dart';
import 'package:aces_uniben/providers/onboarding_provider.dart';
import 'package:aces_uniben/providers/theme_provider.dart';
import 'package:aces_uniben/services/api_services.dart';
import 'package:aces_uniben/services/naviagtor_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  ApiService.wakeUpServer();


  final notificationService = NotificationService();
  final navigationService = NavigationService();

    // Initialize notifications and get launch details
  final launchDetails = await notificationService.initialize(
    onNotificationTap: (payload) {
      print('Notification tapped with payload: $payload');
      _handleNotificationNavigation(payload);
    },
  );

  // Handle cold start (app launched from notification)
  if (launchDetails?.didNotificationLaunchApp ?? false) {
    final payload = launchDetails?.notificationResponse?.payload;
    print('App launched from notification with payload: $payload');
    
    // Add a small delay to ensure navigation context is ready
    Future.delayed(const Duration(milliseconds: 500), () {
      _handleNotificationNavigation(payload);
    });
  }


  await TodoDBHelper.db;
  await TodoDBHelper.rescheduleAllNotifications();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => OnboardingProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => UpdatesProvider()),
        ChangeNotifierProvider(create: (_) => TodoProvider()),
        ChangeNotifierProvider(create: (_) => JournalProvider()),
        ChangeNotifierProvider(create: (_) => TimeTableProvider()),
        ChangeNotifierProvider(create: (_) => ReminderProvider()),
        ChangeNotifierProvider(create: (_) => SleepTrackerProvider(),),
        ChangeNotifierProvider(create: (_) => MoodTrackerProvider(),),
        
        
      ],
      child: ACESApp(navigationService: navigationService),
    ),
  );
}

class ACESApp extends StatelessWidget {
  final NavigationService navigationService;

  const ACESApp({super.key, required this.navigationService});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
        minTextAdapt: true,
        designSize: const Size(375, 812),
        builder: (context, builder) {
          return Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return MaterialApp(
                title: 'ACES Uniben',
                theme: AppTheme.lightTheme,
                debugShowCheckedModeBanner: false,
                navigatorKey: navigationService.navigatorKey, // Add this line
                initialRoute: '/',
                routes: {
                  '/': (context) => const RootScreen(),
                  '/todo': (context) => const TodoDisplayPage(),
                  '/timetable': (context) =>  TimeTableScreen(),
                  '/learn': (context) => const TechLearningPage(isSoftware: true,),
                  '/learn2': (context) => const TechLearningPage(isSoftware: false,),
                  '/journal': (context) => const JournalListPage(),
                  '/mhs': (context)=>  MentalHealthToolsScreen(),
                  '/mood': (context)=> MoodTrackerPage(),
                  '/sleep': (context)=> SleepTrackerPage(),
                  '/mhs2': (context)=> MHSArticlesPage(provider: Provider.of<UpdatesProvider>(context))
                },
              );
            },
          );
        });
  }
}

class RootScreen extends StatelessWidget {
  const RootScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final onboardingProvider = Provider.of<OnboardingProvider>(context);
    if (onboardingProvider.isOnboarded) {
      return const SplashScreen();
    } else {
      return const OnboardingScreen();
    }
  }
}
void _handleNotificationNavigation(String? payload) {
  final navigationService = NavigationService();
  final logger = Logger();

  logger.i('Notification payload received: $payload');

  if (payload != null && payload.isNotEmpty) {
    try {
      final routeData = _parsePayload(payload);
      logger.i('Parsed notification payload: $routeData');

      // Check if we're already on the target screen to avoid duplicate navigation
      final currentRoute = navigationService.getCurrentRoute();
      final targetRoute = '/${routeData['type']}';
      
      if (currentRoute == targetRoute) {
        logger.i('Already on target route: $targetRoute');
        return;
      }

      // Add a small delay to ensure navigation context is ready
      Future.delayed(const Duration(milliseconds: 300), () {
        switch (routeData['type']) {
          case 'todo':
            navigationService.navigateTo(
              '/todo',
              arguments: routeData,
            );
            break;
          case 'learn':
            navigationService.navigateTo(
              '/learn',
              arguments: routeData,
            );
            break;
          case 'timetable':
            navigationService.navigateTo(
              '/timetable',
              arguments: routeData,
            );
            break;
          case 'journal':
            navigationService.navigateTo(
              '/journal',
              arguments: routeData,
            );
            break;
          default:
            navigationService.navigateTo('/');
        }
      });
    } catch (e, stackTrace) {
      logger.e('Error parsing notification payload', 
               error: e, 
               stackTrace: stackTrace);
      navigationService.navigateTo('/');
    }
  } else {
    logger.w('Notification payload is null or empty');
    navigationService.navigateTo('/');
  }
}

Map<String, dynamic> _parsePayload(String payload) {
  try {
    return jsonDecode(payload) as Map<String, dynamic>;
  } catch (e) {
    // Fallback for malformed JSON or simple string payloads
    return {'type': payload.isNotEmpty ? payload : 'unknown'};
  }
}