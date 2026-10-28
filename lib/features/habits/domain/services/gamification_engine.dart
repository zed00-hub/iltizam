import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../models/habit.dart';
import '../models/habit_record.dart';
import '../models/habit_type.dart';

class AchievementBadge {
  final String id;
  final String titleArabic;
  final String descriptionArabic;
  final IconData icon;
  final Color color;
  final bool isUnlocked;
  final double progress; // 0.0 to 1.0

  const AchievementBadge({
    required this.id,
    required this.titleArabic,
    required this.descriptionArabic,
    required this.icon,
    required this.color,
    required this.isUnlocked,
    required this.progress,
  });
}

class GamificationEngine {
  /// Calculate XP for a single record completion
  static int calculateRecordXp({
    required Habit habit,
    required HabitRecord record,
    required int currentStreak,
  }) {
    if (!record.isCompleted) return 0;

    int xp = 50; // Base completion XP

    // Streak multiplier bonus
    if (currentStreak >= 100) {
      xp += 50;
    } else if (currentStreak >= 30) {
      xp += 30;
    } else if (currentStreak >= 7) {
      xp += 15;
    }

    // Time bonus: early morning completion (before 8 AM)
    if (record.completedAt != null && record.completedAt!.hour < 8) {
      xp += 25;
    }

    // Tags bonus (depth of commitment)
    if (record.selectedTags.isNotEmpty) {
      xp += 10 * record.selectedTags.length;
    }

    // Duration bonus
    if (habit.type == HabitType.duration &&
        (record.durationMinutes ?? 0) >= 30) {
      xp += 25;
    }

    return xp;
  }

  /// Calculates total user XP across all completed records
  static int calculateTotalXp({
    required List<Habit> habits,
    required List<HabitRecord> records,
  }) {
    final habitMap = {for (var h in habits) h.id: h};
    int totalXp = 0;

    for (final rec in records) {
      if (rec.isCompleted) {
        final habit = habitMap[rec.habitId];
        if (habit != null) {
          totalXp += calculateRecordXp(
            habit: habit,
            record: rec,
            currentStreak: 1, // Base calc
          );
        }
      }
    }

    return totalXp;
  }

  /// Evaluates badges unlocked by the user
  static List<AchievementBadge> evaluateBadges({
    required List<Habit> habits,
    required List<HabitRecord> records,
    required int maxStreakAcrossHabits,
  }) {
    final completedCount = records.where((r) => r.isCompleted).length;

    // Count mosque prayers
    int mosqueCount = 0;
    for (var r in records) {
      if (r.isCompleted &&
          r.selectedTags.any((t) => t.contains('مسجد') || t.contains('المسجد'))) {
        mosqueCount++;
      }
    }

    return [
      AchievementBadge(
        id: 'streak_7',
        titleArabic: 'شرارة الانطلاق',
        descriptionArabic: 'الوصول إلى سلسلة التزام 7 أيام متتالية',
        icon: Icons.local_fire_department_outlined,
        color: AppColors.gold,
        isUnlocked: maxStreakAcrossHabits >= 7,
        progress: (maxStreakAcrossHabits / 7).clamp(0.0, 1.0),
      ),
      AchievementBadge(
        id: 'streak_30',
        titleArabic: 'صلابة المقاتل',
        descriptionArabic: 'إتمام 30 يوماً من الالتزام المتصل',
        icon: Icons.shield,
        color: AppColors.cyan,
        isUnlocked: maxStreakAcrossHabits >= 30,
        progress: (maxStreakAcrossHabits / 30).clamp(0.0, 1.0),
      ),
      AchievementBadge(
        id: 'streak_100',
        titleArabic: 'دبابة المئة يوم',
        descriptionArabic: 'تحقيق سلسلة تاريخية تفوق 100 يوم من العزيمة',
        icon: Icons.military_tech,
        color: AppColors.goldLight,
        isUnlocked: maxStreakAcrossHabits >= 100,
        progress: (maxStreakAcrossHabits / 100).clamp(0.0, 1.0),
      ),
      AchievementBadge(
        id: 'fajr_mosque',
        titleArabic: 'فارس الفجر',
        descriptionArabic: 'إتمام صلاة الفجر في المسجد 10 مرات',
        icon: Icons.mosque_outlined,
        color: AppColors.emerald,
        isUnlocked: mosqueCount >= 10,
        progress: (mosqueCount / 10).clamp(0.0, 1.0),
      ),
      AchievementBadge(
        id: 'century_records',
        titleArabic: 'رصيد الفولاذ',
        descriptionArabic: 'تسجيل 100 إنجاز فعلي في مختلف العادات',
        icon: Icons.workspace_premium,
        color: AppColors.purple,
        isUnlocked: completedCount >= 100,
        progress: (completedCount / 100).clamp(0.0, 1.0),
      ),
    ];
  }
}
