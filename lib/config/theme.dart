import 'package:flutter/material.dart';

// ─── COULEURS WAJBA ───────────────────────────────────────────────
class WajbaColors {
  static const primary     = Color(0xFFC62828); // Rouge principal
  static const primaryDark = Color(0xFF8E0000);
  static const primaryLight= Color(0xFFFF5F52);
  static const dark        = Color(0xFF121212); // Noir
  static const white       = Color(0xFFFFFFFF);
  static const grey100     = Color(0xFFF5F5F5);
  static const grey200     = Color(0xFFEEEEEE);
  static const grey400     = Color(0xFFBDBDBD);
  static const grey600     = Color(0xFF757575);
  static const grey800     = Color(0xFF424242);
  static const success     = Color(0xFF2E7D32);
  static const warning     = Color(0xFFF9A825);
  static const error       = Color(0xFFC62828);
  static const background  = Color(0xFFF8F8F8);
  static const cardBg      = Color(0xFFFFFFFF);
  static const shadow      = Color(0x1A000000);
}

// ─── THÈME PRINCIPAL ──────────────────────────────────────────────
class WajbaTheme {
  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    fontFamily: 'Poppins',
    colorScheme: ColorScheme.fromSeed(
      seedColor: WajbaColors.primary,
      primary: WajbaColors.primary,
      secondary: WajbaColors.primaryLight,
      background: WajbaColors.background,
      surface: WajbaColors.cardBg,
      error: WajbaColors.error,
    )),
    scaffoldBackgroundColor: WajbaColors.background,
    appBarTheme: const AppBarTheme(
      backgroundColor: WajbaColors.white,
      foregroundColor: WajbaColors.dark,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontFamily: 'Poppins',
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: WajbaColors.dark,
      )),
    )),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: WajbaColors.primary,
        foregroundColor: WajbaColors.white,
        minimumSize: const Size(double.infinity, 52)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(14))),
        textStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 16,
          fontWeight: FontWeight.w600,
        )),
      )),
    )),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: WajbaColors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(14)),
        borderSide: const BorderSide(color: WajbaColors.grey200)),
      )),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(14)),
        borderSide: const BorderSide(color: WajbaColors.grey200)),
      )),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(14)),
        borderSide: const BorderSide(color: WajbaColors.primary, width: 2)),
      )),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16)),
    )),
    cardTheme: const CardThemeData(
      color: WajbaColors.cardBg,
      elevation: 2,
      shadowColor: WajbaColors.shadow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
    )),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: WajbaColors.white,
      selectedItemColor: WajbaColors.primary,
      unselectedItemColor: WajbaColors.grey400,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
    )),
  );
}

// ─── CONSTANTES ───────────────────────────────────────────────────
class WajbaStrings {
  static const appName     = 'Wajba';
  static const tagline     = 'Livraison rapide en Algérie 🍽️';
  static const currency    = 'DA';
  static const phonePrefix = '+213';
}

class WajbaAssets {
  static const logo        = 'assets/images/logo.png';
  static const placeholder = 'assets/images/placeholder.png';
  static const emptyCart   = 'assets/images/empty_cart.png';
  static const emptyOrders = 'assets/images/empty_orders.png';
  static const onboarding1 = 'assets/images/onboarding1.png';
  static const onboarding2 = 'assets/images/onboarding2.png';
  static const onboarding3 = 'assets/images/onboarding3.png';
}

// Padding standards
const double kPaddingS  = 8.0;
const double kPaddingM  = 16.0;
const double kPaddingL  = 24.0;
const double kPaddingXL = 32.0;
const double kRadiusS   = 8.0;
const double kRadiusM   = 14.0;
const double kRadiusL   = 20.0;
