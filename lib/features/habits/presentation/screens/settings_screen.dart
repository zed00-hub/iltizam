import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/haptics.dart';
import '../providers/habit_providers.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _morningBriefEnabled = true;
  bool _eveningDebriefEnabled = true;

  void _exportBackup() {
    AppHaptics.success();
    final repo = ref.read(habitRepositoryProvider);
    final jsonStr = repo.exportBackup();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('النسخة الاحتياطية (JSON)'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'تم إنشاء نسخة احتياطية كاملة لكافة عاداتك وسجلاتك. يمكنك نسخها والاحتفاظ بها بأمان:',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            Container(
              height: 140,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: SingleChildScrollView(
                child: SelectableText(
                  jsonStr,
                  style: const TextStyle(
                      fontFamily: 'monospace', fontSize: 11),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.copy, size: 18),
            label: const Text('نسخ إلى الحافظة'),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: jsonStr));
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم نسخ بياناتك الاحتياطية بنجاح ✅'),
                  backgroundColor: AppColors.emerald,
                ),
              );
            },
          ),
          TextButton(
            child: const Text('إغلاق'),
            onPressed: () => Navigator.pop(ctx),
          ),
        ],
      ),
    );
  }

  void _importBackup() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('استعادة نسخة احتياطية'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'الصق كود JSON الخاص بنسختك الاحتياطية هنا لاستعادة جميع العادات:',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: '{"app": "Eltizam", ...}',
                filled: true,
                fillColor: AppColors.surfaceElevated,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text('إلغاء'),
            onPressed: () => Navigator.pop(ctx),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.emerald,
            ),
            child: const Text('استعادة الآن',
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            onPressed: () async {
              if (controller.text.trim().isEmpty) return;
              final messenger = ScaffoldMessenger.of(context);
              final dialogNav = Navigator.of(ctx);
              final repo = ref.read(habitRepositoryProvider);
              final success = await repo.importBackup(controller.text.trim());

              dialogNav.pop();
              if (success) {
                ref.read(habitsProvider.notifier).refresh();
                ref.read(recordsProvider.notifier).refresh();
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('تمت استعادة البيانات بنجاح! 🚀'),
                    backgroundColor: AppColors.emerald,
                  ),
                );
              } else {
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('فشلت الاستعادة: صيغة الكود غير صحيحة ❌'),
                    backgroundColor: AppColors.ruby,
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الإعدادات والنسخ الاحتياطي ⚙️'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Manifesto Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.emerald.withValues(alpha: 0.3),
              ),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.local_fire_department,
                        color: AppColors.gold, size: 24),
                    SizedBox(width: 8),
                    Text(
                      'مانيفستو "دبابة التزام"',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  'التزام ليس مجرد تطبيق لمربعات الاختيار، بل هو نظام حياة لتحويلك إلى قوة لا تُقهر. السلاسل تُبنى يوماً بيوم، والتعثر عارض لا يهدم عزيمتك، وقاعدة اليومين تحميك دائماً من التراجع.',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Smart Notifications Section
          const Text(
            'التنبيهات والموجز الذكي',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('موجز الصباح الذكي (05:00 ص)'),
                  subtitle: const Text(
                      'تذكير لصلاة الفجر في المسجد واستعراض خطة اليوم'),
                  value: _morningBriefEnabled,
                  activeColor: AppColors.emerald,
                  onChanged: (val) {
                    AppHaptics.selection();
                    setState(() => _morningBriefEnabled = val);
                  },
                ),
                const Divider(height: 1, color: AppColors.border),
                SwitchListTile(
                  title: const Text('مراجعة المساء وإغلاق السلاسل (10:00 م)'),
                  subtitle: const Text(
                      'تذكير لحماية سلاسلك وتأكيد إنجازات اليوم قبل النوم'),
                  value: _eveningDebriefEnabled,
                  activeColor: AppColors.emerald,
                  onChanged: (val) {
                    AppHaptics.selection();
                    setState(() => _eveningDebriefEnabled = val);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Backup & Restore Section
          const Text(
            'حفظ البيانات والأمان المحلي (Offline-first)',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.emerald.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.file_download_outlined,
                        color: AppColors.emerald),
                  ),
                  title: const Text('تصدير نسخة احتياطية (JSON)'),
                  subtitle: const Text('حفظ جميع عاداتك وسجلاتك بملف محلي آمن'),
                  trailing: const Icon(Icons.chevron_left,
                      color: AppColors.textMuted),
                  onTap: _exportBackup,
                ),
                const Divider(height: 1, color: AppColors.border),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.cyan.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.file_upload_outlined,
                        color: AppColors.cyan),
                  ),
                  title: const Text('استيراد نسخة احتياطية'),
                  subtitle:
                      const Text('استعادة عاداتك وبياناتك السابقة فوراً'),
                  trailing: const Icon(Icons.chevron_left,
                      color: AppColors.textMuted),
                  onTap: _importBackup,
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),

          // App Info
          const Center(
            child: Column(
              children: [
                Text(
                  'التـزام v1.0.0',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textMuted,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'صُمم للوصول إلى أعلى مستويات الانضباط الشخصي 🛡️',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
