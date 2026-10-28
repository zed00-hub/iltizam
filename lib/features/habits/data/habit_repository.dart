import '../domain/models/habit.dart';
import '../domain/models/habit_record.dart';
import 'local_storage_service.dart';

class HabitRepository {
  final LocalStorageService _storage;

  HabitRepository(this._storage);

  List<Habit> getAllHabits() {
    return _storage.loadHabits();
  }

  Future<void> saveHabit(Habit habit) async {
    final habits = _storage.loadHabits();
    final index = habits.indexWhere((h) => h.id == habit.id);
    if (index >= 0) {
      habits[index] = habit;
    } else {
      habits.add(habit);
    }
    await _storage.saveHabits(habits);
  }

  Future<void> deleteHabit(String habitId) async {
    final habits = _storage.loadHabits();
    habits.removeWhere((h) => h.id == habitId);
    await _storage.saveHabits(habits);

    // Also remove related records
    final records = _storage.loadRecords();
    records.removeWhere((r) => r.habitId == habitId);
    await _storage.saveRecords(records);
  }

  List<HabitRecord> getAllRecords() {
    return _storage.loadRecords();
  }

  Future<void> saveRecord(HabitRecord record) async {
    final records = _storage.loadRecords();
    final index = records.indexWhere(
      (r) => r.habitId == record.habitId && r.dateKey == record.dateKey,
    );
    if (index >= 0) {
      records[index] = record;
    } else {
      records.add(record);
    }
    await _storage.saveRecords(records);
  }

  Future<void> deleteRecord(String habitId, String dateKey) async {
    final records = _storage.loadRecords();
    records.removeWhere((r) => r.habitId == habitId && r.dateKey == dateKey);
    await _storage.saveRecords(records);
  }

  String exportBackup() => _storage.exportBackupJson();
  Future<bool> importBackup(String json) => _storage.importBackupJson(json);
}
