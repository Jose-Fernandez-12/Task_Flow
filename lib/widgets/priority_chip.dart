import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/task.dart';

class PriorityChip extends StatelessWidget {
  final String label;
  final TaskPriority value;
  final bool isSelected;
  final VoidCallback onTap;

  const PriorityChip({
    Key? key,
    required this.label,
    required this.value,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    
    Color baseColor;
    switch (value) {
      case TaskPriority.alta:
        baseColor = colors.danger;
        break;
      case TaskPriority.media:
        baseColor = colors.warn;
        break;
      case TaskPriority.baja:
        baseColor = colors.success;
        break;
    }

    final Color textColor = isSelected ? baseColor : colors.muted;
    final Color borderColor = isSelected ? baseColor : colors.borderSoft;
    final Color bgColor = isSelected 
        ? baseColor.withOpacity(0.12)
        : colors.bg;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(9999),
          border: Border.all(color: borderColor),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: textColor,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
