import 'package:flutter/material.dart';

/// Single Source of Truth untuk palet warna aplikasi Kost Point.
/// Disesuaikan secara ketat dengan panduan di .agents/kostpoint.agents.md.
class AppColors {
  AppColors._();

  // 6 Warna Wajib Utama
  static const Color backgroundColor = Color(0xFFF5F8FA);
  static const Color surfaceBorderSoft = Color(0xFFE2E2EC);
  static const Color secondaryCardAccent = Color(0xFFC9CCB7);
  static const Color primaryAccent = Color(0xFF7EAAEE);
  static const Color textSecondaryMuted = Color(0xFF878788);
  static const Color textPrimary = Color(0xFF323335);

  // Variasi Utilitas Pendukung
  static const Color cardSurface = Colors.white;
  static const Color white = Colors.white;
  static const Color premiumGold = Color(0xFFE6A23C);
  static const Color danger = Color(0xFFE57373);
  static const Color success = Color(0xFF81C784);
}

