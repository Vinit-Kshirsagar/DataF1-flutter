import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

abstract final class AppTheme {
  static ThemeData get darkTheme => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        primaryColor: AppColors.primary,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primary,
          surface: AppColors.surface,
          onPrimary: Colors.white,
          onSurface: AppColors.textPrimary,
        ),
        splashColor: AppColors.primaryDim,
        highlightColor: Colors.transparent,
        // ── App Bar ──────────────────────────────────────────────
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.background,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
          titleTextStyle: GoogleFonts.barlowCondensed(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            fontStyle: FontStyle.italic,
            color: Colors.white,
          ),
          iconTheme: const IconThemeData(color: AppColors.textPrimary),
        ),
        // ── Bottom Nav ───────────────────────────────────────────
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.background,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textSecondary,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
        ),
        // ── Dividers ─────────────────────────────────────────────
        dividerColor: AppColors.primaryBorder,
        dividerTheme: const DividerThemeData(
          color: AppColors.primaryBorder,
          thickness: 1,
        ),
        // ── Text Theme ───────────────────────────────────────────
        textTheme: TextTheme(
          // Headlines
          headlineLarge: GoogleFonts.barlowCondensed(
            fontWeight: FontWeight.w800,
            fontStyle: FontStyle.italic,
            fontSize: 28,
            letterSpacing: -0.5,
            color: AppColors.textPrimary,
          ),
          headlineMedium: GoogleFonts.barlowCondensed(
            fontWeight: FontWeight.w700,
            fontStyle: FontStyle.italic,
            fontSize: 22,
            letterSpacing: -0.3,
            color: AppColors.textPrimary,
          ),
          headlineSmall: GoogleFonts.barlow(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: AppColors.textPrimary,
          ),
          // Body
          bodyLarge: GoogleFonts.barlow(
            fontWeight: FontWeight.w500,
            fontSize: 15,
            color: AppColors.textPrimary,
          ),
          bodyMedium: GoogleFonts.barlow(
            fontWeight: FontWeight.w400,
            fontSize: 13,
            color: AppColors.textPrimary,
          ),
          bodySmall: GoogleFonts.barlow(
            fontWeight: FontWeight.w400,
            fontSize: 11,
            color: AppColors.textSecondary,
          ),
          // Labels
          labelLarge: GoogleFonts.barlow(
            fontWeight: FontWeight.w700,
            fontSize: 11,
            letterSpacing: 1.5,
            color: AppColors.textSecondary,
          ),
          labelMedium: GoogleFonts.barlow(
            fontWeight: FontWeight.w600,
            fontSize: 10,
            letterSpacing: 1.2,
            color: AppColors.textSecondary,
          ),
          labelSmall: GoogleFonts.barlow(
            fontWeight: FontWeight.w500,
            fontSize: 9,
            letterSpacing: 1.0,
            color: AppColors.textSecondary,
          ),
        ),
        // ── Input Decoration ─────────────────────────────────────
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.primaryDim,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.primaryBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.primaryBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          hintStyle: GoogleFonts.barlow(
            color: AppColors.textMuted,
            fontSize: 15,
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      );
}
