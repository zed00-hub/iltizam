import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/date_utils.dart';
import '../../domain/models/habit.dart';
import '../../domain/models/habit_type.dart';
import '../providers/habit_providers.dart';
import '../widgets/habit_form_dialog.dart';
import '../widgets/heatmap_calendar.dart';

class HabitDetailScreen extends ConsumerWidget {
  final String habitId;

  const HabitDetailScreen({super.key, required this.habitId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habits = ref.watch(habitsProvider);
    final habit = habits.firstWhere(
      (h) => h.id == habitId,
      orElse: () => Habit(
        id: '',
        title: 'غير موجودة',
        type: HabitType.binary,
        createdAt: DateTime.now(),
      ),
    );

    if (habit.id.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('خطأ')),
        body: const Center(child: Text('لم يتم العثور على العادة')),
      );
    }

    final records = ref.watch(recordsProvider);
    final streak = ref.watch(habitStreakProvider(habit));
    final strength = ref.watch(habitStrengthProvider(habit));
    final habitRecords = records.where((r) => r.habitId == habit.id).toList()
      ..sort((a, b) => b.dateKey.compareTo(a.dateKey));

    final color = Color(habit.colorValue);

    // Calculate tag breakdown (e.g. 15 times in mosque, 2 at home)
    final tagCounts = <String, int>{};
    for (var r in habitRecords) {
      if (r.isCompleted) {
        for (var t in r.selectedTags) {
          tagCounts[t] = (tagCounts[t] ?? 0) + 1;
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(habit.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'تعديل العادة',
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => HabitFormDialog(
                  existingHabit: habit,
                  onSave: (updated) {
                    ref.read(habitsProvider.notifier).updateHabit(updated);
                  },
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.ruby),
            tooltip: 'حذف العادة',
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: AppColors.surface,
                  title: const Text('تأكيد الحذف'),
                  content: const Text(
                      'هل أنت متأكد من حذف هذه العادة وجميع سجلاتها التاريخية؟'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('إلغاء'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.ruby,
                      ),
                      child: const Text('حذف نهائي',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              );

              if (confirm == true && context.mounted) {
                await ref.read(habitsProvider.notifier).deleteHabit(habit.id);
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Top Stats Grid
          Row(
            children: [
              // Current Streak
              Expanded(
                child: _buildMetricCard(
                  title: 'السلسلة الحالية',
                  value: habit.type == HabitType.weeklyTarget
                      ? '${streak.currentStreak} أسبوع'
                      : '${streak.currentStreak} يوم',
                  icon: Icons.local_fire_department,
                  accentColor: AppColors.gold,
                  subtitle: 'مستمر بثبات',
                ),
              ),
              const SizedBox(width: 12),
              // Best Streak
              Expanded(
                child: _buildMetricCard(
                  title: 'أفضل سلسلة تاريخية',
                  value: habit.type == HabitType.weeklyTarget
                      ? '${streak.bestStreak} أسبوع'
                      : '${streak.bestStreak} يوم',
                  icon: Icons.military_tech,
                  accentColor: AppColors.emerald,
                  subtitle: 'الرقم القياسي لك 🏆',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              // Habit Strength Score
              Expanded(
                child: _buildMetricCard(
                  title: 'قوة العادة التراكمية',
                  value: '${strength.toInt()}%',
                  icon: Icons.shield,
                  accentColor: color,
                  subtitle: 'معادلة الزخم الزمني',
                ),
              ),
              const SizedBox(width: 12),
              // Total Completions
              Expanded(
                child: _buildMetricCard(
                  title: 'إجمالي الإنجازات',
                  value: '${streak.totalCompleted}',
                  icon: Icons.check_circle,
                  accentColor: AppColors.cyan,
                  subtitle: 'مرة تم تسجيلها',
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Activity Grid / Heatmap
          HeatmapCalendar(habit: habit, records: records),
          const SizedBox(height: 20),

          // Qualitative Tags Breakdown
          if (tagCounts.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'تحليل تفصيلي للوسوم النوعية (Deep Breakdown)',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: tagCounts.entries.map((e) {
                      final ratio = streak.totalCompleted > 0
                          ? ((e.value / streak.totalCompleted) * 100).toInt()
                          : 0;
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceElevated,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.border,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              e.key,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.emerald.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '${e.value} مرة ($ratio%)',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.emerald,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Historical Logs Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'سجل الريكوردات التاريخي',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '${habitRecords.length} سجلات',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Records List
          if (habitRecords.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Text('لا توجد سجلات مسجلة لهذه العادة حتى الآن'),
              ),
            )
          else
            ...habitRecords.map((r) {
              final d = AppDateUtils.fromKey(r.dateKey);
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: r.isCompleted
                        ? AppColors.emerald.withOpacity(0.3)
                        : r.isFrozen
                            ? AppColors.freeze.withOpacity(0.3)
                            : AppColors.border,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      r.isCompleted
                          ? Icons.check_circle
                          : r.isFrozen
                              ? Icons.ac_unit
                              : Icons.cancel_outlined,
                      color: r.isCompleted
                          ? AppColors.emerald
                          : r.isFrozen
                              ? AppColors.freeze
                              : AppColors.textMuted,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppDateUtils.formatHeaderArabic(d),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          if (r.selectedTags.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              r.selectedTags.join(' • '),
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.emerald,
                              ),
                            ),
                          ],
                          if (r.stumbleReason != null &&
                              r.stumbleReason!.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              'ملاحظة تعثر: ${r.stumbleReason}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.ruby,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (r.durationMinutes != null && r.durationMinutes! > 0)
                      Text(
                        '${r.durationMinutes} دقيقة',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.purple,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    else if (r.numericValue != null && r.numericValue! > 0)
                      Text(
                        '${r.numericValue!.toInt()} ${habit.numericUnit ?? ""}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.cyan,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              );
            }),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color accentColor,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Icon(icon, color: accentColor, size: 20),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: accentColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
