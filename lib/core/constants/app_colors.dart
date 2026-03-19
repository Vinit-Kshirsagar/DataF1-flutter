import 'package:flutter/material.dart';

/// DataF1 color system — source of truth for all colors.
/// Never use hardcoded hex values anywhere else in the codebase.
/// Reference: UI_SPEC.md — Color System section.
abstract final class AppColors {
  // ── Backgrounds ────────────────────────────────────────────────
  static const background = Color(0xFF0F0F0F); // deepest bg, main scaffold
  static const surface = Color(0xFF1A1A1A); // cards, bottom sheets
  static const surfaceRaised = Color(0xFF23100F); // warm dark — hero sections

  // ── Brand ──────────────────────────────────────────────────────
  static const primary = Color(0xFFFF1500); // F1 red — THE accent
  static const primaryDim = Color(0x26FF1500); // primary at 15% opacity
  static const primaryBorder = Color(0x33FF1500); // primary at 20% — card borders

  // ── Text ───────────────────────────────────────────────────────
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFF888888);
  static const textMuted = Color(0xFF4A4A4A);

  // ── Semantic ───────────────────────────────────────────────────
  static const success = Color(0xFF39FF14); // lap delta improvements
  static const warning = Color(0xFFFF8C00); // P3 podium, McLaren
  static const inactive = Color(0xFF3D3D3D); // disabled states

  // ── Borders ────────────────────────────────────────────────────
  static const cardBorder = Color(0xFF2A2A2A);

  // ── Graph line palette (6 lap colors) ──────────────────────────
  static const lapColors = [
    Color(0xFFFF1500), // red
    Color(0xFF00D4FF), // cyan
    Color(0xFF39FF14), // green
    Color(0xFFFF8C00), // orange
    Color(0xFFBF5FFF), // purple
    Color(0xFFFFD700), // gold
  ];

  // ── Team colors — 4px left border on driver list items ─────────
  static const teamRedBull = Color(0xFF3671C6);
  static const teamFerrari = Color(0xFFE8002D);
  static const teamMercedes = Color(0xFF06D2BE);
  static const teamMcLaren = Color(0xFFFF8000);
  static const teamAston = Color(0xFF358C75);
  static const teamAlpine = Color(0xFF0093CC);
  static const teamWilliams = Color(0xFF005AFF);
  static const teamAlpha = Color(0xFFC92D4B); // fallback for unknown teams

  /// Returns a team color by team name string (case-insensitive partial match).
  static Color teamColor(String? teamName) {
    if (teamName == null) return teamAlpha;
    final name = teamName.toLowerCase();
    if (name.contains('red bull')) return teamRedBull;
    if (name.contains('ferrari')) return teamFerrari;
    if (name.contains('mercedes')) return teamMercedes;
    if (name.contains('mclaren')) return teamMcLaren;
    if (name.contains('aston')) return teamAston;
    if (name.contains('alpine')) return teamAlpine;
    if (name.contains('williams')) return teamWilliams;
    return teamAlpha;
  }
}
