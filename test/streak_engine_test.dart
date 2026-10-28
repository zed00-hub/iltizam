import 'package:flutter_test/flutter_test.dart';
import 'package:eltizam/features/habits/domain/models/habit.dart';
import 'package:eltizam/features/habits/domain/models/habit_record.dart';
import 'package:eltizam/features/habits/domain/models/habit_type.dart';
import 'package:eltizam/features/habits/domain/services/streak_engine.dart';
import 'package:eltizam/features/habits/domain/services/habit_strength_calculator.dart';
import 'package:eltizam/core/utils/date_utils.dart';

void main() {
  group('StreakEngine & HabitStrength Tests', () {
    final now = DateTime(2026, 10, 28); // Wednesday (weekday 3)
    final habit = Habit(
      id: 'h1',
      title: 'صلاة الفجر في المسجد',
      type: HabitType.binary,
      scheduledDays: [1, 2, 3, 4, 5, 6, 7],
      createdAt: now.subtract(const Duration(days: 30)),
    );

    test('Consecutive completed days calculate current and best streak correctly', () {
      final records = [
        HabitRecord(
          id: '1',
          habitId: 'h1',
          dateKey: AppDateUtils.toKey(now),
          isCompleted: true,
        ),
        HabitRecord(
          id: '2',
          habitId: 'h1',
          dateKey: AppDateUtils.toKey(now.subtract(const Duration(days: 1))),
          isCompleted: true,
        ),
        HabitRecord(
          id: '3',
          habitId: 'h1',
          dateKey: AppDateUtils.toKey(now.subtract(const Duration(days: 2))),
          isCompleted: true,
        ),
      ];

      final res = StreakEngine.calculateStreak(
        habit: habit,
        records: records,
        referenceDate: now,
      );

      expect(res.currentStreak, 3);
      expect(res.bestStreak, 3);
      expect(res.isCompletedToday, true);
      expect(res.isCriticalDay, false);
    });

    test('Freeze day protects streak continuity without counting as completed day', () {
      final records = [
        HabitRecord(
          id: '1',
          habitId: 'h1',
          dateKey: AppDateUtils.toKey(now),
          isCompleted: true,
        ),
        HabitRecord(
          id: '2',
          habitId: 'h1',
          dateKey: AppDateUtils.toKey(now.subtract(const Duration(days: 1))),
          isCompleted: false,
          isFrozen: true, // Frozen yesterday!
        ),
        HabitRecord(
          id: '3',
          habitId: 'h1',
          dateKey: AppDateUtils.toKey(now.subtract(const Duration(days: 2))),
          isCompleted: true,
        ),
      ];

      final res = StreakEngine.calculateStreak(
        habit: habit,
        records: records,
        referenceDate: now,
      );

      // 2 completed days + 1 protected frozen day
      expect(res.currentStreak, 2);
      expect(res.isCompletedToday, true);
      expect(res.isCriticalDay, false);
    });

    test('Habit Strength Score calculates exponential memory decay correctly', () {
      final records = [
        HabitRecord(
          id: '1',
          habitId: 'h1',
          dateKey: AppDateUtils.toKey(now),
          isCompleted: true,
        ),
      ];

      final score = HabitStrengthCalculator.calculateStrength(
        habit: habit,
        records: records,
        referenceDate: now,
      );

      expect(score, greaterThan(0.0));
      expect(score, lessThanOrEqualTo(100.0));
    });
  });
}
