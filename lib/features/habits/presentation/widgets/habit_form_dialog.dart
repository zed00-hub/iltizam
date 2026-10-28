import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/haptics.dart';
import '../../domain/models/habit.dart';
import '../../domain/models/habit_type.dart';

class HabitFormDialog extends StatefulWidget {
  final Habit? existingHabit;
  final Function(Habit habit) onSave;

  const HabitFormDialog({
    super.key,
    this.existingHabit,
    required this.onSave,
  });

  @override
  State<HabitFormDialog> createState() => _HabitFormDialogState();
}

class _HabitFormDialogState extends State<HabitFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _categoryController;
  late TextEditingController _tagsController;
  late TextEditingController _unitController;
  late TextEditingController _targetValController;

  late HabitType _selectedType;
  late int _colorValue;
  late int _iconCodePoint;
  late int _weeklyFrequency;
  late int _durationMinutes;
  late List<int> _scheduledDays;

  final List<Color> _availableColors = [
    AppColors.emerald,
    AppColors.gold,
    AppColors.cyan,
    AppColors.purple,
    AppColors.blue,
    AppColors.ruby,
    AppColors.orange,
  ];

  final List<IconData> _availableIcons = [
    Icons.mosque_rounded,
    Icons.fitness_center_rounded,
    Icons.menu_book_rounded,
    Icons.timer_rounded,
    Icons.water_drop_rounded,
    Icons.run_circle_outlined,
    Icons.bedtime_rounded,
    Icons.code_rounded,
    Icons.psychology_rounded,
    Icons.star_rounded,
  ];

  @override
  void initState() {
    super.initState();
    final h = widget.existingHabit;
    _titleController = TextEditingController(text: h?.title ?? '');
    _descController = TextEditingController(text: h?.description ?? '');
    _categoryController = TextEditingController(text: h?.category ?? 'عام');
    _tagsController =
        TextEditingController(text: h?.tagsAvailable.join(', ') ?? '');
    _unitController = TextEditingController(text: h?.numericUnit ?? 'تكرار');
    _targetValController = TextEditingController(
      text: h?.targetNumericValue?.toString() ?? '10',
    );

    _selectedType = h?.type ?? HabitType.binary;
    _colorValue = h?.colorValue ?? AppColors.emerald.value;
    _iconCodePoint = h?.iconCodePoint ?? Icons.star_rounded.codePoint;
    _weeklyFrequency = h?.targetWeeklyFrequency ?? 4;
    _durationMinutes = h?.targetDurationMinutes ?? 30;
    _scheduledDays = h != null
        ? List<int>.from(h.scheduledDays)
        : [1, 2, 3, 4, 5, 6, 7];
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _categoryController.dispose();
    _tagsController.dispose();
    _unitController.dispose();
    _targetValController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    AppHaptics.success();

    final tags = _tagsController.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    final habit = Habit(
      id: widget.existingHabit?.id ?? const Uuid().v4(),
      title: _titleController.text.trim(),
      description: _descController.text.trim().isEmpty
          ? null
          : _descController.text.trim(),
      category: _categoryController.text.trim().isEmpty
          ? 'عام'
          : _categoryController.text.trim(),
      type: _selectedType,
      iconCodePoint: _iconCodePoint,
      colorValue: _colorValue,
      tagsAvailable: tags,
      targetWeeklyFrequency: _selectedType == HabitType.weeklyTarget
          ? _weeklyFrequency
          : null,
      targetNumericValue: _selectedType == HabitType.numeric
          ? double.tryParse(_targetValController.text) ?? 10
          : null,
      numericUnit:
          _selectedType == HabitType.numeric ? _unitController.text.trim() : null,
      targetDurationMinutes: _selectedType == HabitType.duration
          ? _durationMinutes
          : null,
      scheduledDays: _scheduledDays.isEmpty ? [1, 2, 3, 4, 5, 6, 7] : _scheduledDays,
      createdAt: widget.existingHabit?.createdAt ?? DateTime.now(),
      isArchived: widget.existingHabit?.isArchived ?? false,
    );

    widget.onSave(habit);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: AppColors.border, width: 1.2),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 550, maxHeight: 700),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.existingHabit == null
                          ? 'إضافة عادة فولاذية جديدة'
                          : 'تعديل العادة',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: AppColors.textMuted),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Title
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'اسم العادة *',
                    hintText: 'مثال: صلاة الفجر في المسجد، تمرين بدني...',
                    filled: true,
                    fillColor: AppColors.surfaceElevated,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                  ),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'يرجى كتابة اسم العادة' : null,
                ),
                const SizedBox(height: 12),

                // Category & Description
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: _categoryController,
                        decoration: InputDecoration(
                          labelText: 'التصنيف',
                          hintText: 'عبادات، رياضة...',
                          filled: true,
                          fillColor: AppColors.surfaceElevated,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 3,
                      child: TextFormField(
                        controller: _descController,
                        decoration: InputDecoration(
                          labelText: 'الهدف / الوصف',
                          hintText: 'لماذا التزم بهذه العادة؟',
                          filled: true,
                          fillColor: AppColors.surfaceElevated,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Habit Type Selector
                const Text(
                  'نوع محرك العادة:',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: HabitType.values.map((type) {
                    final isSel = _selectedType == type;
                    return ChoiceChip(
                      label: Text(type.labelArabic),
                      selected: isSel,
                      selectedColor: Color(_colorValue),
                      backgroundColor: AppColors.surfaceElevated,
                      labelStyle: TextStyle(
                        color: isSel ? Colors.black : AppColors.textPrimary,
                        fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                      ),
                      onSelected: (val) {
                        if (val) setState(() => _selectedType = type);
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 14),

                // Type specific configs
                if (_selectedType == HabitType.weeklyTarget) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('عدد الحصص المستهدفة أسبوعياً:'),
                        DropdownButton<int>(
                          value: _weeklyFrequency,
                          dropdownColor: AppColors.surfaceElevated,
                          items: [1, 2, 3, 4, 5, 6].map((i) {
                            return DropdownMenuItem(
                              value: i,
                              child: Text('$i أيام في الأسبوع'),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _weeklyFrequency = val);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                if (_selectedType == HabitType.numeric) ...[
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _targetValController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'الكمية المستهدفة',
                            filled: true,
                            fillColor: AppColors.surfaceElevated,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          controller: _unitController,
                          decoration: InputDecoration(
                            labelText: 'وحدة القياس',
                            hintText: 'صفحة، مل، ركعة',
                            filled: true,
                            fillColor: AppColors.surfaceElevated,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],

                if (_selectedType == HabitType.duration) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('مدة مؤقت التركيز (بالدقائق):'),
                        DropdownButton<int>(
                          value: _durationMinutes,
                          dropdownColor: AppColors.surfaceElevated,
                          items: [15, 25, 30, 45, 60, 90].map((m) {
                            return DropdownMenuItem(
                              value: m,
                              child: Text('$m دقيقة'),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _durationMinutes = val);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // Qualitative Tags
                TextFormField(
                  controller: _tagsController,
                  decoration: InputDecoration(
                    labelText: 'الوسوم النوعية المخصصة (مفصولة بفاصلة)',
                    hintText: 'مثال: في المسجد، تكبيرة الإحرام، في البيت',
                    filled: true,
                    fillColor: AppColors.surfaceElevated,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Icon & Color Pickers
                const Text(
                  'اختر الأيقونة واللون:',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                // Colors
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _availableColors.map((c) {
                      final isSel = _colorValue == c.value;
                      return GestureDetector(
                        onTap: () => setState(() => _colorValue = c.value),
                        child: Container(
                          width: 34,
                          height: 34,
                          margin: const EdgeInsets.only(left: 8),
                          decoration: BoxDecoration(
                            color: c,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSel ? Colors.white : Colors.transparent,
                              width: 2.5,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 12),
                // Icons
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _availableIcons.map((ic) {
                      final isSel = _iconCodePoint == ic.codePoint;
                      return GestureDetector(
                        onTap: () =>
                            setState(() => _iconCodePoint = ic.codePoint),
                        child: Container(
                          width: 40,
                          height: 40,
                          margin: const EdgeInsets.only(left: 8),
                          decoration: BoxDecoration(
                            color: isSel
                                ? Color(_colorValue).withOpacity(0.2)
                                : AppColors.surfaceElevated,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSel
                                  ? Color(_colorValue)
                                  : AppColors.border,
                            ),
                          ),
                          child: Icon(ic,
                              color: isSel
                                  ? Color(_colorValue)
                                  : AppColors.textSecondary,
                              size: 22),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 24),

                // Save Button
                ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(_colorValue),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'حفظ العادة في التزام ⚡',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
