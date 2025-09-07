import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  
  ThemeMode _themeMode = ThemeMode.light; // Default to light mode for new users
  
  ThemeMode get themeMode => _themeMode;
  
  bool get isDarkMode {
    
    return _themeMode == ThemeMode.dark;
  }
  
  // Helper methods for getting theme-aware colors
  Color getBackgroundColor(BuildContext context) {
    return isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF4FCF5);
  }
  
  Color getCardColor(BuildContext context) {
    return isDarkMode ? const Color(0xFF1E293B) : Colors.white;
  }
  
  Color getTextColor(BuildContext context) {
    return isDarkMode ? const Color(0xFFF8FAFC) : Colors.black;
  }
  
  Color getSecondaryTextColor(BuildContext context) {
    return isDarkMode ? const Color(0xFFCBD5E1) : const Color(0xFF64748B);
  }
  
  Color getBorderColor(BuildContext context) {
    return isDarkMode ? const Color(0xFF475569) : const Color(0xFFE2E8F0);
  }
  
  Color getInputFillColor(BuildContext context) {
    return isDarkMode ? const Color(0xFF334155) : const Color(0xFFF9FAFB);
  }
  
  String get themeDisplayName {
    switch (_themeMode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }
  
  ThemeProvider() {
    _loadThemeMode();
  }
  
  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final themeModeIndex =  0; // Default to light mode (index 0)
    _themeMode = ThemeMode.values[themeModeIndex];
    notifyListeners();
  }
  
  Future<void> setThemeMode(ThemeMode themeMode) async {
    _themeMode = themeMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, themeMode.index);
    notifyListeners();
  }
  
  Future<void> toggleTheme() async {
    if (_themeMode == ThemeMode.light) {
      await setThemeMode(ThemeMode.light);
    } else {
      await setThemeMode(ThemeMode.light);
    }
  }


  void setSystemTheme() {
    _themeMode = ThemeMode.system;
    notifyListeners();
  }
}