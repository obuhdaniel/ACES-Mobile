// navigation_service.dart
import 'package:flutter/material.dart';
class NavigationService {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  
  Future<dynamic> navigateTo(String routeName, {dynamic arguments}) {
    return navigatorKey.currentState!.pushNamed(routeName, arguments: arguments);
  }
  
  void goBack() {
    navigatorKey.currentState!.pop();
  }

    String? getCurrentRoute() {
    final route = navigatorKey.currentState?.widget.onGenerateRoute;
    if (route != null) {
      final settings = navigatorKey.currentState?.widget.pages.last;
      return settings?.name;
    }
    return null;
  }
}