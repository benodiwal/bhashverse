import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import '../constants/app_constants.dart';
import 'app_theme.dart';
import 'app_theme_utils.dart';

class AppThemeProvider with ChangeNotifier {
  Box hiveDBInstance = Hive.box(hiveDBName);

  ThemeMode _themeMode = ThemeMode.system;
  static const _lightTheme = LightAppTheme();
  static const _darkTheme = DarkAppTheme();
  AppTheme? _appTheme;

  ThemeMode get appThemeMode => _themeMode;

  bool get isDarkMode {
    switch (_themeMode) {
      case ThemeMode.light:
        return false;
      case ThemeMode.dark:
        return true;
      case ThemeMode.system:
        return _isSystemInDarkMode;
    }
  }

  bool get _isSystemInDarkMode =>
      WidgetsBinding.instance.platformDispatcher.platformBrightness ==
      Brightness.dark;

  AppTheme get theme =>
      _appTheme ?? (_isSystemInDarkMode ? _darkTheme : _lightTheme);

  void loadUserPreferredTheme() {
    final userPreference = hiveDBInstance.get(preferredAppTheme);
    if (userPreference != null) {
      switch (userPreference) {
        case lightModeTheme:
          _themeMode = ThemeMode.light;
          break;
        case darkModeTheme:
          _themeMode = ThemeMode.dark;
          break;
        default:
          _themeMode = ThemeMode.system;
          break;
      }

      _appTheme = appThemeForMode(_themeMode);
      notifyListeners();
    }
  }

  void setAppTheme(ThemeMode themeMode, {bool storeToPreference = true}) {
    final String userPreference;
    switch (themeMode) {
      case ThemeMode.light:
        userPreference = lightModeTheme;
        break;
      case ThemeMode.dark:
        userPreference = darkModeTheme;
        break;
      case ThemeMode.system:
        userPreference = systemTheme;
        break;
    }

    if (storeToPreference) {
      hiveDBInstance.put(preferredAppTheme, userPreference);
    }

    _themeMode = themeMode;
    _appTheme = appThemeForMode(themeMode);
    notifyListeners();
  }

  /// Get AppTheme from ThemeMode
  AppTheme appThemeForMode(ThemeMode mode) {
    final AppTheme theme;
    switch (mode) {
      case ThemeMode.system:
        theme = _isSystemInDarkMode ? _darkTheme : _lightTheme;
        break;
      case ThemeMode.light:
        theme = _lightTheme;
        break;
      case ThemeMode.dark:
        theme = _darkTheme;
        break;
    }
    return theme;
  }
}

extension BuildContextEx on BuildContext {
  ThemeMode get appThemeMode =>
      Provider.of<AppThemeProvider>(this, listen: true)._themeMode;
  AppTheme get appTheme => Provider.of<AppThemeProvider>(this).theme;
  bool get isDarkMode => Provider.of<AppThemeProvider>(this).isDarkMode;
  AppTheme get lightAppTheme =>
      Provider.of<AppThemeProvider>(this).appThemeForMode(ThemeMode.light);
  AppTheme get darkAppTheme =>
      Provider.of<AppThemeProvider>(this).appThemeForMode(ThemeMode.dark);
}
