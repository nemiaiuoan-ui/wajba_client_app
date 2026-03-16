import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WajbaColors {
  // Brand
  static const primary = Color(0xFFF97316);       // Orange WAJBA
  static const primaryDark = Color(0xFFEA580C);
  static const primaryLight = Color(0xFFFED7AA);
  static const primaryBg = Color(0xFFFFF7ED);

  // Semantic
  static const success = Color(0xFF22C55E);
  static const successBg = Color(0xFFF0FDF4);
  static const error = Color(0xFFEF4444);
  static const errorBg = Color(0xFFFEF2F2);
  static const warning = Color(0xFFF59E0B);
  static const warningBg = Color(0xFFFFFBEB);
  static const info = Color(0xFF3B82F6);
  static const infoBg = Color(0xFFEFF6FF);

  // Neutrals
  static const grey50 = Color(0xFFF9FAFB);
  static const grey100 = Color(0xFFF3F4F6);
  static const grey200 = Color(0xFFE5E7EB);
  static const grey300 = Color(0xFFD1D5DB);
  static const grey400 = Color(0xFF9CA3AF);
  static const grey500 = Color(0xFF6B7280);
  static const grey600 = Color(0xFF4B5563);
  static const grey700 = Color(0xFF374151);
  static const grey800 = Color(0xFF1F2937);
  static const grey900 = Color(0xFF111827);

  // Backgrounds
  static const bg = Color(0xFFFFFFFF);
  static const bgSecondary = Color(0xFFF9FAFB);
  static const bgCard = Color(0xFFFFFFFF);

  // Special
  static const star = Color(0xFFF59E0B);
  static const shadow = Color(0x14000000);
}

class WajbaTheme {
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: WajbaColors.primary,
        primary: WajbaColors.primary,
        secondary: WajbaColors.primaryDark,
        surface: WajbaColors.bg,
        background: WajbaColors.bgSecondary,
        error: WajbaColors.error,
      ),
      scaffoldBackgroundColor: WajbaColors.bgSecondary,
      textTheme: GoogleFonts.cairoTextTheme().copyWith(
        displayLarge: GoogleFonts.cairo(fontSize: 32, fontWeight: FontWeight.w700, color: WajbaColors.grey900),
        displayMedium: GoogleFonts.cairo(fontSize: 26, fontWeight: FontWeight.w700, color: WajbaColors.grey900),
        headlineLarge: GoogleFonts.cairo(fontSize: 22, fontWeight: FontWeight.w700, color: WajbaColors.grey900),
        headlineMedium: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.w700, color: WajbaColors.grey900),
        headlineSmall: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w600, color: WajbaColors.grey900),
        titleLarge: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.w600, color: WajbaColors.grey900),
        titleMedium: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w600, color: WajbaColors.grey700),
        titleSmall: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.w500, color: WajbaColors.grey600),
        bodyLarge: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.w400, color: WajbaColors.grey800),
        bodyMedium: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w400, color: WajbaColors.grey700),
        bodySmall: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w400, color: WajbaColors.grey500),
        labelLarge: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w600, color: WajbaColors.grey900),
        labelMedium: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w500, color: WajbaColors.grey600),
        labelSmall: GoogleFonts.cairo(fontSize: 11, fontWeight: FontWeight.w500, color: WajbaColors.grey500),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: WajbaColors.bg,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        shadowColor: WajbaColors.shadow,
        centerTitle: true,
        titleTextStyle: GoogleFonts.cairo(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: WajbaColors.grey900,
        ),
        iconTheme: const IconThemeData(color: WajbaColors.grey900),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: WajbaColors.bg,
        selectedItemColor: WajbaColors.primary,
        unselectedItemColor: WajbaColors.grey400,
        elevation: 20,
        type: BottomNavigationBarType.fixed,
      ),
      cardTheme: CardTheme(
        color: WajbaColors.bgCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: WajbaColors.grey100),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: WajbaColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: WajbaColors.primary,
          side: const BorderSide(color: WajbaColors.primary),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: WajbaColors.grey50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: WajbaColors.grey200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: WajbaColors.grey200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: WajbaColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: WajbaColors.error),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: GoogleFonts.cairo(fontSize: 14, color: WajbaColors.grey400),
        labelStyle: GoogleFonts.cairo(fontSize: 14, color: WajbaColors.grey600),
      ),
      dividerTheme: const DividerThemeData(
        color: WajbaColors.grey100,
        thickness: 1,
        space: 0,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: WajbaColors.grey100,
        selectedColor: WajbaColors.primaryBg,
        labelStyle: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.w500),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
    );
  }
}
