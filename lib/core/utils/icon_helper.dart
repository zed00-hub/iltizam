import 'package:flutter/material.dart';

class HabitIconHelper {
  static const List<IconData> supportedIcons = [
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
    Icons.check_circle_outline,
    Icons.shield_rounded,
    Icons.local_fire_department,
    Icons.flag_outlined,
  ];

  static IconData getIcon(int codePoint) {
    for (final icon in supportedIcons) {
      if (icon.codePoint == codePoint) {
        return icon;
      }
    }
    return Icons.star_rounded;
  }
}
