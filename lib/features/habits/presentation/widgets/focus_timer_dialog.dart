import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/haptics.dart';

class FocusTimerDialog extends StatefulWidget {
  final String habitTitle;
  final int initialMinutes;
  final Function(int minutesSpent) onComplete;

  const FocusTimerDialog({
    super.key,
    required this.habitTitle,
    this.initialMinutes = 25,
    required this.onComplete,
  });

  @override
  State<FocusTimerDialog> createState() => _FocusTimerDialogState();
}

class _FocusTimerDialogState extends State<FocusTimerDialog> {
  late int _remainingSeconds;
  late int _totalSeconds;
  Timer? _timer;
  bool _isRunning = false;

  @override
  void initState() {
    super.initState();
    _totalSeconds = widget.initialMinutes * 60;
    _remainingSeconds = _totalSeconds;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _toggleTimer() {
    AppHaptics.selection();
    if (_isRunning) {
      _timer?.cancel();
      setState(() => _isRunning = false);
    } else {
      setState(() => _isRunning = true);
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_remainingSeconds > 0) {
          setState(() => _remainingSeconds--);
        } else {
          _timer?.cancel();
          setState(() => _isRunning = false);
          AppHaptics.success();
        }
      });
    }
  }

  void _resetTimer() {
    AppHaptics.lightImpact();
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _remainingSeconds = _totalSeconds;
    });
  }

  void _addMinutes(int minutes) {
    AppHaptics.lightImpact();
    setState(() {
      _totalSeconds += minutes * 60;
      _remainingSeconds += minutes * 60;
    });
  }

  void _finishAndSave() {
    AppHaptics.success();
    _timer?.cancel();
    final secondsSpent = _totalSeconds - _remainingSeconds;
    final minutesSpent = (secondsSpent / 60).ceil();
    widget.onComplete(minutesSpent > 0 ? minutesSpent : 1);
    Navigator.of(context).pop();
  }

  String _formatTime(int totalSecs) {
    final m = totalSecs ~/ 60;
    final s = totalSecs % 60;
    final mStr = m.toString().padLeft(2, '0');
    final sStr = s.toString().padLeft(2, '0');
    return '$mStr:$sStr';
  }

  @override
  Widget build(BuildContext context) {
    final progress = _totalSeconds > 0
        ? ((_totalSeconds - _remainingSeconds) / _totalSeconds).clamp(0.0, 1.0)
        : 0.0;

    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
        side: const BorderSide(color: AppColors.border, width: 1.2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Icon(Icons.timer_outlined, color: AppColors.purple, size: 28),
                Text(
                  widget.habitTitle,
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
            const SizedBox(height: 24),

            // Circular Countdown Display
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 170,
                  height: 170,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 10,
                    backgroundColor: AppColors.surfaceElevated,
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(AppColors.purple),
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _formatTime(_remainingSeconds),
                      style: const TextStyle(
                        fontSize: 38,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _isRunning ? 'جلسة تركيز جارية...' : 'مؤقت الاستغراق',
                      style: TextStyle(
                        fontSize: 12,
                        color: _isRunning ? AppColors.purple : AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Quick Add Minutes
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(
                  onPressed: () => _addMinutes(5),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    side: const BorderSide(color: AppColors.border),
                  ),
                  child: const Text('+5 د'),
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: () => _addMinutes(15),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    side: const BorderSide(color: AppColors.border),
                  ),
                  child: const Text('+15 د'),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Action Buttons
            Row(
              children: [
                // Reset
                IconButton(
                  icon: const Icon(Icons.refresh_rounded,
                      color: AppColors.textMuted),
                  onPressed: _resetTimer,
                  tooltip: 'إعادة ضبط',
                ),
                const SizedBox(width: 8),
                // Play / Pause
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _toggleTimer,
                    icon: Icon(
                      _isRunning
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      color: Colors.white,
                    ),
                    label: Text(
                      _isRunning ? 'إيقاف مؤقت' : 'بدء التركيز',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.purple,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Save & Finish
                ElevatedButton(
                  onPressed: _finishAndSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.surfaceElevated,
                    foregroundColor: AppColors.emerald,
                    side: const BorderSide(color: AppColors.emerald),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'تسجيل',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
