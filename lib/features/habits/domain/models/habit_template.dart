import 'package:uuid/uuid.dart';
import 'habit.dart';
import 'habit_type.dart';

class HabitTemplate {
  final String title;
  final String description;
  final String category;
  final HabitType type;
  final int iconCodePoint;
  final int colorValue;
  final List<String> tagsAvailable;
  final int? targetWeeklyFrequency;
  final double? targetNumericValue;
  final String? numericUnit;
  final int? targetDurationMinutes;
  final List<int> scheduledDays;

  const HabitTemplate({
    required this.title,
    required this.description,
    required this.category,
    required this.type,
    required this.iconCodePoint,
    required this.colorValue,
    this.tagsAvailable = const [],
    this.targetWeeklyFrequency,
    this.targetNumericValue,
    this.numericUnit,
    this.targetDurationMinutes,
    this.scheduledDays = const [1, 2, 3, 4, 5, 6, 7],
  });

  Habit toHabit() {
    return Habit(
      id: const Uuid().v4(),
      title: title,
      description: description,
      category: category,
      type: type,
      iconCodePoint: iconCodePoint,
      colorValue: colorValue,
      tagsAvailable: tagsAvailable,
      targetWeeklyFrequency: targetWeeklyFrequency,
      targetNumericValue: targetNumericValue,
      numericUnit: numericUnit,
      targetDurationMinutes: targetDurationMinutes,
      scheduledDays: scheduledDays,
      createdAt: DateTime.now(),
    );
  }

  static const List<HabitTemplate> catalog = [
    // 1. إيمانيات وروحانيات
    HabitTemplate(
      title: 'صلاة الفجر في المسجد',
      description: 'البداية الحقيقية لبركة اليوم وثبات الروح',
      category: 'إيمانيات',
      type: HabitType.binary,
      iconCodePoint: 0xf0200, // mosque_rounded
      colorValue: 0xFF10B981, // Emerald
      tagsAvailable: ['في المسجد', 'تكبيرة الإحرام', 'في البيت', 'قضاء'],
    ),
    HabitTemplate(
      title: 'ورد القرآن الكريم',
      description: 'غذاء الروح والتأمل اليومي في كتاب الله',
      category: 'إيمانيات',
      type: HabitType.numeric,
      targetNumericValue: 20,
      numericUnit: 'صفحة',
      iconCodePoint: 0xe3e0, // menu_book_rounded
      colorValue: 0xFF06B6D4, // Cyan
    ),
    HabitTemplate(
      title: 'أذكار الصباح والمساء',
      description: 'حصن المسلم والسكينة في بداية ونهاية النهار',
      category: 'إيمانيات',
      type: HabitType.binary,
      iconCodePoint: 0xe5fe, // shield_rounded
      colorValue: 0xFF10B981,
      tagsAvailable: ['أذكار الصباح', 'أذكار المساء', 'كاملة'],
    ),

    // 2. صحة ولياقة بدنية
    HabitTemplate(
      title: 'تمرين بدني ولياقة',
      description: 'بناء القوة البدنية ورفع الطاقة الحيوية',
      category: 'صحة ورياضة',
      type: HabitType.weeklyTarget,
      targetWeeklyFrequency: 4,
      iconCodePoint: 0xe28f, // fitness_center_rounded
      colorValue: 0xFFF59E0B, // Gold
    ),
    HabitTemplate(
      title: 'شرب 3 لترات ماء',
      description: 'الترطيب المستمر لصحة الجسم والدماغ',
      category: 'صحة ورياضة',
      type: HabitType.numeric,
      targetNumericValue: 3000,
      numericUnit: 'مل',
      iconCodePoint: 0xf067a, // water_drop_rounded
      colorValue: 0xFF38BDF8, // Ice blue
    ),
    HabitTemplate(
      title: 'المشي اليومي (10,000 خطوة)',
      description: 'حركة يومية مستمرة لتنشيط الدورة الدموية',
      category: 'صحة ورياضة',
      type: HabitType.numeric,
      targetNumericValue: 10000,
      numericUnit: 'خطوة',
      iconCodePoint: 0xe54d, // run_circle_outlined
      colorValue: 0xFFF97316, // Orange
    ),

    // 3. تطوير وتعلّم
    HabitTemplate(
      title: 'قراءة الكتب وتطوير الذات',
      description: 'تغذية العقل وتوسيع المدارك بالمعرفة الرصينة',
      category: 'تطوير وتعلّم',
      type: HabitType.numeric,
      targetNumericValue: 20,
      numericUnit: 'صفحة',
      iconCodePoint: 0xe3e0, // menu_book_rounded
      colorValue: 0xFF8B5CF6, // Purple
    ),
    HabitTemplate(
      title: 'تعلّم مهارة جديدة',
      description: 'استثمار يومي لتطوير المهارات التقنية أو اللغوية',
      category: 'تطوير وتعلّم',
      type: HabitType.duration,
      targetDurationMinutes: 30,
      iconCodePoint: 0xe8af, // code_rounded
      colorValue: 0xFF06B6D4,
    ),

    // 4. إنتاجية وتركيز
    HabitTemplate(
      title: 'جلسة عمل عميق وتركيز (Deep Work)',
      description: 'إنجاز المهمات الاستراتيجية بمؤقت ودون أي مقاطعات',
      category: 'إنتاجية وتركيز',
      type: HabitType.duration,
      targetDurationMinutes: 45,
      iconCodePoint: 0xe664, // timer_rounded
      colorValue: 0xFF8B5CF6,
      scheduledDays: [1, 2, 3, 4, 5],
    ),
    HabitTemplate(
      title: 'النوم المبكر (قبل 11:00 م)',
      description: 'الاستيقاظ بنشاط وكفاءة ذهنية عالية',
      category: 'إنتاجية وتركيز',
      type: HabitType.binary,
      iconCodePoint: 0xe0e1, // bedtime_rounded
      colorValue: 0xFF3B82F6,
    ),
  ];
}
