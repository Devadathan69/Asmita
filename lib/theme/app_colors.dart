import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF6B21A8);
  static const primaryLight = Color(0xFF9333EA);
  static const primaryPale = Color(0xFFF3E8FF);
  static const secondary = Color(0xFFDB2777);
  static const secondaryLight = Color(0xFFF472B6);
  static const secondaryPale = Color(0xFFFDF2F8);
  static const accent = Color(0xFFF59E0B);
  static const surface = Color(0xFFFFFFFF);
  static const success = Color(0xFF10B981);
  static const warning = Color(0xFFF59E0B);
  static const danger = Color(0xFFEF4444);
  static const textPrimary = Color(0xFF1F1035);
  static const textSecondary = Color(0xFF6B7280);
  static const textOnPurple = Color(0xFFFFFFFF);
  static const darkBackground = Color(0xFF1A0A2E);
  static const darkCard = Color(0xFF2D1B4E);
  static const darkTextSecondary = Color(0xFFA78BCA);
  static const ink = Color(0xFF100724);
  static const coral = Color(0xFFFF766E);
  static const coralPale = Color(0xFFFFE5E1);
  static const lilacMist = Color(0xFFF8F1FF);
  static const navInactive = Color(0xFF9CA3AF);
  static const menstruation = Color(0xFFDB2777);
  static const follicular = Color(0xFF9333EA);
  static const ovulation = Color(0xFFF59E0B);
  static const luteal = Color(0xFF6366F1);
}

enum CyclePhase { menstruation, follicular, ovulation, luteal }

extension CyclePhaseStyle on CyclePhase {
  Color get color => switch (this) {
        CyclePhase.menstruation => AppColors.menstruation,
        CyclePhase.follicular => AppColors.follicular,
        CyclePhase.ovulation => AppColors.ovulation,
        CyclePhase.luteal => AppColors.luteal,
      };

  String get label => switch (this) {
        CyclePhase.menstruation => 'Menstruation',
        CyclePhase.follicular => 'Follicular',
        CyclePhase.ovulation => 'Ovulation',
        CyclePhase.luteal => 'Luteal',
      };
}
