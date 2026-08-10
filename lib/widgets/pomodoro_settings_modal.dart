import 'package:flutter/material.dart';
import '../models/pomodoro_state.dart';
import '../theme/app_theme.dart';

class PomodoroSettingsModal extends StatefulWidget {
  final PomodoroState state;
  final Function(int focus, int shortBreak, int longBreak) onSave;

  const PomodoroSettingsModal({
    Key? key,
    required this.state,
    required this.onSave,
  }) : super(key: key);

  @override
  State<PomodoroSettingsModal> createState() => _PomodoroSettingsModalState();
}

class _PomodoroSettingsModalState extends State<PomodoroSettingsModal> {
  late int _focusMinutes;
  late int _shortBreakMinutes;
  late int _longBreakMinutes;

  @override
  void initState() {
    super.initState();
    _focusMinutes = widget.state.customFocusMinutes;
    _shortBreakMinutes = widget.state.customShortBreakMinutes;
    _longBreakMinutes = widget.state.customLongBreakMinutes;
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Personalizar Tiempos',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: colors.fg,
                ),
              ),
              IconButton(
                icon: Icon(Icons.close, color: colors.muted),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Focus Time Slider/Selector (Above 30 min)
          _buildDurationPicker(
            label: 'Tiempo de Enfoque Principal',
            value: _focusMinutes,
            options: [35, 45, 60, 90, 120],
            colors: colors,
            onSelected: (val) => setState(() => _focusMinutes = val),
          ),
          const SizedBox(height: 20),

          // Enfoque Corto
          _buildDurationPicker(
            label: 'Enfoque Corto',
            value: _shortBreakMinutes,
            options: [3, 5, 10, 15],
            colors: colors,
            onSelected: (val) => setState(() => _shortBreakMinutes = val),
          ),
          const SizedBox(height: 20),

          // Enfoque Largo
          _buildDurationPicker(
            label: 'Enfoque Largo',
            value: _longBreakMinutes,
            options: [10, 15, 20, 30],
            colors: colors,
            onSelected: (val) => setState(() => _longBreakMinutes = val),
          ),
          const SizedBox(height: 30),

          // Save Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.accent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () {
                widget.onSave(_focusMinutes, _shortBreakMinutes, _longBreakMinutes);
                Navigator.pop(context);
              },
              child: Text(
                'Guardar Cambios',
                style: TextStyle(
                  color: colors.accentOn,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildDurationPicker({
    required String label,
    required int value,
    required List<int> options,
    required AppColors colors,
    required ValueChanged<int> onSelected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: colors.fg2,
              ),
            ),
            Text(
              '$value min',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: colors.accent,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: options.map((opt) {
              final isSelected = value == opt;
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ChoiceChip(
                  label: Text('$opt min'),
                  selected: isSelected,
                  selectedColor: colors.accent,
                  backgroundColor: colors.surfaceWarm,
                  labelStyle: TextStyle(
                    color: isSelected ? colors.accentOn : colors.fg,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  onSelected: (sel) {
                    if (sel) onSelected(opt);
                  },
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
