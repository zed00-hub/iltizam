import 'package:flutter_test/flutter_test.dart';
import 'package:eltizam/features/habits/domain/models/habit.dart';
import 'package:eltizam/features/habits/domain/models/habit_record.dart';
import 'package:eltizam/features/habits/domain/models/habit_type.dart';
import 'package:eltizam/features/habits/domain/services/streak_engine.dart';
import 'package:eltizam/features/habits/domain/services/habit_strength_calculator.dart';
import 'package:eltizam/features/habits/domain/services/gamification_engine.dart';
import 'package:eltizam/core/utils/date_utils.dart';

void main() {
  group('StreakEngine & HabitStrength Tests', () {
    final now = DateTime(2026, 10, 28);
    final habit = Habit(
      id: 'h1',
      title: 'عادة تجريبية',
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
          isFrozen: true,
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

      expect(res.currentStreak, 2);
      expect(res.isCompletedToday, true);
      expect(res.isCriticalDay, false);
    });

    test('Zero habits and zero records behave gracefully without errors', () {
      final globalIndex = HabitStrengthCalculator.calculateGlobalCommitmentIndex(
        habits: [],
        records: [],
      );
      expect(globalIndex, 0.0);

      final totalXp = GamificationEngine.calculateTotalXp(
        habits: [],
        records: [],
      );
      expect(totalXp, 0);

      final badges = GamificationEngine.evaluateBadges(
        habits: [],
        records: [],
        maxStreakAcrossHabits: 0,
      );
      expect(badges.isNotEmpty, true);
      expect(badges.every((b) => !b.isUnlocked), true);
    });

    test('Universal badges unlock accurately based on pure behavioral metrics', () {
      final records = [
        HabitRecord(
          id: '1',
          habitId: 'h1',
          dateKey: '2026-10-28',
          isCompleted: true,
          completedAt: DateTime(2026, 10, 28, 6, 30), // Early bird < 8:00 AM
        ),
      ];

      final badges = GamificationEngine.evaluateBadges(
        habits: [habit],
        records: records,
        maxStreakAcrossHabits: 3,
      );

      final firstStep = badges.firstWhere((b) => b.id == 'first_step');
      expect(firstStep.isUnlocked, true);

      final streak3 = badges.firstWhere((b) => b.id == 'streak_3');
      expect(streak3.isUnlocked, true);

      final streak7 = badges.firstWhere((b) => b.id == 'streak_7');
      expect(streak7.isUnlocked, false);
    });
  });
}
