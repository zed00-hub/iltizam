class UserProfile {
  final String displayName;
  final bool isOnboardingCompleted;
  final DateTime joinedDate;
  final String? preferredWakeTime; // e.g. "05:00"
  final String? preferredSleepTime; // e.g. "22:00"

  const UserProfile({
    this.displayName = '',
    this.isOnboardingCompleted = false,
    required this.joinedDate,
    this.preferredWakeTime,
    this.preferredSleepTime,
  });

  UserProfile copyWith({
    String? displayName,
    bool? isOnboardingCompleted,
    DateTime? joinedDate,
    String? preferredWakeTime,
    String? preferredSleepTime,
  }) {
    return UserProfile(
      displayName: displayName ?? this.displayName,
      isOnboardingCompleted:
          isOnboardingCompleted ?? this.isOnboardingCompleted,
      joinedDate: joinedDate ?? this.joinedDate,
      preferredWakeTime: preferredWakeTime ?? this.preferredWakeTime,
      preferredSleepTime: preferredSleepTime ?? this.preferredSleepTime,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'displayName': displayName,
      'isOnboardingCompleted': isOnboardingCompleted,
      'joinedDate': joinedDate.toIso8601String(),
      'preferredWakeTime': preferredWakeTime,
      'preferredSleepTime': preferredSleepTime,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      displayName: json['displayName'] as String? ?? '',
      isOnboardingCompleted:
          json['isOnboardingCompleted'] as bool? ?? false,
      joinedDate: json['joinedDate'] != null
          ? DateTime.parse(json['joinedDate'] as String)
          : DateTime.now(),
      preferredWakeTime: json['preferredWakeTime'] as String?,
      preferredSleepTime: json['preferredSleepTime'] as String?,
    );
  }
}
