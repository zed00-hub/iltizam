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

  void _editProfileDialog() {
    final profile = ref.read(profileProvider);
    final controller = TextEditingController(text: profile.displayName);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('تعديل الملف الشخصي'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: 'اسمك الشخصي',
                filled: true,
                fillColor: AppColors.surfaceElevated,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
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
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.emerald),
            child: const Text('حفظ',
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            onPressed: () async {
              final dialogNav = Navigator.of(ctx);
              final newName = controller.text.trim();
              await ref
                  .read(profileProvider.notifier)
                  .updateProfile(profile.copyWith(displayName: newName));
              dialogNav.pop();
            },
          ),
        ],
      ),
    );
  }

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
              'تم إنشاء نسخة احتياطية لكافة بياناتك الفعلية. يمكنك نسخها والاحتفاظ بها بأمان:',
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
        title: const Text('استيراد نسخة احتياطية'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'الصق كود الـ JSON الخاص بالنسخة الاحتياطية لفحصها واستعادتها:',
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
            child: const Text('فحص ومعاينة',
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            onPressed: () {
              final raw = controller.text.trim();
              if (raw.isEmpty) return;

              final repo = ref.read(habitRepositoryProvider);
              final inspection = repo.inspectBackup(raw);

              if (inspection == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('الملف غير صالح أو لا ينتمي لتطبيق التزام ❌'),
                    backgroundColor: AppColors.ruby,
                  ),
                );
                return;
              }

              Navigator.pop(ctx);
              _showRestorePreviewModal(inspection);
            },
          ),
        ],
      ),
    );
  }

  void _showRestorePreviewModal(Map<String, dynamic> inspection) {
    final habitCount = inspection['habitCount'] as int;
    final recordCount = inspection['recordCount'] as int;
    final exportedAt = inspection['exportedAt'] as String;
    final backupData = inspection['data'] as Map<String, dynamic>;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('معاينة النسخة الاحتياطية 📋'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('عدد العادات بالملف:'),
                      Text('$habitCount عادات',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('عدد السجلات:'),
                      Text('$recordCount سجل',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  if (exportedAt.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('تاريخ النسخ:'),
                        Text(
                          exportedAt.substring(0, 10),
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'اختر طريقة الاستعادة المناسبة:',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          // Smart Merge Button
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.cyan),
            ),
            onPressed: () async {
              final nav = Navigator.of(ctx);
              final messenger = ScaffoldMessenger.of(context);
              final repo = ref.read(habitRepositoryProvider);

              final success = await repo.restoreMerge(backupData);
              nav.pop();
              if (success) {
                ref.read(habitsProvider.notifier).refresh();
                ref.read(recordsProvider.notifier).refresh();
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('تم الدمج الذكي للبيانات بنجاح! 🚀'),
                    backgroundColor: AppColors.emerald,
                  ),
                );
              }
            },
            child: const Text('دمج ذكي (Merge)',
                style: TextStyle(color: AppColors.cyan)),
          ),

          // Full Replace Button
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.ruby,
            ),
            onPressed: () async {
              final nav = Navigator.of(ctx);
              final messenger = ScaffoldMessenger.of(context);
              final repo = ref.read(habitRepositoryProvider);

              final success = await repo.restoreReplace(backupData);
              nav.pop();
              if (success) {
                ref.read(habitsProvider.notifier).refresh();
                ref.read(recordsProvider.notifier).refresh();
                ref.invalidate(profileProvider);
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('تم استبدال البيانات بالكامل بنجاح! ✅'),
                    backgroundColor: AppColors.emerald,
                  ),
                );
              }
            },
            child: const Text('استبدال شامل (Replace)',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _clearDataDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('بدء جديد ومسح البيانات ⚠️'),
        content: const Text(
          'هل تريد مسح جميع العادات والسجلات المحلية والبدء من جديد بلوحة فارغة؟ لا يمكن التراجع عن هذه الخطوة إلا عبر استيراد نسخة احتياطية.',
          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            child: const Text('إلغاء'),
            onPressed: () => Navigator.pop(ctx),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.ruby),
            child: const Text('مسح وبدء جديد',
                style: TextStyle(color: Colors.white)),
            onPressed: () async {
              final nav = Navigator.of(ctx);
              final messenger = ScaffoldMessenger.of(context);
              final repo = ref.read(habitRepositoryProvider);

              await repo.clearAll();
              ref.read(habitsProvider.notifier).refresh();
              ref.read(recordsProvider.notifier).refresh();
              nav.pop();

              messenger.showSnackBar(
                const SnackBar(
                  content: Text('تمت تهيئة البيانات بنجاح، اللوحة الآن فارغة وجاهزة 🛡️'),
                  backgroundColor: AppColors.emerald,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('الإعدادات والملف الشخصي ⚙️'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Profile Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.emerald.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.emerald),
                  ),
                  child: const Icon(Icons.person, color: AppColors.emerald, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile.displayName.isEmpty
                            ? 'بطل الالتزام'
                            : profile.displayName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'عضو منذ: ${profile.joinedDate.year}/${profile.joinedDate.month}/${profile.joinedDate.day}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined,
                      color: AppColors.textSecondary),
                  tooltip: 'تعديل الاسم',
                  onPressed: _editProfileDialog,
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
                  title: const Text('موجز الصباح للتخطيط'),
                  subtitle: Text(
                      'تذكير عند ${profile.preferredWakeTime ?? "05:00 ص"} لبدء اليوم بقوة'),
                  value: _morningBriefEnabled,
                  activeColor: AppColors.emerald,
                  onChanged: (val) {
                    AppHaptics.selection();
                    setState(() => _morningBriefEnabled = val);
                  },
                ),
                const Divider(height: 1, color: AppColors.border),
                SwitchListTile(
                  title: const Text('مراجعة المساء وإغلاق السلاسل'),
                  subtitle: Text(
                      'تذكير عند ${profile.preferredSleepTime ?? "10:00 م"} لحماية سلاسلك قبل النوم'),
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
                  subtitle: const Text('تصدير بياناتك الفعلية بملف محلي آمن'),
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
                      const Text('معاينة واستعادة البيانات (استبدال أو دمج)'),
                  trailing: const Icon(Icons.chevron_left,
                      color: AppColors.textMuted),
                  onTap: _importBackup,
                ),
                const Divider(height: 1, color: AppColors.border),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.ruby.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.delete_sweep_outlined,
                        color: AppColors.ruby),
                  ),
                  title: const Text('بدء جديد (مسح كافة البيانات)',
                      style: TextStyle(color: AppColors.ruby)),
                  subtitle: const Text('تفريغ اللوحة والبدء من الصفر'),
                  onTap: _clearDataDialog,
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
