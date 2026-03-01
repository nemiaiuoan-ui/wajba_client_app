import 'package:flutter/material.dart';
import 'colors.dart';

final ThemeData appTheme = ThemeData(
  useMaterial3: true,

  scaffoldBackgroundColor: WajbaColors.background,

  appBarTheme: const AppBarTheme(
    backgroundColor: WajbaColors.white,
    foregroundColor: WajbaColors.dark,
    elevation: 0,
    centerTitle: true,
    titleTextStyle: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: WajbaColors.dark,
    ),
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: WajbaColors.primary,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 14),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(14)),
      ),
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    ),
  ),

  inputDecorationTheme: const InputDecorationTheme(
    filled: true,
    fillColor: WajbaColors.white,
    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),

    border: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(14)),
      borderSide: BorderSide(color: WajbaColors.grey200),
    ),

    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(14)),
      borderSide: BorderSide(color: WajbaColors.grey200),
    ),

    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(14)),
      borderSide: BorderSide(color: WajbaColors.primary, width: 2),
    ),
  ),

  cardTheme: const CardThemeData(
    color: WajbaColors.cardBg,
    elevation: 2,
    shadowColor: WajbaColors.shadow,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(16)),
    ),
  ),

  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: WajbaColors.white,
    selectedItemColor: WajbaColors.primary,
    unselectedItemColor: WajbaColors.grey400,
    showUnselectedLabels: true,
    type: BottomNavigationBarType.fixed,
  ),
);
