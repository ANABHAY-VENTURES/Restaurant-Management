// Anabhay Ventures — Restaurant Management
// Premium Design System: Colour Palette

import 'package:flutter/material.dart';

/// Official premium colour palette for the Restaurant Management platform.
/// Avoid neon, cheap gradients, or clashing colours.
class AppColors {
  AppColors._();

  // ─── Brand Primaries ────────────────────────────────────
  static const Color matteBlack    = Color(0xFF171717);
  static const Color deepCharcoal  = Color(0xFF242321);
  static const Color champagneGold = Color(0xFFB88746);
  static const Color warmIvory     = Color(0xFFF3EBDD);
  static const Color copper        = Color(0xFFA45D35);
  static const Color mutedGrey     = Color(0xFF88847C);

  // ─── Semantic ───────────────────────────────────────────
  static const Color successGreen  = Color(0xFF39734D);
  static const Color warningAmber  = Color(0xFFC58B38);
  static const Color errorRed      = Color(0xFFB94B42);
  static const Color infoBlue      = Color(0xFF4A7C9B);

  // ─── Surface / Background ──────────────────────────────
  static const Color surfaceDark      = Color(0xFF1C1C1A);
  static const Color surfaceCard      = Color(0xFF1F1F1D);
  static const Color surfaceElevated  = Color(0xFF2A2A27);
  static const Color surfaceLight     = Color(0xFFF9F6F1);
  static const Color surfaceWhite     = Color(0xFFFFFFFF);

  // ─── Text ──────────────────────────────────────────────
  static const Color textPrimary    = Color(0xFFF3EBDD);
  static const Color textSecondary  = Color(0xFFB0ACA5);
  static const Color textTertiary   = Color(0xFF706D66);
  static const Color textOnLight    = Color(0xFF171717);
  static const Color textOnGold     = Color(0xFF171717);

  // ─── Borders ───────────────────────────────────────────
  static const Color borderSubtle   = Color(0xFF2E2E2B);
  static const Color borderMedium   = Color(0xFF3D3D39);
  static const Color borderLight    = Color(0xFFE0DCD5);

  // ─── Chart Palette ─────────────────────────────────────
  static const List<Color> chartPalette = [
    champagneGold,
    copper,
    successGreen,
    infoBlue,
    warningAmber,
    mutedGrey,
  ];
}

