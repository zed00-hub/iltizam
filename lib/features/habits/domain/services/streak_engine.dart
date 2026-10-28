import '../../../../core/utils/date_utils.dart';
import '../models/habit.dart';
import '../models/habit_record.dart';
import '../models/habit_type.dart';

class StreakResult {
  final int currentStreak;
  final int bestStreak;
  final int totalCompleted;
  final int totalFrozen;
  final double weeklyCompletionRate; // Last 7 days %
  final double monthlyCompletionRate; // Last 30 days %
  final bool isDueToday;
  final bool isCompletedToday;
  final bool isFrozenToday;
  final bool isCriticalDay; // Never Miss Twice: Missed previous due day!
  final int currentWeekCount; // For weekly target habits
  final int targetWeeklyCount;

  const StreakResult({
    required this.currentStreak,
    required this.bestStreak,
    required this.totalCompleted,
    required this.totalFrozen,
    required this.weeklyCompletionRate,
    required this.monthlyCompletionRate,
    required this.isDueToday,
    required this.isCompletedToday,
    required this.isFrozenToday,
    required this.isCriticalDay,
    this.currentWeekCount = 0,
    this.targetWeeklyCount = 0,
  });
}

class StreakEngine {
  /// Calculate streak metrics for a specific habit
  static StreakResult calculateStreak({
    required Habit habit,
    required List<HabitRecord> records,
    DateTime? referenceDate,
  }) {
    final now = referenceDate ?? DateTime.now();
    final today = AppDateUtils.normalize(now);
    final todayKey = AppDateUtils.toKey(today);

    // Map records by dateKey for fast O(1) lookup
    final recordMap = <String, HabitRecord>{};
    for (var r in records) {
      if (r.habitId == habit.id) {
        recordMap[r.dateKey] = r;
      }
    }

    final todayRecord = recordMap[todayKey];
    final isCompletedToday = todayRecord?.isCompleted ?? false;
    final isFrozenToday = todayRecord?.isFrozen ?? false;
    final isDueToday = habit.scheduledDays.contains(today.weekday);

    // 1. Weekly Target Habits (e.g., 4 days a week)
    if (habit.type == HabitType.weeklyTarget) {
      return _calculateWeeklyTargetStreak(
        habit: habit,
        recordMap: recordMap,
        today: today,
        isCompletedToday: isCompletedToday,
        isFrozenToday: isFrozenToday,
      );
    }

    // 2. Day-by-Day Habits (Binary, Numeric, Duration)
    int currentStreak = 0;
    int bestStreak = 0;
    int tempStreak = 0;
    int totalCompleted = 0;
    int totalFrozen = 0;

    // Check backwards from today for current streak
    DateTime cursor = today;
    bool countingCurrent = true;

    // If today is completed or frozen, count it
    if (isCompletedToday) {
      currentStreak++;
    }

    // Walk backwards for the last 365 days
    cursor = cursor.subtract(const Duration(days: 1));
    bool isCriticalDay = false;
    bool checkedYesterday = false;

    for (int i = 0; i < 365; i++) {
      final key = AppDateUtils.toKey(cursor);
      final rec = recordMap[key];
      final isDue = habit.scheduledDays.contains(cursor.weekday);

      if (isDue) {
        final completed = rec?.isCompleted ?? false;
        final frozen = rec?.isFrozen ?? false;

        if (!checkedYesterday) {
          checkedYesterday = true;
          // If previous due day was neither completed nor frozen, today is critical!
          if (!completed && !frozen) {
            isCriticalDay = true;
          }
        }

        if (countingCurrent) {
          if (completed) {
            currentStreak++;
          } else if (frozen) {
            // Freeze protects streak continuity: streak does not break, but counter doesn't increase
          } else {
            // Broken
            countingCurrent = false;
          }
        }
      }

      cursor = cursor.subtract(const Duration(days: 1));
    }

    // Calculate Best Streak across full historical records
    // Sort all records chronologically
    final sortedKeys = recordMap.keys.toList()..sort();
    tempStreak = 0;
    for (final key in sortedKeys) {
      final rec = recordMap[key]!;
      if (rec.isCompleted) {
        totalCompleted++;
        tempStreak++;
        if (tempStreak > bestStreak) {
          bestStreak = tempStreak;
        }
      } else if (rec.isFrozen) {
        totalFrozen++;
        // freeze holds streak
      } else {
        tempStreak = 0;
      }
    }
    if (currentStreak > bestStreak) {
      bestStreak = currentStreak;
    }

    // Weekly completion rate (last 7 calendar days)
    int completedLast7 = 0;
    int dueLast7 = 0;
    for (int i = 0; i < 7; i++) {
      final day = today.subtract(Duration(days: i));
      if (habit.scheduledDays.contains(day.weekday)) {
        dueLast7++;
        if (recordMap[AppDateUtils.toKey(day)]?.isCompleted ?? false) {
          completedLast7++;
        }
      }
    }
    final weeklyRate = dueLast7 > 0 ? (completedLast7 / dueLast7) * 100 : 0.0;

    // Monthly completion rate (last 30 calendar days)
    int completedLast30 = 0;
    int dueLast30 = 0;
    for (int i = 0; i < 30; i++) {
      final day = today.subtract(Duration(days: i));
      if (habit.scheduledDays.contains(day.weekday)) {
        dueLast30++;
        if (recordMap[AppDateUtils.toKey(day)]?.isCompleted ?? false) {
          completedLast30++;
        }
      }
    }
    final monthlyRate =
        dueLast30 > 0 ? (completedLast30 / dueLast30) * 100 : 0.0;

    return StreakResult(
      currentStreak: currentStreak,
      bestStreak: bestStreak,
      totalCompleted: totalCompleted,
      totalFrozen: totalFrozen,
      weeklyCompletionRate: weeklyRate,
      monthlyCompletionRate: monthlyRate,
      isDueToday: isDueToday,
      isCompletedToday: isCompletedToday,
      isFrozenToday: isFrozenToday,
      isCriticalDay: isCriticalDay,
    );
  }

