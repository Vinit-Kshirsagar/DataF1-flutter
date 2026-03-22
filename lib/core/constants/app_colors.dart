import 'package:flutter/material.dart';

/// DataF1 color system — source of truth for all colors.
/// Never use hardcoded hex values anywhere else in the codebase.
abstract final class AppColors {
  // ── Backgrounds ────────────────────────────────────────────────
  static const background    = Color(0xFF0F0F0F);
  static const surface       = Color(0xFF1A1A1A);
  static const surfaceRaised = Color(0xFF23100F);

  // ── Brand ──────────────────────────────────────────────────────
  static const primary       = Color(0xFFFF1500);
  static const primaryDim    = Color(0x26FF1500);
  static const primaryBorder = Color(0x33FF1500);

  // ── Text ───────────────────────────────────────────────────────
  static const textPrimary   = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFF888888);
  static const textMuted     = Color(0xFF4A4A4A);

  // ── Semantic ───────────────────────────────────────────────────
  static const success  = Color(0xFF39FF14);
  static const warning  = Color(0xFFFF8C00);
  static const inactive = Color(0xFF3D3D3D);

  // ── Borders ────────────────────────────────────────────────────
  static const cardBorder = Color(0xFF2A2A2A);

  // ── Graph line palette ──────────────────────────────────────────
  static const lapColors = [
    Color(0xFFFF1500),
    Color(0xFF00D4FF),
    Color(0xFF39FF14),
    Color(0xFFFF8C00),
    Color(0xFFBF5FFF),
    Color(0xFFFFD700),
  ];

  // ── Team colors — full 2026 grid ──────────────────────────────
  static const teamRedBull   = Color(0xFF3671C6);
  static const teamFerrari   = Color(0xFFE8002D);
  static const teamMercedes  = Color(0xFF06D2BE);
  static const teamMcLaren   = Color(0xFFFF8000);
  static const teamAston     = Color(0xFF358C75);
  static const teamAlpine    = Color(0xFF0093CC);
  static const teamWilliams  = Color(0xFF005AFF);
  static const teamHaas      = Color(0xFFB6BABD);
  static const teamSauber    = Color(0xFF52E252); // Audi / Kick Sauber
  static const teamRB        = Color(0xFF6692FF); // Racing Bulls (VCARB)
  static const teamAlpha     = Color(0xFFC92D4B); // fallback

  static Color teamColor(String? teamName) {
    if (teamName == null) return teamAlpha;
    final n = teamName.toLowerCase();
    if (n.contains('red bull'))                    return teamRedBull;
    if (n.contains('ferrari'))                     return teamFerrari;
    if (n.contains('mercedes'))                    return teamMercedes;
    if (n.contains('mclaren'))                     return teamMcLaren;
    if (n.contains('aston'))                       return teamAston;
    if (n.contains('alpine'))                      return teamAlpine;
    if (n.contains('williams'))                    return teamWilliams;
    if (n.contains('haas'))                        return teamHaas;
    if (n.contains('sauber') || n.contains('audi')) return teamSauber;
    if (n.contains('racing bulls') || n.contains('rb') || n.contains('vcarb')) return teamRB;
    return teamAlpha;
  }
}
