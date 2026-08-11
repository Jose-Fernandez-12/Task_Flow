import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'calendar_picker.dart';

/// Bottom sheet to pick a new day for a task: quick chips + calendar.
class MoveTaskModal extends StatefulWidget {
  final String initialDate;
  final ValueChanged<String> onSelect;

  const MoveTaskModal({
    Key? key,
    required this.initialDate,
    required this.onSelect,
  }) : super(key: key);

  @override
  State<MoveTaskModal> createState() => _MoveTaskModalState();
}

class _MoveTaskModalState extends State<MoveTaskModal> {
  late String _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
  }

  String _dateStr(DateTime d) {
    return "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";
  }

  void _select(String date) {
    Navigator.pop(context);
    widget.onSelect(date);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 20,
        bottom: 24 + MediaQuery.of(context).padding.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: colors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Text(
            'Mover a otro día',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: colors.fg),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildQuickChip('Hoy', _dateStr(DateTime.now()), colors),
              const SizedBox(width: 8),
              _buildQuickChip('Mañana', _dateStr(DateTime.now().add(const Duration(days: 1))), colors),
              const SizedBox(width: 8),
              _buildQuickChip('Pasado mañana', _dateStr(DateTime.now().add(const Duration(days: 2))), colors),
            ],
          ),
          const SizedBox(height: 16),
          CalendarPicker(
            selectedDate: _selectedDate,
            onSelect: (date) => _select(date),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickChip(String label, String date, AppColors colors) {
    final isSelected = _selectedDate == date;
    return Expanded(
      child: GestureDetector(
        onTap: () => _select(date),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? colors.accent : colors.surfaceWarm,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isSelected ? colors.accentOn : colors.fg2,
            ),
          ),
        ),
      ),
    );
  }
}
