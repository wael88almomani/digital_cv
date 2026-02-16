import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';

class AppTheme {
  static ThemeData light() {
    final base = ThemeData(
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: AppColors.royalIndigo,
        secondary: AppColors.emerald,
        surface: AppColors.lightBackground,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.textPrimary,
        outline: AppColors.outline,
      ),
      useMaterial3: true,
    );

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.lightBackground,
      textTheme: GoogleFonts.interTextTheme(base.textTheme)
          .apply(
            bodyColor: AppColors.textPrimary,
            displayColor: AppColors.textPrimary,
          )
          .copyWith(
            headlineSmall: GoogleFonts.inter(fontWeight: FontWeight.w700),
            titleLarge: GoogleFonts.inter(fontWeight: FontWeight.w600),
            titleMedium: GoogleFonts.inter(fontWeight: FontWeight.w600),
            bodyLarge: GoogleFonts.inter(fontWeight: FontWeight.w500),
            bodyMedium: GoogleFonts.inter(fontWeight: FontWeight.w400),
          ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.lightBackground,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardLight,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radius),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        hintStyle: const TextStyle(color: AppColors.textSecondary),
        floatingLabelStyle: const TextStyle(color: AppColors.royalIndigo),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusSm),
          borderSide: const BorderSide(color: AppColors.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusSm),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusSm),
          borderSide: const BorderSide(
            color: AppColors.royalIndigo,
            width: 1.5,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(AppSizes.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radius),
          ),
          elevation: 0,
          backgroundColor: AppColors.royalIndigo,
          foregroundColor: Colors.white,
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(AppSizes.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radius),
          ),
          side: const BorderSide(color: AppColors.outline),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
          foregroundColor: AppColors.royalIndigo,
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: const Color(0xFFE2E8F0),
        labelStyle: GoogleFonts.inter(),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusSm),
        ),
      ),
      dividerColor: const Color(0xFFE2E8F0),
    );
  }

  static ThemeData dark() {
    final base = ThemeData(
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.royalIndigo,
        secondary: AppColors.emerald,
        surface: AppColors.darkBackground,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.textOnDark,
        outline: Color(0xFF334155),
      ),
      useMaterial3: true,
    );

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.darkBackground,
      textTheme: GoogleFonts.interTextTheme(base.textTheme)
          .apply(
            bodyColor: AppColors.textOnDark,
            displayColor: AppColors.textOnDark,
          )
          .copyWith(
            headlineSmall: GoogleFonts.inter(fontWeight: FontWeight.w700),
            titleLarge: GoogleFonts.inter(fontWeight: FontWeight.w600),
            titleMedium: GoogleFonts.inter(fontWeight: FontWeight.w600),
            bodyLarge: GoogleFonts.inter(fontWeight: FontWeight.w500),
            bodyMedium: GoogleFonts.inter(fontWeight: FontWeight.w400),
          ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkBackground,
        foregroundColor: AppColors.textOnDark,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardDark,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radius),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF111827),
        labelStyle: TextStyle(color: AppColors.textOnDark.withAlpha(204)),
        hintStyle: TextStyle(color: AppColors.textOnDark.withAlpha(204)),
        floatingLabelStyle: const TextStyle(color: AppColors.royalIndigo),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusSm),
          borderSide: const BorderSide(color: Color(0xFF334155)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusSm),
          borderSide: const BorderSide(color: Color(0xFF334155)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusSm),
          borderSide: const BorderSide(
            color: AppColors.royalIndigo,
            width: 1.5,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(AppSizes.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radius),
          ),
          elevation: 0,
          backgroundColor: AppColors.royalIndigo,
          foregroundColor: Colors.white,
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(AppSizes.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radius),
          ),
          side: const BorderSide(color: Color(0xFF334155)),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
          foregroundColor: AppColors.emerald,
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: const Color(0xFF1F2937),
        labelStyle: GoogleFonts.inter(color: AppColors.textOnDark),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusSm),
        ),
      ),
      dividerColor: const Color(0xFF1F2937),
    );
  }
}
