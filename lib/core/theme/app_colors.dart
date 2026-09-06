// lib/core/theme/app_colors.dart
import 'package:flutter/material.dart';

/// Palette SkillUp — direction artistique forêt / mousse / or / sable.
abstract final class AppColors {
  static const Color forest = Color(0xFF1F3A2E);
  static const Color moss = Color(0xFF3E7C59);
  static const Color gold = Color(0xFFC9962F);
  static const Color sand = Color(0xFFEDE6D3);
  static const Color ink = Color(0xFF182620);

  /// Variantes dérivées pour surfaces et états.
  static const Color sandMuted = Color(0xFFE4DCC6);
  static const Color forestMuted = Color(0xFF2A4A3B);
  static const Color error = Color(0xFF8B3A3A);
}
