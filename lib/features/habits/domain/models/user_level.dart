import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class UserLevel {
  final int level;
  final String titleArabic;
  final String subtitleArabic;
  final int minXp;
  final int maxXp;
  final IconData icon;
  final Color badgeColor;

  const UserLevel({
    required this.level,
    required this.titleArabic,
    required this.subtitleArabic,
    required this.minXp,
    required this.maxXp,
    required this.icon,
    required this.badgeColor,
  });

  static const List<UserLevel> levels = [
    UserLevel(
      level: 1,
      titleArabic: 'مبتدئ',
      subtitleArabic: 'الخطوة الأولى في طريق الانضباط',
      minXp: 0,
      maxXp: 200,
      icon: Icons.flag_outlined,
      badgeColor: AppColors.textSecondary,
    ),
    UserLevel(
      level: 2,
      titleArabic: 'عازم',
      subtitleArabic: 'بداية تشكل الإرادة',
      minXp: 200,
      maxXp: 600,
      icon: Icons.bolt_outlined,
      badgeColor: AppColors.cyan,
    ),
    UserLevel(
      level: 3,
      titleArabic: 'منضبط',
      subtitleArabic: 'بناء العادات اليومية بثبات',
      minXp: 600,
      maxXp: 1400,
      icon: Icons.shield_outlined,
      badgeColor: AppColors.blue,
    ),
    UserLevel(
      level: 4,
      titleArabic: 'مقاتل',
      subtitleArabic: 'لا استسلام ولا تراجع',
      minXp: 1400,
      maxXp: 3000,
      icon: Icons.military_tech_outlined,
      badgeColor: AppColors.purple,
    ),
    UserLevel(
      level: 5,
      titleArabic: 'صلب',
      subtitleArabic: 'مقاومة قوية لجميع المغريات',
      minXp: 3000,
      maxXp: 6000,
      icon: Icons.diamond_outlined,
      badgeColor: AppColors.emerald,
    ),
    UserLevel(
      level: 6,
      titleArabic: 'فولاذي',
      subtitleArabic: 'الروتين اليومي أصبح قانوناً لا يُكسر',
      minXp: 6000,
      maxXp: 12000,
      icon: Icons.workspace_premium_outlined,
      badgeColor: AppColors.gold,
    ),
    UserLevel(
      level: 7,
      titleArabic: 'دبابة التزام',
      subtitleArabic: 'قوة انضباط ساحقة تتجاوز كل الظروف',
      minXp: 12000,
      maxXp: 999999,
      icon: Icons.local_fire_department,
      badgeColor: AppColors.goldLight,
    ),
  ];

  static UserLevel fromXp(int xp) {
    for (int i = levels.length - 1; i >= 0; i--) {
      if (xp >= levels[i].minXp) {
        return levels[i];
      }
    }
    return levels.first;
  }

  static double calculateProgress(int xp) {
    final current = fromXp(xp);
    if (current.level == levels.last.level) return 1.0;
    final range = current.maxXp - current.minXp;
    if (range <= 0) return 1.0;
    final earnedInLevel = xp - current.minXp;
    return (earnedInLevel / range).clamp(0.0, 1.0);
  }
}
