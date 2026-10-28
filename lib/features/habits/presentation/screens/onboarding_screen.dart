import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/haptics.dart';
import '../providers/habit_providers.dart';
import '../../../main_navigation_screen.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  final TextEditingController _nameController = TextEditingController();
  String _wakeTime = '05:00 ص';
  String _sleepTime = '10:00 م';
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _finishOnboarding() async {
    AppHaptics.success();
    final name = _nameController.text.trim();
    await ref.read(profileProvider.notifier).completeOnboarding(
          name,
          wakeTime: _wakeTime,
          sleepTime: _sleepTime,
        );

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        actions: [
          TextButton(
            onPressed: _finishOnboarding,
            child: const Text(
              'تخطي البدء السريع',
              style: TextStyle(
                color: AppColors.textMuted,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (page) => setState(() => _currentPage = page),
                children: [
                  _buildWelcomePage(),
                  _buildProfilePage(),
                ],
              ),
            ),

            // Page Indicator & Bottom Button
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Dot indicators
                  Row(
                    children: List.generate(2, (index) {
                      final isSel = _currentPage == index;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(left: 6),
                        width: isSel ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: isSel ? AppColors.emerald : AppColors.surfaceElevated,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),

                  // Next / Finish Button
                  ElevatedButton.icon(
                    onPressed: () {
                      AppHaptics.selection();
                      if (_currentPage == 0) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 350),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        _finishOnboarding();
                      }
                    },
                    icon: Icon(
                      _currentPage == 0
                          ? Icons.arrow_back_rounded // RTL points backwards for next
                          : Icons.check_circle_rounded,
                      color: Colors.black,
                      size: 20,
                    ),
                    label: Text(
                      _currentPage == 0 ? 'متابعة' : 'ادخل إلى التـزام 🛡️',
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.emerald,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomePage() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Logo Badge
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: AppColors.emerald.withValues(alpha: 0.5),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.emerald.withValues(alpha: 0.15),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(
              Icons.shield_rounded,
              color: AppColors.emerald,
              size: 50,
            ),
          ),
          const SizedBox(height: 28),

          const Text(
            'التـزام',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'محرك بناء العادات والانضباط الحديدي',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: AppColors.gold,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),

          // Pillars cards
          _buildPillarRow(
            icon: Icons.local_fire_department,
            color: AppColors.gold,
            title: 'سلاسل التزام مستمرة',
            subtitle: 'تتبع يومي وأسبوعي يحسب أيامك المستحقة بدقة دون ظلم',
          ),
          const SizedBox(height: 12),
          _buildPillarRow(
            icon: Icons.shield,
            color: AppColors.cyan,
            title: 'قوة العادة وقاعدة اليومين',
            subtitle: 'معادلة زخم ذكية تمنع انهيار جهدك وتساعدك على العودة الفورية',
          ),
          const SizedBox(height: 12),
          _buildPillarRow(
            icon: Icons.lock_outline_rounded,
            color: AppColors.emerald,
            title: 'محلي وخاص 100% (Offline-First)',
            subtitle: 'بياناتك ملكك بالكامل ومحفوظة على جهازك فقط دون استهلاك إنترنت',
          ),
        ],
      ),
    );
  }

  Widget _buildProfilePage() {
    return ListView(
      padding: const EdgeInsets.all(24.0),
      children: [
        const SizedBox(height: 10),
        const Text(
          'تخصيص تجربتك الشخصية',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'يمكنك كتابة اسمك لتخصيص لوحة القيادة والتنبيهات، أو تركه فارغاً',
          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 24),

        // Name Field
        TextFormField(
          controller: _nameController,
          decoration: InputDecoration(
            labelText: 'الاسم الشخصي (اختياري)',
            hintText: 'مثال: البطل، أحمد، محمد...',
            prefixIcon: const Icon(Icons.person_outline, color: AppColors.emerald),
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.border),
            ),
          ),
        ),
        const SizedBox(height: 24),

        const Text(
          'أوقات التركيز المقترحة ليومك:',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),

        // Wake Time Card
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.wb_sunny_outlined, color: AppColors.gold, size: 22),
                  SizedBox(width: 12),
                  Text('الاستيقاظ وبداية اليوم',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                ],
              ),
              DropdownButton<String>(
                value: _wakeTime,
                dropdownColor: AppColors.surfaceElevated,
                underline: const SizedBox(),
                items: ['04:30 ص', '05:00 ص', '06:00 ص', '07:00 ص'].map((t) {
                  return DropdownMenuItem(value: t, child: Text(t));
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _wakeTime = val);
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Sleep Time Card
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.bedtime_outlined, color: AppColors.purple, size: 22),
                  SizedBox(width: 12),
                  Text('مراجعة المساء والنوم',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                ],
              ),
              DropdownButton<String>(
                value: _sleepTime,
                dropdownColor: AppColors.surfaceElevated,
                underline: const SizedBox(),
                items: ['09:30 م', '10:00 م', '11:00 م', '12:00 ص'].map((t) {
                  return DropdownMenuItem(value: t, child: Text(t));
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _sleepTime = val);
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.emerald.withValues(alpha: 0.2)),
          ),
          child: const Row(
            children: [
              Icon(Icons.info_outline, color: AppColors.emerald, size: 20),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'ستبدأ بلوحة نظيفة تماماً، ويمكنك إضافة عاداتك الخاصة من الصفر أو استعراض قوالب جاهزة عند الحاجة.',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPillarRow({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
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
    );
  }
}
