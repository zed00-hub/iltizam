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

    // Depth bonus: tags attached
    if (record.selectedTags.isNotEmpty) {
      xp += 10 * record.selectedTags.length;
    }

    // Duration bonus: focus sessions >= 25 mins
    if (habit.type == HabitType.duration &&
        (record.durationMinutes ?? 0) >= 25) {
      xp += 25;
    }

    return xp;
  }

  /// Calculates total user XP across all completed records
  static int calculateTotalXp({
    required List<Habit> habits,
    required List<HabitRecord> records,
  }) {
    if (habits.isEmpty || records.isEmpty) return 0;

    final habitMap = {for (var h in habits) h.id: h};
    int totalXp = 0;

    for (final rec in records) {
      if (rec.isCompleted) {
        final habit = habitMap[rec.habitId];
        if (habit != null) {
          totalXp += calculateRecordXp(
            habit: habit,
            record: rec,
            currentStreak: 1,
          );
        }
      }
    }

    return totalXp;
  }

  /// Evaluates badges unlocked by the user - 100% agnostic to habit names!
  static List<AchievementBadge> evaluateBadges({
    required List<Habit> habits,
    required List<HabitRecord> records,
    required int maxStreakAcrossHabits,
  }) {
    final completedRecords = records.where((r) => r.isCompleted).toList();
    final completedCount = completedRecords.length;

    // Early morning completions count (before 8:00 AM)
    final earlyCount = completedRecords
        .where((r) => r.completedAt != null && r.completedAt!.hour < 8)
        .length;

    // Total focus minutes
    int totalFocusMinutes = 0;
    for (final r in completedRecords) {
      if (r.durationMinutes != null && r.durationMinutes! > 0) {
        totalFocusMinutes += r.durationMinutes!;
      }
    }

    return [
      AchievementBadge(
        id: 'first_step',
        titleArabic: 'شرارة الانطلاق',
        descriptionArabic: 'تسجيل أول إنجاز فعلي في رحلتك',
        icon: Icons.flag_outlined,
        color: AppColors.emerald,
        isUnlocked: completedCount >= 1,
        progress: (completedCount / 1).clamp(0.0, 1.0),
      ),
      AchievementBadge(
        id: 'streak_3',
        titleArabic: 'ثلاثية الثبات',
        descriptionArabic: 'بناء سلسلة متصلة لـ 3 أيام متتالية',
        icon: Icons.bolt,
        color: AppColors.cyan,
        isUnlocked: maxStreakAcrossHabits >= 3,
        progress: (maxStreakAcrossHabits / 3).clamp(0.0, 1.0),
      ),
      AchievementBadge(
        id: 'streak_7',
        titleArabic: 'أسبوع الفولاذ',
        descriptionArabic: 'الاستمرار في سلسلة التزام لمدة 7 أيام متتالية',
        icon: Icons.local_fire_department_outlined,
        color: AppColors.gold,
        isUnlocked: maxStreakAcrossHabits >= 7,
        progress: (maxStreakAcrossHabits / 7).clamp(0.0, 1.0),
      ),
      AchievementBadge(
        id: 'early_bird',
        titleArabic: 'طائر الصباح',
        descriptionArabic: 'تسجيل 5 إنجازات مبكرة قبل الساعة 8 صباحاً',
        icon: Icons.wb_sunny_outlined,
        color: AppColors.goldLight,
        isUnlocked: earlyCount >= 5,
        progress: (earlyCount / 5).clamp(0.0, 1.0),
      ),
      AchievementBadge(
        id: 'streak_30',
        titleArabic: 'صلابة الشهر',
        descriptionArabic: 'إتمام 30 يوماً متصلة من الانضباط الصارم',
        icon: Icons.shield_rounded,
        color: AppColors.purple,
        isUnlocked: maxStreakAcrossHabits >= 30,
        progress: (maxStreakAcrossHabits / 30).clamp(0.0, 1.0),
      ),
      AchievementBadge(
        id: 'focus_master',
        titleArabic: 'سيد التركيز',
        descriptionArabic: 'قضاء أكثر من 300 دقيقة (5 ساعات) في مؤقت التركيز',
        icon: Icons.timer_outlined,
        color: AppColors.blue,
        isUnlocked: totalFocusMinutes >= 300,
        progress: (totalFocusMinutes / 300).clamp(0.0, 1.0),
      ),
      AchievementBadge(
        id: 'century_records',
        titleArabic: 'نادي المئة إنجاز',
        descriptionArabic: 'تسجيل 100 إنجاز فعلي في مختلف عاداتك',
        icon: Icons.workspace_premium_outlined,
        color: AppColors.gold,
        isUnlocked: completedCount >= 100,
        progress: (completedCount / 100).clamp(0.0, 1.0),
      ),
      AchievementBadge(
        id: 'streak_100',
        titleArabic: 'دبابة المئة يوم 🏆',
        descriptionArabic: 'تحطيم حاجز الـ 100 يوم من العزيمة التي لا تُقهر',
        icon: Icons.military_tech_rounded,
        color: AppColors.goldLight,
        isUnlocked: maxStreakAcrossHabits >= 100,
        progress: (maxStreakAcrossHabits / 100).clamp(0.0, 1.0),
      ),
    ];
  }
}
