import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../constants/app_constants.dart';

const systemTheme = 'SYSTEM_THEME';
const lightModeTheme = 'LIGHT_THEME';
const darkModeTheme = 'DARK_THEME';

ThemeMode getUserPreferredThemeMode(Box hiveDBInstance) {
  final userPreference = hiveDBInstance.get(preferredAppTheme);
  if (userPreference != null) {
    switch (userPreference) {
      case lightModeTheme:
        return ThemeMode.light;
      case darkModeTheme:
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  } else {
    return ThemeMode.system;
  }
}

Brightness getUserPreferredBrightness(Box hiveDBInstance) {
  ThemeMode themeMode = getUserPreferredThemeMode(hiveDBInstance);
  switch (themeMode) {
    case ThemeMode.light:
      return Brightness.light;
    case ThemeMode.dark:
      return Brightness.dark;
    case ThemeMode.system:
      return WidgetsBinding.instance.platformDispatcher.platformBrightness;
  }
}
