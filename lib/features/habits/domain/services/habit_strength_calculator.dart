import '../../../../core/utils/date_utils.dart';
import '../models/habit.dart';
import '../models/habit_record.dart';

class HabitStrengthCalculator {
  /// Calculates Habit Strength % (0% to 100%) using Exponential Memory Decay
  /// Missing a single day causes a realistic ~7% gentle drop, rather than wiping out
  /// months of hard commitment to 0%.
  static double calculateStrength({
    required Habit habit,
    required List<HabitRecord> records,
    DateTime? referenceDate,
  }) {
    final now = referenceDate ?? DateTime.now();
    final today = AppDateUtils.normalize(now);

    final recordMap = <String, HabitRecord>{};
    for (var r in records) {
      if (r.habitId == habit.id) {
        recordMap[r.dateKey] = r;
      }
    }

    // Check last 60 days in chronological order
    double strength = 0.0;
    const double alpha = 0.92; // Persistence / memory coefficient

    for (int i = 60; i >= 0; i--) {
      final day = today.subtract(Duration(days: i));

      // Only evaluate on due days
      if (habit.scheduledDays.contains(day.weekday)) {
        final key = AppDateUtils.toKey(day);
        final rec = recordMap[key];

        if (rec != null && rec.isCompleted) {
          // Completed day adds value
          strength = (strength * alpha) + (100.0 * (1.0 - alpha));
        } else if (rec != null && rec.isFrozen) {
          // Freeze maintains the current strength without decay
          strength = strength;
        } else if (i > 0) {
          // Missed past due day: gentle decay
          strength = strength * alpha;
        }
        // Note: For i == 0 (today), if not completed yet, don't penalize until day is over!
      }
    }

    return strength.clamp(0.0, 100.0);
  }

  /// Calculates Overall Commitment Index ("مؤشر التزام الدبابة") across all active habits
  static double calculateGlobalCommitmentIndex({
    required List<Habit> habits,
    required List<HabitRecord> records,
  }) {
    final activeHabits = habits.where((h) => !h.isArchived).toList();
    if (activeHabits.isEmpty) return 0.0;

    double totalStrength = 0.0;
    for (final habit in activeHabits) {
      totalStrength += calculateStrength(habit: habit, records: records);
    }

    return (totalStrength / activeHabits.length).clamp(0.0, 100.0);
  }
}
