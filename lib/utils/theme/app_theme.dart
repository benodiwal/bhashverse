library app_theme;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

part 'app_colors.dart';
part 'app_theme_interface.dart';
part 'dark_app_theme.dart';
part 'light_app_theme.dart';

ThemeData lightMaterialThemeData() {
  const background = _AppColors.whiteLilac;
  return ThemeData(
    textTheme: GoogleFonts.latoTextTheme(),
    primaryColor: _AppColors.primaryColor,
    colorScheme: const ColorScheme.light(
      primary: _AppColors.primaryColor,
    ),
    appBarTheme: const AppBarTheme(
      color: background,
      iconTheme: IconThemeData(
        color: _AppColors.primaryColor,
      ),
    ),
    popupMenuTheme: const PopupMenuThemeData(
      color: _AppColors.white,
      textStyle: TextStyle(
        color: _AppColors.arsenicColor,
        fontSize: 16.0,
        fontWeight: FontWeight.w400,
      ),
    ),
  );
}

ThemeData darkMaterialThemeData() {
  const background = _AppColors.jaguarBlack;
  return ThemeData(
    textTheme: GoogleFonts.latoTextTheme(),
    primaryColor: _AppColors.primaryDarkColor,
    colorScheme: const ColorScheme.dark(
      primary: _AppColors.primaryDarkColor,
    ),
    appBarTheme: const AppBarTheme(
      color: background,
      iconTheme: IconThemeData(
        color: _AppColors.primaryDarkColor,
      ),
    ),
    popupMenuTheme: const PopupMenuThemeData(
      color: _AppColors.jaguarBlue,
      textStyle: TextStyle(
        color: _AppColors.mischkaGrey,
        fontSize: 16.0,
        fontWeight: FontWeight.w400,
      ),
    ),
  );
}
