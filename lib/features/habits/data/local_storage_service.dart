import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/models/habit.dart';
import '../domain/models/habit_record.dart';
import '../domain/models/user_profile.dart';

class LocalStorageService {
  static const _habitsKey = 'eltizam_habits_v1';
  static const _recordsKey = 'eltizam_records_v1';
  static const _profileKey = 'eltizam_user_profile_v1';

  final SharedPreferences _prefs;

  LocalStorageService(this._prefs);

  static Future<LocalStorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return LocalStorageService(prefs);
  }

  // 1. User Profile Management
  UserProfile loadProfile() {
    final raw = _prefs.getString(_profileKey);
    if (raw == null || raw.isEmpty) {
      return UserProfile(
        displayName: '',
        isOnboardingCompleted: false,
        joinedDate: DateTime.now(),
      );
    }
    try {
      return UserProfile.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return UserProfile(
        displayName: '',
        isOnboardingCompleted: false,
        joinedDate: DateTime.now(),
      );
    }
  }

  Future<void> saveProfile(UserProfile profile) async {
    await _prefs.setString(_profileKey, jsonEncode(profile.toJson()));
  }

  // 2. Habits (Starts completely empty for new users)
  List<Habit> loadHabits() {
    final raw = _prefs.getString(_habitsKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final List<dynamic> list = jsonDecode(raw);
      return list.map((item) => Habit.fromJson(item)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveHabits(List<Habit> habits) async {
    final raw = jsonEncode(habits.map((h) => h.toJson()).toList());
    await _prefs.setString(_habitsKey, raw);
  }

  // 3. Records (Starts completely empty for new users)
  List<HabitRecord> loadRecords() {
    final raw = _prefs.getString(_recordsKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final List<dynamic> list = jsonDecode(raw);
      return list.map((item) => HabitRecord.fromJson(item)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveRecords(List<HabitRecord> records) async {
    final raw = jsonEncode(records.map((r) => r.toJson()).toList());
    await _prefs.setString(_recordsKey, raw);
  }

  // 4. Clean Slate Reset
  Future<void> clearAllData() async {
    await _prefs.remove(_habitsKey);
    await _prefs.remove(_recordsKey);
  }

  // 5. Full JSON Export for Backup
  String exportBackupJson() {
    final profile = loadProfile();
    final habits = loadHabits();
    final records = loadRecords();
    return jsonEncode({
      'app': 'Eltizam',
      'version': '1.0.0',
      'exportedAt': DateTime.now().toIso8601String(),
      'profile': profile.toJson(),
      'habits': habits.map((h) => h.toJson()).toList(),
      'records': records.map((r) => r.toJson()).toList(),
    });
  }

  // 6. Backup Validation & Metadata extraction
  Map<String, dynamic>? inspectBackup(String jsonString) {
    try {
      final dynamic decoded = jsonDecode(jsonString.trim());
      if (decoded is! Map<String, dynamic>) return null;

      final app = decoded['app'] as String?;
      if (app != 'Eltizam' && app != 'eltizam') return null;

      final rawHabits = decoded['habits'];
      final rawRecords = decoded['records'];
      final habitCount = rawHabits is List ? rawHabits.length : 0;
      final recordCount = rawRecords is List ? rawRecords.length : 0;
      final exportedAt = decoded['exportedAt'] as String? ?? '';
      final version = decoded['version'] as String? ?? '1.0.0';

      return {
        'isValid': true,
        'version': version,
        'exportedAt': exportedAt,
        'habitCount': habitCount,
        'recordCount': recordCount,
        'data': decoded,
      };
    } catch (_) {
      return null;
    }
  }

  // 7. Full Overwrite / Replace Restore
  Future<bool> restoreReplace(Map<String, dynamic> backupData) async {
    try {
      final List<dynamic> rawHabits = backupData['habits'] ?? [];
      final List<dynamic> rawRecords = backupData['records'] ?? [];

      final habits = rawHabits.map((h) => Habit.fromJson(h)).toList();
      final records = rawRecords.map((r) => HabitRecord.fromJson(r)).toList();

      if (backupData['profile'] != null) {
        final profile = UserProfile.fromJson(
            backupData['profile'] as Map<String, dynamic>);
        await saveProfile(profile);
      }

      await saveHabits(habits);
      await saveRecords(records);
      return true;
    } catch (_) {
      return false;
    }
  }

  // 8. Smart Merge Restore (Deduping without overwriting existing data)
  Future<bool> restoreMerge(Map<String, dynamic> backupData) async {
    try {
      final List<dynamic> rawHabits = backupData['habits'] ?? [];
      final List<dynamic> rawRecords = backupData['records'] ?? [];

      final importedHabits =
          rawHabits.map((h) => Habit.fromJson(h)).toList();
      final importedRecords =
          rawRecords.map((r) => HabitRecord.fromJson(r)).toList();

      // Merge habits (only add ones that don't already exist by id)
      final currentHabits = loadHabits();
      final currentHabitIds = currentHabits.map((h) => h.id).toSet();
      for (final h in importedHabits) {
        if (!currentHabitIds.contains(h.id)) {
          currentHabits.add(h);
        }
      }

      // Merge records (deduplicate by habitId + dateKey)
      final currentRecords = loadRecords();
      final currentRecordKeys =
          currentRecords.map((r) => '${r.habitId}_${r.dateKey}').toSet();
      for (final r in importedRecords) {
        final key = '${r.habitId}_${r.dateKey}';
        if (!currentRecordKeys.contains(key)) {
          currentRecords.add(r);
        }
      }

      await saveHabits(currentHabits);
      await saveRecords(currentRecords);
      return true;
    } catch (_) {
      return false;
    }
  }
}
