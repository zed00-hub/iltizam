import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../domain/models/habit.dart';
import '../domain/models/habit_record.dart';
import '../domain/models/habit_type.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/date_utils.dart';

class LocalStorageService {
  static const _habitsKey = 'eltizam_habits_v1';
  static const _recordsKey = 'eltizam_records_v1';
  static const _initializedKey = 'eltizam_is_initialized';

  final SharedPreferences _prefs;

  LocalStorageService(this._prefs);

  static Future<LocalStorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    final service = LocalStorageService(prefs);
    await service._seedInitialDataIfFirstTime();
    return service;
  }

  Future<void> _seedInitialDataIfFirstTime() async {
    final isInitialized = _prefs.getBool(_initializedKey) ?? false;
    if (!isInitialized) {
      final now = DateTime.now();

      // Seed 4 signature starter habits representing each HabitType
      final initialHabits = [
        Habit(
          id: const Uuid().v4(),
          title: 'صلاة الفجر في المسجد',
          description: 'البداية الحقيقية لليوم والبركة في الرزق والوقت',
          category: 'عبادات',
          type: HabitType.binary,
          iconCodePoint: Icons.mosque_rounded.codePoint,
          colorValue: AppColors.emerald.value,
          tagsAvailable: ['في المسجد', 'تكبيرة الإحرام', 'في البيت', 'قضاء'],
          scheduledDays: [1, 2, 3, 4, 5, 6, 7],
          createdAt: now.subtract(const Duration(days: 7)),
        ),
        Habit(
          id: const Uuid().v4(),
          title: 'تمرين رياضي ولياقة',
          description: 'بناء قوة الجسد والطاقة العالية - 4 حصص أسبوعياً',
          category: 'رياضة وصحة',
          type: HabitType.weeklyTarget,
          targetWeeklyFrequency: 4,
          iconCodePoint: Icons.fitness_center_rounded.codePoint,
          colorValue: AppColors.gold.value,
          scheduledDays: [1, 2, 3, 4, 5, 6, 7],
          createdAt: now.subtract(const Duration(days: 7)),
        ),
        Habit(
          id: const Uuid().v4(),
          title: 'ورد القرآن الكريم',
          description: 'غذاء الروح اليومي والسكينة',
          category: 'عبادات',
          type: HabitType.numeric,
          targetNumericValue: 20,
          numericUnit: 'صفحة',
          iconCodePoint: Icons.menu_book_rounded.codePoint,
          colorValue: AppColors.cyan.value,
          scheduledDays: [1, 2, 3, 4, 5, 6, 7],
          createdAt: now.subtract(const Duration(days: 7)),
        ),
        Habit(
          id: const Uuid().v4(),
          title: 'جلسة تركيز وعمل عميق',
          description: 'إنجاز المهمات الكبرى دون أي تشتيت بمؤقت',
          category: 'تطوير وتركيز',
          type: HabitType.duration,
          targetDurationMinutes: 45,
          iconCodePoint: Icons.timer_rounded.codePoint,
          colorValue: AppColors.purple.value,
          scheduledDays: [1, 2, 3, 4, 5], // 5 weekdays
          createdAt: now.subtract(const Duration(days: 7)),
        ),
      ];

      // Add a few historical records so charts and streaks look alive immediately
      final initialRecords = <HabitRecord>[];
      final fajr = initialHabits[0];
      final gym = initialHabits[1];

      // Seed 3 days streak for Fajr
      for (int i = 3; i >= 1; i--) {
        final d = now.subtract(Duration(days: i));
        initialRecords.add(HabitRecord(
          id: const Uuid().v4(),
          habitId: fajr.id,
          dateKey: AppDateUtils.toKey(d),
          isCompleted: true,
          selectedTags: ['في المسجد', 'تكبيرة الإحرام'],
          completedAt: DateTime(d.year, d.month, d.day, 5, 15),
        ));
      }

      // Seed 2 gym workouts this week
      for (int i = 2; i >= 1; i--) {
        final d = now.subtract(Duration(days: i));
        initialRecords.add(HabitRecord(
          id: const Uuid().v4(),
          habitId: gym.id,
          dateKey: AppDateUtils.toKey(d),
          isCompleted: true,
          completedAt: DateTime(d.year, d.month, d.day, 17, 30),
        ));
      }

      await saveHabits(initialHabits);
      await saveRecords(initialRecords);
      await _prefs.setBool(_initializedKey, true);
    }
  }

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

  /// Full JSON export for backup
  String exportBackupJson() {
    final habits = loadHabits();
    final records = loadRecords();
    return jsonEncode({
      'app': 'Eltizam',
      'version': '1.0.0',
      'exportedAt': DateTime.now().toIso8601String(),
      'habits': habits.map((h) => h.toJson()).toList(),
      'records': records.map((r) => r.toJson()).toList(),
    });
  }

  /// Full JSON import from backup
  Future<bool> importBackupJson(String jsonString) async {
    try {
      final Map<String, dynamic> data = jsonDecode(jsonString);
      final List<dynamic> rawHabits = data['habits'] ?? [];
      final List<dynamic> rawRecords = data['records'] ?? [];

      final habits = rawHabits.map((h) => Habit.fromJson(h)).toList();
      final records = rawRecords.map((r) => HabitRecord.fromJson(r)).toList();

      await saveHabits(habits);
      await saveRecords(records);
      return true;
    } catch (_) {
      return false;
    }
  }
}
