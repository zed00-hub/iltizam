class HabitRecord {
  final String id;
  final String habitId;
  final String dateKey; // "yyyy-MM-dd"
  final bool isCompleted;
  final bool isFrozen; // Streak Freeze applied (protects streak without fake completion)
  final bool isRestDay; // Planned rest day
  final double? numericValue;
  final int? durationMinutes;
  final List<String> selectedTags;
  final String? stumbleReason; // سبب التعثر اختياريًا
  final String? notes;
  final DateTime? completedAt;

  HabitRecord({
    required this.id,
    required this.habitId,
    required this.dateKey,
    this.isCompleted = false,
    this.isFrozen = false,
    this.isRestDay = false,
    this.numericValue,
    this.durationMinutes,
    this.selectedTags = const [],
    this.stumbleReason,
    this.notes,
    this.completedAt,
  });

  HabitRecord copyWith({
    String? id,
    String? habitId,
    String? dateKey,
    bool? isCompleted,
    bool? isFrozen,
    bool? isRestDay,
    double? numericValue,
    int? durationMinutes,
    List<String>? selectedTags,
    String? stumbleReason,
    String? notes,
    DateTime? completedAt,
  }) {
    return HabitRecord(
      id: id ?? this.id,
      habitId: habitId ?? this.habitId,
      dateKey: dateKey ?? this.dateKey,
      isCompleted: isCompleted ?? this.isCompleted,
      isFrozen: isFrozen ?? this.isFrozen,
      isRestDay: isRestDay ?? this.isRestDay,
      numericValue: numericValue ?? this.numericValue,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      selectedTags: selectedTags ?? this.selectedTags,
      stumbleReason: stumbleReason ?? this.stumbleReason,
      notes: notes ?? this.notes,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'habitId': habitId,
      'dateKey': dateKey,
      'isCompleted': isCompleted,
      'isFrozen': isFrozen,
      'isRestDay': isRestDay,
      'numericValue': numericValue,
      'durationMinutes': durationMinutes,
      'selectedTags': selectedTags,
      'stumbleReason': stumbleReason,
      'notes': notes,
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  factory HabitRecord.fromJson(Map<String, dynamic> json) {
    return HabitRecord(
      id: json['id'] as String,
      habitId: json['habitId'] as String,
      dateKey: json['dateKey'] as String,
      isCompleted: json['isCompleted'] as bool? ?? false,
      isFrozen: json['isFrozen'] as bool? ?? false,
      isRestDay: json['isRestDay'] as bool? ?? false,
      numericValue: (json['numericValue'] as num?)?.toDouble(),
      durationMinutes: json['durationMinutes'] as int?,
      selectedTags: (json['selectedTags'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      stumbleReason: json['stumbleReason'] as String?,
      notes: json['notes'] as String?,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
    );
  }
}
