import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/utils/haptics.dart';
import '../../../../core/utils/icon_helper.dart';
import '../../domain/models/habit.dart';
import '../../domain/models/habit_record.dart';
import '../../domain/models/habit_type.dart';
import '../../domain/services/streak_engine.dart';
import '../providers/habit_providers.dart';
import 'focus_timer_dialog.dart';

class HabitCard extends ConsumerWidget {
  final Habit habit;
  final VoidCallback onOpenDetail;

  const HabitCard({
    super.key,
    required this.habit,
    required this.onOpenDetail,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);
    final dateKey = AppDateUtils.toKey(selectedDate);
    final records = ref.watch(recordsProvider);
    final streak = ref.watch(habitStreakProvider(habit));
    final strength = ref.watch(habitStrengthProvider(habit));

    final record = records.firstWhere(
      (r) => r.habitId == habit.id && r.dateKey == dateKey,
      orElse: () => HabitRecord(
        id: '',
        habitId: habit.id,
        dateKey: dateKey,
        isCompleted: false,
      ),
    );

    final isCompleted = record.isCompleted;
    final isFrozen = record.isFrozen;
    final color = Color(habit.colorValue);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isCompleted
              ? color.withValues(alpha: 0.5)
              : isFrozen
                  ? AppColors.freeze.withValues(alpha: 0.5)
                  : AppColors.border,
          width: isCompleted ? 1.5 : 1.0,
        ),
        boxShadow: isCompleted
            ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.06),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                )
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onOpenDetail,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Category, Critical Warning, Streak, Strength
                Row(
                  children: [
                    // Icon Box
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: color.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        HabitIconHelper.getIcon(habit.iconCodePoint),
                        color: color,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Title & Category
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                habit.category,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: color,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              if (streak.isCriticalDay) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: AppColors.ruby.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: AppColors.ruby.withValues(alpha: 0.4),
                                    ),
                                  ),
                                  child: const Text(
                                    'قاعدة اليومين! ⚡',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.ruby,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            habit.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isCompleted
                                  ? AppColors.textPrimary
                                  : AppColors.textPrimary.withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Streak Flame & Strength
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Streak Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceElevated,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: streak.currentStreak > 0
                                    ? AppColors.gold.withValues(alpha: 0.3)
                                    : AppColors.border),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.local_fire_department,
                                size: 14,
                                color: streak.currentStreak > 0
                                    ? AppColors.gold
                                    : AppColors.textMuted,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                habit.type == HabitType.weeklyTarget
                                    ? '${streak.currentStreak} أسبوع'
                                    : '${streak.currentStreak} يوم',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: streak.currentStreak > 0
                                      ? AppColors.gold
                                      : AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Strength Pill
                        Text(
                          'قوة ${strength.toInt()}%',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: strength > 70
                                ? AppColors.emerald
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // Interactive Content by Type
                _buildTypeInteractiveRow(
                  context: context,
                  ref: ref,
                  record: record,
                  selectedDate: selectedDate,
                  color: color,
                  streak: streak,
                ),

                // Qualitative Tags
                if (habit.tagsAvailable.isNotEmpty &&
                    (isCompleted || habit.type == HabitType.binary)) ...[
                  const SizedBox(height: 10),
                  _buildTagsSelector(context, ref, record, selectedDate),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypeInteractiveRow({
    required BuildContext context,
    required WidgetRef ref,
    required HabitRecord record,
    required DateTime selectedDate,
    required Color color,
    required StreakResult streak,
  }) {
    final isCompleted = record.isCompleted;
    final isFrozen = record.isFrozen;

    switch (habit.type) {
      case HabitType.binary:
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Status phrase
            Text(
              isCompleted
                  ? 'تم الإنجاز بنجاح 🎯'
                  : isFrozen
                      ? 'السلسلة مجمدة ومحمية ❄️'
                      : 'بانتظار الإنجاز اليوم...',
              style: TextStyle(
                fontSize: 13,
                color: isCompleted
                    ? AppColors.emerald
                    : isFrozen
                        ? AppColors.freeze
                        : AppColors.textMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
            Row(
              children: [
                // Freeze Button
                IconButton(
                  icon: Icon(
                    isFrozen ? Icons.ac_unit : Icons.ac_unit_outlined,
                    color: isFrozen ? AppColors.freeze : AppColors.textMuted,
                    size: 20,
                  ),
                  tooltip: 'تجميد وحماية السلسلة',
                  onPressed: () {
                    AppHaptics.mediumImpact();
                    ref.read(recordsProvider.notifier).toggleFreeze(
                          habitId: habit.id,
                          date: selectedDate,
                        );
                  },
                ),
                // Complete Button
                ElevatedButton.icon(
                  onPressed: () {
                    AppHaptics.success();
                    ref.read(recordsProvider.notifier).toggleCompletion(
                          habit: habit,
                          date: selectedDate,
                        );
                  },
                  icon: Icon(
                    isCompleted ? Icons.check_circle : Icons.circle_outlined,
                    size: 18,
                    color: isCompleted ? Colors.black : color,
                  ),
                  label: Text(
                    isCompleted ? 'تم الإنجاز' : 'تسجيل إنجاز',
                    style: TextStyle(
                      color: isCompleted ? Colors.black : AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isCompleted ? AppColors.emerald : AppColors.surfaceElevated,
                    elevation: 0,
                    side: BorderSide(
                      color: isCompleted
                          ? AppColors.emerald
                          : AppColors.border,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );

      case HabitType.weeklyTarget:
        final currentCount = streak.currentWeekCount;
        final target = streak.targetWeeklyCount;
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'أسبوع: $currentCount من $target حصص',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  currentCount >= target
                      ? 'اكتمل هدف الأسبوع! 🔥'
                      : 'متبقي ${target - currentCount} حصص',
                  style: TextStyle(
                    fontSize: 11,
                    color: currentCount >= target
                        ? AppColors.gold
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            ElevatedButton.icon(
              onPressed: () {
                AppHaptics.success();
                ref.read(recordsProvider.notifier).toggleCompletion(
                      habit: habit,
                      date: selectedDate,
                    );
              },
              icon: Icon(
                isCompleted ? Icons.check_circle : Icons.add_task_rounded,
                size: 18,
                color: isCompleted ? Colors.black : color,
              ),
              label: Text(
                isCompleted ? 'تمت اليوم' : 'تسجيل حصة',
                style: TextStyle(
                  color: isCompleted ? Colors.black : AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isCompleted ? AppColors.emerald : AppColors.surfaceElevated,
                elevation: 0,
                side: BorderSide(
                  color: isCompleted ? AppColors.emerald : AppColors.border,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        );

      case HabitType.numeric:
        final currentVal = record.numericValue ?? 0.0;
        final targetVal = habit.targetNumericValue ?? 10.0;
        final unit = habit.numericUnit ?? '';
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${currentVal.toInt()} / ${targetVal.toInt()} $unit',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isCompleted ? 'تم إكمال الهدف! 🎯' : 'تقدم مستمر',
                  style: TextStyle(
                    fontSize: 11,
                    color: isCompleted ? AppColors.emerald : AppColors.textMuted,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                // Quick +step
                IconButton(
                  icon: const Icon(Icons.add_circle_outline,
                      color: AppColors.cyan),
                  onPressed: () {
                    AppHaptics.lightImpact();
                    final step = (targetVal / 5).clamp(1.0, 1000.0);
                    final nextVal = currentVal + step;
                    ref.read(recordsProvider.notifier).updateRecord(
                          record.copyWith(
                            numericValue: nextVal,
                            isCompleted: nextVal >= targetVal,
                            completedAt:
                                nextVal >= targetVal ? DateTime.now() : null,
                          ),
                        );
                  },
                ),
                ElevatedButton(
                  onPressed: () {
                    AppHaptics.success();
                    final nextCompleted = !isCompleted;
                    ref.read(recordsProvider.notifier).updateRecord(
                          record.copyWith(
                            numericValue: nextCompleted ? targetVal : 0.0,
                            isCompleted: nextCompleted,
                            completedAt: nextCompleted ? DateTime.now() : null,
                          ),
                        );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isCompleted ? AppColors.emerald : AppColors.surfaceElevated,
                    elevation: 0,
                    side: BorderSide(
                      color: isCompleted ? AppColors.emerald : AppColors.border,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    isCompleted ? 'مكتمل' : 'إتمام الهدف',
                    style: TextStyle(
                      color: isCompleted ? Colors.black : AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ],
        );

      case HabitType.duration:
        final currentMins = record.durationMinutes ?? 0;
        final targetMins = habit.targetDurationMinutes ?? 25;
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$currentMins من $targetMins دقيقة',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isCompleted ? 'أنجزت جلسة عميقة 🧘‍♂️' : 'جاهز للتركيز؟',
                  style: TextStyle(
                    fontSize: 11,
                    color:
                        isCompleted ? AppColors.purple : AppColors.textMuted,
                  ),
                ),
              ],
            ),
            ElevatedButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => FocusTimerDialog(
                    habitTitle: habit.title,
                    initialMinutes: targetMins,
                    onComplete: (minutesSpent) {
                      ref.read(recordsProvider.notifier).updateRecord(
                            record.copyWith(
                              durationMinutes: currentMins + minutesSpent,
                              isCompleted:
                                  (currentMins + minutesSpent) >= targetMins,
                              completedAt: DateTime.now(),
                            ),
                          );
                    },
                  ),
                );
              },
              icon: const Icon(Icons.timer_outlined,
                  size: 18, color: Colors.white),
              label: Text(
                isCompleted ? 'متابعة المؤقت' : 'بدء المؤقت',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.purple,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        );
    }
  }

  Widget _buildTagsSelector(
    BuildContext context,
    WidgetRef ref,
    HabitRecord record,
    DateTime selectedDate,
  ) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: habit.tagsAvailable.map((tag) {
          final isSelected = record.selectedTags.contains(tag);
          return Padding(
            padding: const EdgeInsets.only(left: 6.0),
            child: FilterChip(
              label: Text(tag),
              labelStyle: TextStyle(
                fontSize: 11,
                color: isSelected ? Colors.black : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              selected: isSelected,
              selectedColor: AppColors.emerald,
              backgroundColor: AppColors.surfaceElevated,
              side: BorderSide(
                color: isSelected
                    ? AppColors.emerald
                    : AppColors.border.withValues(alpha: 0.5),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              onSelected: (bool selected) {
                AppHaptics.selection();
                final currentTags = List<String>.from(record.selectedTags);
                if (selected) {
                  currentTags.add(tag);
                } else {
                  currentTags.remove(tag);
                }
                ref.read(recordsProvider.notifier).updateRecord(
                      record.copyWith(
                        selectedTags: currentTags,
                        isCompleted: true,
                        completedAt: record.completedAt ?? DateTime.now(),
                      ),
                    );
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}
