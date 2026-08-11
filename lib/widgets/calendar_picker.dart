import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';

/// A self-contained month calendar that reports a selected date as
/// "YYYY-MM-DD". Manages its own month navigation state.
class CalendarPicker extends StatefulWidget {
  final String selectedDate;
  final ValueChanged<String> onSelect;

  const CalendarPicker({
    Key? key,
    required this.selectedDate,
    required this.onSelect,
  }) : super(key: key);

  @override
  State<CalendarPicker> createState() => _CalendarPickerState();
}

class _CalendarPickerState extends State<CalendarPicker> {
  late DateTime _calMonth;

  @override
  void initState() {
    super.initState();
    _initMonth();
  }

  void _initMonth() {
    if (widget.selectedDate.isNotEmpty) {
      try {
        final selected = DateTime.parse(widget.selectedDate);
        _calMonth = DateTime(selected.year, selected.month, 1);
        return;
      } catch (e) {
        // fall through to current month
      }
    }
    final now = DateTime.now();
    _calMonth = DateTime(now.year, now.month, 1);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    final daysInMonth = DateUtils.getDaysInMonth(_calMonth.year, _calMonth.month);
    final firstDayOffset = _calMonth.weekday - 1; // 0 = Lunes, 6 = Domingo

    final dayNames = ['Lu', 'Ma', 'Mi', 'Ju', 'Vi', 'Sa', 'Do'];
    final now = DateTime.now();
    final todayStr = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border.all(color: colors.borderSoft),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () {
                  setState(() {
                    _calMonth = DateTime(_calMonth.year, _calMonth.month - 1, 1);
                  });
                },
              ),
              Text(
                DateFormat('MMMM yyyy', 'es_ES').format(_calMonth),
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: colors.fg),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () {
                  setState(() {
                    _calMonth = DateTime(_calMonth.year, _calMonth.month + 1, 1);
                  });
                },
              ),
            ],
          ),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1.2,
              crossAxisSpacing: 2,
              mainAxisSpacing: 2,
            ),
            itemCount: 7 + firstDayOffset + daysInMonth,
            itemBuilder: (context, index) {
              if (index < 7) {
                return Center(
                  child: Text(
                    dayNames[index],
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: colors.muted),
                  ),
                );
              }
              final dayIndex = index - 7 - firstDayOffset;
              if (dayIndex < 0) return const SizedBox.shrink();

              final day = dayIndex + 1;
              final dateStr = "${_calMonth.year}-${_calMonth.month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}";
              final isSelected = dateStr == widget.selectedDate;
              final isToday = dateStr == todayStr;

              return GestureDetector(
                onTap: () => widget.onSelect(dateStr),
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected ? colors.accent : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    day.toString(),
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected ? colors.accentOn : (isToday ? colors.accent : colors.fg2),
                      fontWeight: isSelected || isToday ? FontWeight.w700 : FontWeight.normal,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
