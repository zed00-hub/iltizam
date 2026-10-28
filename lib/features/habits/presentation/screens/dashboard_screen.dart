import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/haptics.dart';
import '../providers/habit_providers.dart';
import '../widgets/habit_card.dart';
import '../widgets/habit_form_dialog.dart';
import '../widgets/habit_templates_sheet.dart';
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

  void _showAddHabitOptions(BuildContext context) {
    AppHaptics.selection();
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Text(
                'إضافة عادة جديدة',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.emerald.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.edit_note_rounded,
                      color: AppColors.emerald),
                ),
                title: const Text('إنشاء عادة مخصصة من الصفر',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('حدد الاسم والنوع والأهداف كما يناسبك تماماً'),
                onTap: () {
                  Navigator.pop(ctx);
                  showDialog(
                    context: context,
                    builder: (dCtx) => HabitFormDialog(
                      onSave: (newHabit) {
                        ref.read(habitsProvider.notifier).addHabit(newHabit);
                      },
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.auto_stories_rounded,
                      color: AppColors.gold),
                ),
                title: const Text('استعراض مكتبة القوالب الجاهزة',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('اختر من قوالب العبادات، الرياضة، والتطوير'),
                onTap: () {
                  Navigator.pop(ctx);
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => const HabitTemplatesSheet(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final habits = ref.watch(habitsProvider);
    final profile = ref.watch(profileProvider);
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
                color: AppColors.emerald.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.shield_rounded,
                  color: AppColors.emerald, size: 22),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'التـزام',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                    letterSpacing: 0.5,
                  ),
                ),
                if (profile.displayName.isNotEmpty)
                  Text(
                    'مرحباً ${profile.displayName} 👋',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded,
                color: AppColors.emerald, size: 28),
            tooltip: 'إضافة عادة جديدة',
            onPressed: () => _showAddHabitOptions(context),
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

            // Habits List / Empty State
            if (activeHabits.isEmpty)
              Container(
                padding: const EdgeInsets.all(28),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppColors.emerald.withValues(alpha: 0.25),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.emerald.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.track_changes_rounded,
                        size: 44,
                        color: AppColors.emerald,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'أهلاً بك في التـزام 🛡️',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'لوحتك نظيفة ومستعدة لتبدأ رحلتك الخاصة.\nأنشئ عادتك الأولى أو استكشف قوالب جاهزة ملهمة!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
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
                          icon: const Icon(Icons.add, color: Colors.black, size: 18),
                          label: const Text('عادة من الصفر',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.emerald,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        OutlinedButton.icon(
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (_) => const HabitTemplatesSheet(),
                            );
                          },
                          icon: const Icon(Icons.auto_stories_rounded,
                              color: AppColors.gold, size: 18),
                          label: const Text('قوالب مقترحة',
                              style: TextStyle(
                                  color: AppColors.gold,
                                  fontWeight: FontWeight.bold)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.gold),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
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
        onPressed: () => _showAddHabitOptions(context),
        child: const Icon(Icons.add_rounded, size: 30),
      ),
    );
  }
}
