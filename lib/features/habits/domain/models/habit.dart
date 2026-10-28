import 'habit_type.dart';

class Habit {
  final String id;
  final String title;
  final String? description;
  final String category; // e.g. عبادات, رياضة, تطوير ذات, صحة, تركيز
  final HabitType type;
  final int iconCodePoint;
  final int colorValue;
  final List<String> tagsAvailable;
  final int? targetWeeklyFrequency; // for weeklyTarget, e.g. 4 days
  final double? targetNumericValue; // for numeric, e.g. 3000
  final String? numericUnit; // for numeric, e.g. 'مل', 'صفحة'
  final int? targetDurationMinutes; // for duration, e.g. 45
  final List<int> scheduledDays; // 1 = Monday ... 7 = Sunday
  final DateTime createdAt;
  final bool isArchived;

  Habit({
    required this.id,
    required this.title,
    this.description,
    this.category = 'عام',
    required this.type,
    this.iconCodePoint = 0xe25a, // Icons.check_circle_outline default
    this.colorValue = 0xFF10B981, // AppColors.emerald default
    this.tagsAvailable = const [],
    this.targetWeeklyFrequency,
    this.targetNumericValue,
    this.numericUnit,
    this.targetDurationMinutes,
    this.scheduledDays = const [1, 2, 3, 4, 5, 6, 7],
    required this.createdAt,
    this.isArchived = false,
  });

  Habit copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    HabitType? type,
    int? iconCodePoint,
    int? colorValue,
    List<String>? tagsAvailable,
    int? targetWeeklyFrequency,
    double? targetNumericValue,
    String? numericUnit,
    int? targetDurationMinutes,
    List<int>? scheduledDays,
    DateTime? createdAt,
    bool? isArchived,
  }) {
    return Habit(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      type: type ?? this.type,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      colorValue: colorValue ?? this.colorValue,
      tagsAvailable: tagsAvailable ?? this.tagsAvailable,
      targetWeeklyFrequency:
          targetWeeklyFrequency ?? this.targetWeeklyFrequency,
      targetNumericValue: targetNumericValue ?? this.targetNumericValue,
      numericUnit: numericUnit ?? this.numericUnit,
      targetDurationMinutes:
          targetDurationMinutes ?? this.targetDurationMinutes,
      scheduledDays: scheduledDays ?? this.scheduledDays,
      createdAt: createdAt ?? this.createdAt,
      isArchived: isArchived ?? this.isArchived,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'type': type.name,
      'iconCodePoint': iconCodePoint,
      'colorValue': colorValue,
      'tagsAvailable': tagsAvailable,
      'targetWeeklyFrequency': targetWeeklyFrequency,
      'targetNumericValue': targetNumericValue,
      'numericUnit': numericUnit,
      'targetDurationMinutes': targetDurationMinutes,
      'scheduledDays': scheduledDays,
      'createdAt': createdAt.toIso8601String(),
      'isArchived': isArchived,
    };
  }

  factory Habit.fromJson(Map<String, dynamic> json) {
    return Habit(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      category: json['category'] as String? ?? 'عام',
      type: HabitType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => HabitType.binary,
      ),
      iconCodePoint: json['iconCodePoint'] as int? ?? 0xe25a,
      colorValue: json['colorValue'] as int? ?? 0xFF10B981,
      tagsAvailable: (json['tagsAvailable'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      targetWeeklyFrequency: json['targetWeeklyFrequency'] as int?,
      targetNumericValue: (json['targetNumericValue'] as num?)?.toDouble(),
      numericUnit: json['numericUnit'] as String?,
      targetDurationMinutes: json['targetDurationMinutes'] as int?,
      scheduledDays: (json['scheduledDays'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          const [1, 2, 3, 4, 5, 6, 7],
      createdAt: DateTime.parse(json['createdAt'] as String),
      isArchived: json['isArchived'] as bool? ?? false,
    );
  }
}
