import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/haptics.dart';
import '../providers/habit_providers.dart';
import '../widgets/habit_card.dart';
import '../widgets/habit_form_dialog.dart';
import '../widgets/progress_ring_header.dart';
import '../widgets/rank_badge_widget.dart';
import 'habit_detail_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  String _selectedCategory = 'الكل';

  @override
  Widget build(BuildContext context) {
    final habits = ref.watch(habitsProvider);
    final activeHabits = habits.where((h) => !h.isArchived).toList();

    // Extract categories
    final categories = ['الكل', ...activeHabits.map((h) => h.category).toSet()];

    final filteredHabits = _selectedCategory == 'الكل'
        ? activeHabits
        : activeHabits.where((h) => h.category == _selectedCategory).toList();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.emerald.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.shield_rounded,
                  color: AppColors.emerald, size: 22),
            ),
            const SizedBox(width: 10),
            const Text(
              'التـزام',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 22,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded,
                color: AppColors.emerald, size: 28),
            tooltip: 'إضافة عادة جديدة',
            onPressed: () {
              AppHaptics.selection();
              showDialog(
                context: context,
                builder: (ctx) => HabitFormDialog(
                  onSave: (newHabit) {
                    ref.read(habitsProvider.notifier).addHabit(newHabit);
                  },
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.read(habitsProvider.notifier).refresh();
          ref.read(recordsProvider.notifier).refresh();
        },
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          children: [
            // User Rank & XP
            const RankBadgeWidget(),
            const SizedBox(height: 14),

            // Daily Progress Ring & Date Picker
            const ProgressRingHeader(),
            const SizedBox(height: 18),

            // Category Filter Pills
            if (categories.length > 2) ...[
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: categories.map((cat) {
                    final isSel = _selectedCategory == cat;
                    return Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: FilterChip(
                        label: Text(cat),
                        selected: isSel,
                        selectedColor: AppColors.emerald,
                        backgroundColor: AppColors.surface,
                        labelStyle: TextStyle(
                          color: isSel ? Colors.black : AppColors.textSecondary,
                          fontWeight:
                              isSel ? FontWeight.bold : FontWeight.normal,
                          fontSize: 12,
                        ),
                        side: BorderSide(
                          color: isSel ? AppColors.emerald : AppColors.border,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        onSelected: (val) {
                          if (val) {
                            setState(() => _selectedCategory = cat);
                          }
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 14),
            ],

            // Habits Section Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'عاداتك اليومية',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  '${filteredHabits.length} عادات نشطة',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Habits List
            if (filteredHabits.isEmpty)
              Container(
                padding: const EdgeInsets.all(32),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.checklist_rounded,
                        size: 48, color: AppColors.textMuted),
                    const SizedBox(height: 12),
                    const Text(
                      'لا توجد عادات مسجلة بعد',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'اضغط على زر الإضافة وابدأ أول خطوة لبناء دبابة التزامك!',
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => HabitFormDialog(
                            onSave: (newHabit) {
                              ref
                                  .read(habitsProvider.notifier)
                                  .addHabit(newHabit);
                            },
                          ),
                        );
                      },
                      icon: const Icon(Icons.add, color: Colors.black),
                      label: const Text('إضافة أول عادة',
                          style: TextStyle(
                              color: Colors.black, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.emerald,
                      ),
                    ),
                  ],
                ),
              )
            else
              ...filteredHabits.map((habit) {
                return HabitCard(
                  key: ValueKey(habit.id),
                  habit: habit,
                  onOpenDetail: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => HabitDetailScreen(habitId: habit.id),
                      ),
                    );
                  },
                );
              }),

            const SizedBox(height: 40),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.emerald,
        foregroundColor: Colors.black,
        elevation: 6,
        onPressed: () {
          AppHaptics.selection();
          showDialog(
            context: context,
            builder: (ctx) => HabitFormDialog(
              onSave: (newHabit) {
                ref.read(habitsProvider.notifier).addHabit(newHabit);
              },
            ),
          );
        },
        child: const Icon(Icons.add_rounded, size: 30),
      ),
    );
  }
}
