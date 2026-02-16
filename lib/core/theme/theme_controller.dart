import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_strings.dart';

class ThemeController extends ChangeNotifier {
  ThemeController(this._prefs);

  final SharedPreferences _prefs;

  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  Future<void> load() async {
    final stored = _prefs.getString('theme_mode') ?? AppStrings.themeSystem;
    _themeMode = _parseThemeMode(stored);
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    _prefs.setString('theme_mode', _themeModeKey(mode));
    notifyListeners();
  }

  void toggle() {
    if (_themeMode == ThemeMode.dark) {
      setThemeMode(ThemeMode.light);
    } else {
      setThemeMode(ThemeMode.dark);
    }
  }

  ThemeMode _parseThemeMode(String value) {
    switch (value) {
      case AppStrings.themeLight:
        return ThemeMode.light;
      case AppStrings.themeDark:
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  String _themeModeKey(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return AppStrings.themeLight;
      case ThemeMode.dark:
        return AppStrings.themeDark;
      case ThemeMode.system:
        return AppStrings.themeSystem;
    }
  }
}
