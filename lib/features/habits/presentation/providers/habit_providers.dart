import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../data/habit_repository.dart';
import '../../data/local_storage_service.dart';
import '../../domain/models/habit.dart';
import '../../domain/models/habit_record.dart';
import '../../domain/models/user_level.dart';
import '../../domain/services/gamification_engine.dart';
import '../../domain/services/habit_strength_calculator.dart';
import '../../domain/services/streak_engine.dart';
import '../../../../core/utils/date_utils.dart';

// 1. Dependency Providers
final storageServiceProvider = Provider<LocalStorageService>((ref) {
  throw UnimplementedError('Initialize storageServiceProvider in main');
});

final habitRepositoryProvider = Provider<HabitRepository>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return HabitRepository(storage);
});

// 2. Selected Date Notifier
class SelectedDateNotifier extends Notifier<DateTime> {
  @override
  DateTime build() {
    return AppDateUtils.normalize(DateTime.now());
  }

  void setDate(DateTime date) {
    state = date;
  }
}

final selectedDateProvider =
    NotifierProvider<SelectedDateNotifier, DateTime>(SelectedDateNotifier.new);

// 3. Habits Notifier
class HabitsNotifier extends Notifier<List<Habit>> {
  @override
  List<Habit> build() {
    final repo = ref.watch(habitRepositoryProvider);
    return repo.getAllHabits();
  }

  Future<void> addHabit(Habit habit) async {
    final repo = ref.read(habitRepositoryProvider);
    await repo.saveHabit(habit);
    state = repo.getAllHabits();
  }

  Future<void> updateHabit(Habit habit) async {
    final repo = ref.read(habitRepositoryProvider);
    await repo.saveHabit(habit);
    state = repo.getAllHabits();
  }

  Future<void> deleteHabit(String habitId) async {
    final repo = ref.read(habitRepositoryProvider);
    await repo.deleteHabit(habitId);
    state = repo.getAllHabits();
  }

  void refresh() {
    final repo = ref.read(habitRepositoryProvider);
    state = repo.getAllHabits();
  }
}

final habitsProvider =
    NotifierProvider<HabitsNotifier, List<Habit>>(HabitsNotifier.new);

// 4. Records Notifier
class RecordsNotifier extends Notifier<List<HabitRecord>> {
  @override
  List<HabitRecord> build() {
    final repo = ref.watch(habitRepositoryProvider);
    return repo.getAllRecords();
  }

  Future<void> toggleCompletion({
    required Habit habit,
    required DateTime date,
    List<String>? selectedTags,
    double? numericValue,
    int? durationMinutes,
  }) async {
    final repo = ref.read(habitRepositoryProvider);
    final dateKey = AppDateUtils.toKey(date);
    final existing = state.firstWhere(
      (r) => r.habitId == habit.id && r.dateKey == dateKey,
      orElse: () => HabitRecord(
        id: const Uuid().v4(),
        habitId: habit.id,
        dateKey: dateKey,
        isCompleted: false,
      ),
    );

    final nextCompleted = !existing.isCompleted;
    final updated = existing.copyWith(
      isCompleted: nextCompleted,
      isFrozen: false, // If completing, clear freeze
      selectedTags: selectedTags ?? existing.selectedTags,
      numericValue: numericValue ?? existing.numericValue,
      durationMinutes: durationMinutes ?? existing.durationMinutes,
      completedAt: nextCompleted ? DateTime.now() : null,
    );

    await repo.saveRecord(updated);
    state = repo.getAllRecords();
  }

  Future<void> updateRecord(HabitRecord record) async {
    final repo = ref.read(habitRepositoryProvider);
    await repo.saveRecord(record);
    state = repo.getAllRecords();
  }

  Future<void> toggleFreeze({
    required String habitId,
    required DateTime date,
  }) async {
    final repo = ref.read(habitRepositoryProvider);
    final dateKey = AppDateUtils.toKey(date);
    final existing = state.firstWhere(
      (r) => r.habitId == habitId && r.dateKey == dateKey,
      orElse: () => HabitRecord(
        id: const Uuid().v4(),
        habitId: habitId,
        dateKey: dateKey,
        isCompleted: false,
      ),
    );

    final updated = existing.copyWith(
      isFrozen: !existing.isFrozen,
      isCompleted: false,
    );

    await repo.saveRecord(updated);
    state = repo.getAllRecords();
  }

  void refresh() {
    final repo = ref.read(habitRepositoryProvider);
    state = repo.getAllRecords();
  }
}

final recordsProvider =
    NotifierProvider<RecordsNotifier, List<HabitRecord>>(RecordsNotifier.new);

// 5. Computed Metric Providers
final habitStreakProvider =
    Provider.family<StreakResult, Habit>((ref, habit) {
  final records = ref.watch(recordsProvider);
  final selectedDate = ref.watch(selectedDateProvider);
  return StreakEngine.calculateStreak(
    habit: habit,
    records: records,
    referenceDate: selectedDate,
  );
});

final habitStrengthProvider =
    Provider.family<double, Habit>((ref, habit) {
  final records = ref.watch(recordsProvider);
  final selectedDate = ref.watch(selectedDateProvider);
  return HabitStrengthCalculator.calculateStrength(
    habit: habit,
    records: records,
    referenceDate: selectedDate,
  );
});

final overallCommitmentIndexProvider = Provider<double>((ref) {
  final habits = ref.watch(habitsProvider);
  final records = ref.watch(recordsProvider);
  return HabitStrengthCalculator.calculateGlobalCommitmentIndex(
    habits: habits,
    records: records,
  );
});

final totalXpProvider = Provider<int>((ref) {
  final habits = ref.watch(habitsProvider);
  final records = ref.watch(recordsProvider);
  return GamificationEngine.calculateTotalXp(
    habits: habits,
    records: records,
  );
});

final userLevelProvider = Provider<UserLevel>((ref) {
  final xp = ref.watch(totalXpProvider);
  return UserLevel.fromXp(xp);
});

final achievementBadgesProvider = Provider<List<AchievementBadge>>((ref) {
  final habits = ref.watch(habitsProvider);
  final records = ref.watch(recordsProvider);

  int maxStreak = 0;
  for (var h in habits) {
    final res = StreakEngine.calculateStreak(habit: h, records: records);
    if (res.bestStreak > maxStreak) {
      maxStreak = res.bestStreak;
    }
  }

  return GamificationEngine.evaluateBadges(
    habits: habits,
    records: records,
    maxStreakAcrossHabits: maxStreak,
  );
});
