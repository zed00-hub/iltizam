import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/date_utils.dart';
import '../../domain/services/gamification_engine.dart';
import '../providers/habit_providers.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final commitmentIndex = ref.watch(overallCommitmentIndexProvider);
    final userLevel = ref.watch(userLevelProvider);
    final xp = ref.watch(totalXpProvider);
    final badges = ref.watch(achievementBadgesProvider);
    final habits = ref.watch(habitsProvider);
    final records = ref.watch(recordsProvider);

    // Calculate last 7 days daily completion counts for the chart
    final now = DateTime.now();
    final today = AppDateUtils.normalize(now);
    final recordMap = {for (var r in records) '${r.habitId}_${r.dateKey}': r};

    final List<double> last7DaysCompletions = [];
    final List<String> last7DaysLabels = [];

    for (int i = 6; i >= 0; i--) {
      final d = today.subtract(Duration(days: i));
      final dateKey = AppDateUtils.toKey(d);
      int count = 0;
      for (var h in habits) {
        if (recordMap['${h.id}_$dateKey']?.isCompleted ?? false) {
          count++;
        }
      }
      last7DaysCompletions.add(count.toDouble());
      last7DaysLabels.add(AppDateUtils.arabicDayName(d));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('التحليلات ومؤشر الدبابة 📊'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Tank Commitment Overview Banner
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.surface,
                  AppColors.surfaceElevated,
                ],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: userLevel.badgeColor.withOpacity(0.4),
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.shield,
                              color: userLevel.badgeColor, size: 20),
                          const SizedBox(width: 6),
                          Text(
                            'رتبتك: ${userLevel.titleArabic}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: userLevel.badgeColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        userLevel.subtitleArabic,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '$xp نقطة خبرة XP مُكتسبة',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.gold,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: userLevel.badgeColor.withOpacity(0.4),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${commitmentIndex.toInt()}%',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: userLevel.badgeColor,
                        ),
                      ),
                      const Text(
                        'الانضباط',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Weekly Consistency Bar Chart
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'نشاط آخر 7 أيام (إجمالي العادات المنجزة)',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Icon(Icons.bar_chart_rounded, color: AppColors.emerald),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 180,
                  child: BarChart(
                    BarChartData(
                      maxY: (habits.length + 1).toDouble().clamp(4.0, 20.0),
                      barTouchData: BarTouchData(
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipColor: (_) => AppColors.surfaceElevated,
                        ),
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 24,
                            getTitlesWidget: (val, meta) => Text(
                              val.toInt().toString(),
                              style: const TextStyle(
                                  color: AppColors.textMuted, fontSize: 10),
                            ),
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (val, meta) {
                              final idx = val.toInt();
                              if (idx >= 0 && idx < last7DaysLabels.length) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 6.0),
                                  child: Text(
                                    last7DaysLabels[idx].substring(0, 3),
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 11,
                                    ),
                                  ),
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (val) => FlLine(
                          color: AppColors.border.withOpacity(0.5),
                          strokeWidth: 1,
                        ),
                      ),
                      barGroups: List.generate(last7DaysCompletions.length, (i) {
                        return BarChartGroupData(
                          x: i,
                          barRods: [
                            BarChartRodData(
                              toY: last7DaysCompletions[i],
                              color: last7DaysCompletions[i] > 0
                                  ? AppColors.emerald
                                  : AppColors.surfaceElevated,
                              width: 18,
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(6)),
                            ),
                          ],
                        );
                      }),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Achievement Badges Section
          const Text(
            'أوسمة وشارات الإنجاز 🏅',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),

          ...badges.map((b) => _buildBadgeTile(b)),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildBadgeTile(AchievementBadge badge) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: badge.isUnlocked
              ? badge.color.withOpacity(0.5)
              : AppColors.border,
          width: badge.isUnlocked ? 1.4 : 1.0,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: badge.isUnlocked
                  ? badge.color.withOpacity(0.15)
                  : AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: badge.isUnlocked ? badge.color : AppColors.border,
              ),
            ),
            child: Icon(
              badge.icon,
              color: badge.isUnlocked ? badge.color : AppColors.textMuted,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      badge.titleArabic,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: badge.isUnlocked
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                      ),
                    ),
                    if (badge.isUnlocked)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: badge.color.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'مُكتمل 🏅',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: badge.color,
                          ),
                        ),
                      )
                    else
                      Text(
                        '${(badge.progress * 100).toInt()}%',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textMuted,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  badge.descriptionArabic,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
                if (!badge.isUnlocked) ...[
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: badge.progress,
                      minHeight: 4,
                      backgroundColor: AppColors.surfaceElevated,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(badge.color),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