  /// Specialized streak calculator for weekly frequency targets (e.g. 4 times per week)
  static StreakResult _calculateWeeklyTargetStreak({
    required Habit habit,
    required Map<String, HabitRecord> recordMap,
    required DateTime today,
    required bool isCompletedToday,
    required bool isFrozenToday,
  }) {
    final target = habit.targetWeeklyFrequency ?? 3;

    // Find start of current week (Monday)
    final mondayOffset = today.weekday - 1;
    final thisMonday = today.subtract(Duration(days: mondayOffset));

    int currentWeekCount = 0;
    for (int i = 0; i < 7; i++) {
      final day = thisMonday.add(Duration(days: i));
      if (recordMap[AppDateUtils.toKey(day)]?.isCompleted ?? false) {
        currentWeekCount++;
      }
    }

    // Count consecutive completed weeks
    int currentWeekStreak = 0;
    int bestWeekStreak = 0;
    int tempWeekStreak = 0;

    // If current week already reached target, count it
    if (currentWeekCount >= target) {
      currentWeekStreak++;
    }

    // Walk back 52 weeks
    for (int w = 1; w < 52; w++) {
      final prevMonday = thisMonday.subtract(Duration(days: 7 * w));
      int weekCount = 0;
      for (int i = 0; i < 7; i++) {
        final day = prevMonday.add(Duration(days: i));
        if (recordMap[AppDateUtils.toKey(day)]?.isCompleted ?? false) {
          weekCount++;
        }
      }

      if (weekCount >= target) {
        if (w == 1 && currentWeekCount < target) {
          // If this week is still in progress, previous completed week counts towards streak!
          currentWeekStreak++;
        } else if (currentWeekStreak > 0) {
          currentWeekStreak++;
        }
        tempWeekStreak++;
        if (tempWeekStreak > bestWeekStreak) {
          bestWeekStreak = tempWeekStreak;
        }
      } else {
        tempWeekStreak = 0;
      }
    }

    if (currentWeekStreak > bestWeekStreak) {
      bestWeekStreak = currentWeekStreak;
    }

    int totalCompleted = 0;
    for (var r in recordMap.values) {
      if (r.isCompleted) totalCompleted++;
    }

    final weeklyProgressRate =
        target > 0 ? (currentWeekCount / target).clamp(0.0, 1.0) * 100 : 0.0;

    return StreakResult(
      currentStreak: currentWeekStreak,
      bestStreak: bestWeekStreak,
      totalCompleted: totalCompleted,
      totalFrozen: 0,
      weeklyCompletionRate: weeklyProgressRate,
      monthlyCompletionRate: weeklyProgressRate,
      isDueToday: true,
      isCompletedToday: isCompletedToday,
      isFrozenToday: isFrozenToday,
      isCriticalDay: false,
      currentWeekCount: currentWeekCount,
      targetWeeklyCount: target,
    );
  }
}
