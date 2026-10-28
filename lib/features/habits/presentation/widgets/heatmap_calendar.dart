import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/date_utils.dart';
import '../../domain/models/habit.dart';
import '../../domain/models/habit_record.dart';

class HeatmapCalendar extends StatelessWidget {
  final Habit habit;
  final List<HabitRecord> records;
  final int weeksToShow;

  const HeatmapCalendar({
    super.key,
    required this.habit,
    required this.records,
    this.weeksToShow = 14,
  });

  @override
  Widget build(BuildContext context) {
    final recordMap = {for (var r in records) r.dateKey: r};
    final now = DateTime.now();
    final today = AppDateUtils.normalize(now);

    final totalDays = weeksToShow * 7;
    final startDay = today
        .subtract(Duration(days: totalDays))
        .subtract(Duration(days: today.weekday - 1));

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
              const Text(
                'خريطة الالتزام والمربعات (Activity Grid)',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Row(
                children: [
                  _buildLegendItem('مكتمل', AppColors.emerald),
                  const SizedBox(width: 8),
                  _buildLegendItem('مجمد', AppColors.freeze),
                  const SizedBox(width: 8),
                  _buildLegendItem('فائت', AppColors.surfaceElevated),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Horizontal scrollable grid
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            reverse: true,
            child: Row(
              children: List.generate(weeksToShow, (weekIdx) {
                return Column(
                  children: List.generate(7, (dayIdx) {
                    final cellDate = startDay
                        .add(Duration(days: (weekIdx * 7) + dayIdx));
                    final isFuture = cellDate.isAfter(today);
                    final key = AppDateUtils.toKey(cellDate);
                    final rec = recordMap[key];
                    final isDue = habit.scheduledDays.contains(cellDate.weekday);

                    Color cellColor;
                    Border? border;

                    if (isFuture) {
                      cellColor = Colors.transparent;
                    } else if (!isDue) {
                      cellColor = AppColors.background.withValues(alpha: 0.4);
                    } else if (rec != null && rec.isCompleted) {
                      cellColor = AppColors.emerald;
                    } else if (rec != null && rec.isFrozen) {
                      cellColor = AppColors.freeze;
                    } else {
                      cellColor = AppColors.surfaceElevated;
                      border = Border.all(
                        color: AppColors.border.withValues(alpha: 0.8),
                        width: 1,
                      );
                    }

                    return Tooltip(
                      message:
                          '${AppDateUtils.toKey(cellDate)}: ${rec?.isCompleted == true ? "مكتمل 🎯" : rec?.isFrozen == true ? "مجمد ❄️" : "لم يكتمل"}',
                      child: Container(
                        width: 15,
                        height: 15,
                        margin: const EdgeInsets.all(2.5),
                        decoration: BoxDecoration(
                          color: cellColor,
                          borderRadius: BorderRadius.circular(3.5),
                          border: border,
                        ),
                      ),
                    );
                  }),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
        ),
      ],
    );
  }
}
