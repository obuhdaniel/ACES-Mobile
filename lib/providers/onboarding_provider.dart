import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingProvider with ChangeNotifier {
  bool _isOnboarded = false;

  static const String _techLearningKey = 'tech_learning_first_time';

  bool _isFirstTime = false;

  bool get isOnboarded => _isOnboarded;
  bool get isFirstTime => _isFirstTime;

  OnboardingProvider() {
    checkOnboardingStatus();
  }

  Future<void> checkOnboardingStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _isOnboarded = prefs.getBool('is_onboarded') ?? false;
    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_onboarded', true);
    _isOnboarded = true;
    notifyListeners();
  }

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _isFirstTime = prefs.getBool(_techLearningKey) ?? true;
    notifyListeners();
  }

  Future<void> setFirstTimeCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_techLearningKey, false);
    _isFirstTime = false;
    notifyListeners();
  }

  Future<void> resetFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_techLearningKey);
    _isFirstTime = true;
    notifyListeners();
  }
}
