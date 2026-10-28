enum HabitType {
  /// نعم / لا مع وسوم نوعية (مثل صلاة الفجر في المسجد)
  binary,

  /// هدف دوري أسبوعي (مثل 4 أيام رياضة في الأسبوع)
  weeklyTarget,

  /// رقمي وكمي بوحدة قياس (مثل 3 لترات ماء، 20 صفحة)
  numeric,

  /// مدة زمنية بمؤقت تركيز (مثل 45 دقيقة مذاكرة أو قراءة)
  duration;

  String get labelArabic {
    switch (this) {
      case HabitType.binary:
        return 'نعم / لا ووسوم';
      case HabitType.weeklyTarget:
        return 'تكرار أسبوعي';
      case HabitType.numeric:
        return 'كمي ورقمي';
      case HabitType.duration:
        return 'مؤقت ومدة زمنية';
    }
  }

  String get descriptionArabic {
    switch (this) {
      case HabitType.binary:
        return 'تسجيل إتمام بنقرة واحدة مع وسوم تفصيلية (في المسجد، جماعة)';
      case HabitType.weeklyTarget:
        return 'تحديد عدد مرات مستهدفة في الأسبوع وتتبع إنجاز الأسابيع';
      case HabitType.numeric:
        return 'تتبع أرقام بالزيادة (صفحات، لترات، ركعات)';
      case HabitType.duration:
        return 'مؤقت تركيز مدمج بالدقائق والثواني';
    }
  }
}
