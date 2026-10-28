import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/utils/haptics.dart';
import '../../domain/models/habit_record.dart';
import '../providers/habit_providers.dart';

class ProgressRingHeader extends ConsumerWidget {
  const ProgressRingHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);
    final isToday = AppDateUtils.isSameDay(selectedDate, DateTime.now());
    final habits = ref.watch(habitsProvider);
    final records = ref.watch(recordsProvider);
    final commitmentIndex = ref.watch(overallCommitmentIndexProvider);

    // Calculate completed vs total due for selectedDate
    final dateKey = AppDateUtils.toKey(selectedDate);
    final activeHabits = habits.where((h) => !h.isArchived).toList();
    final dueHabits = activeHabits
        .where((h) => h.scheduledDays.contains(selectedDate.weekday))
        .toList();

    int completedCount = 0;
    for (final habit in dueHabits) {
      final rec = records.firstWhere(
        (r) => r.habitId == habit.id && r.dateKey == dateKey,
        orElse: () => HabitRecord(id: '', habitId: '', dateKey: ''),
      );
      if (rec.isCompleted) completedCount++;
    }

    final bool hasDueHabits = dueHabits.isNotEmpty;
    final double completionRatio = hasDueHabits
        ? (completedCount / dueHabits.length).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border, width: 1.2),
        gradient: LinearGradient(
          colors: [
            AppColors.surface,
            AppColors.surfaceElevated.withValues(alpha: 0.6),
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
      ),
      child: Column(
        children: [
          // Date Selector Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_right_rounded,
                    color: AppColors.textSecondary, size: 26),
                onPressed: () {
                  AppHaptics.selection();
                  ref.read(selectedDateProvider.notifier).setDate(
                        selectedDate.subtract(const Duration(days: 1)),
                      );
                },
                tooltip: 'اليوم السابق',
              ),
              GestureDetector(
                onTap: () {
                  AppHaptics.lightImpact();
                  ref.read(selectedDateProvider.notifier).setDate(
                        AppDateUtils.normalize(DateTime.now()),
                      );
                },
                child: Column(
                  children: [
                    Text(
                      AppDateUtils.formatHeaderArabic(selectedDate),
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isToday)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.emerald.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'اليوم الحاضر',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.emerald,
                              ),
                            ),
                          )
                        else
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceElevated,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'اضغط للعودة لليوم',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.gold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_left_rounded,
                    color: AppColors.textSecondary, size: 26),
                onPressed: () {
                  AppHaptics.selection();
                  ref.read(selectedDateProvider.notifier).setDate(
                        selectedDate.add(const Duration(days: 1)),
                      );
                },
                tooltip: 'اليوم التالي',
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Central Rings & Stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Circular Progress Ring
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 90,
                    height: 90,
                    child: CircularProgressIndicator(
                      value: hasDueHabits ? completionRatio : 0.0,
                      strokeWidth: 8,
                      backgroundColor: AppColors.border,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        completionRatio == 1.0 && hasDueHabits
                            ? AppColors.gold
                            : AppColors.emerald,
                      ),
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        hasDueHabits
                            ? '$completedCount/${dueHabits.length}'
                            : '0',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        hasDueHabits
                            ? '${(completionRatio * 100).toInt()}%'
                            : 'جاهز',
                        style: TextStyle(
                          fontSize: 11,
                          color: completionRatio == 1.0 && hasDueHabits
                              ? AppColors.gold
                              : AppColors.emerald,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Overall Tank Score Badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.local_fire_department,
                          color: commitmentIndex > 70
                              ? AppColors.gold
                              : AppColors.emerald,
                          size: 18,
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          'مؤشر التزام الدبابة',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      hasDueHabits || activeHabits.isNotEmpty
                          ? '${commitmentIndex.toStringAsFixed(1)}%'
                          : '100%',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: commitmentIndex > 70
                            ? AppColors.gold
                            : AppColors.emerald,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      activeHabits.isEmpty
                          ? 'بانتظار عادتك الأولى 🚀'
                          : commitmentIndex >= 85
                              ? 'قوة التزام خارقة 🛡️'
                              : commitmentIndex >= 50
                                  ? 'ثبات وانضباط مستمر 💪'
                                  : 'في مرحلة بناء الزخم 🚀',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
