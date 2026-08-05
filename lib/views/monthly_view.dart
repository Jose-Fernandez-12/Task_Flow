import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/task_card.dart';
import '../widgets/task_detail_modal.dart';
import '../widgets/add_task_modal.dart';
import 'weekly_view.dart'; // Para StringExtension.capitalize()

class MonthlyView extends StatefulWidget {
  const MonthlyView({Key? key}) : super(key: key);

  @override
  State<MonthlyView> createState() => _MonthlyViewState();
}

class _MonthlyViewState extends State<MonthlyView> {
  int _monthOffset = 0;
  String? _selectedDateStr;

  void _showDetailModal(BuildContext context, Task task, TaskProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => TaskDetailModal(
        task: task,
        onEdit: () => _showEditModal(context, task, provider),
        onDelete: () {
          provider.deleteTask(task.id);
          _showDeleteSnackbar(context, provider);
        },
      ),
    );
  }

  void _showEditModal(BuildContext context, Task task, TaskProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AddTaskModal(
        taskToEdit: task,
        onSave: (title, desc, date, priority, type, time) {
          provider.addOrUpdateTask(
            id: task.id,
            title: title,
            desc: desc,
            date: date,
            priority: priority,
            type: type,
            time: time,
          );
        },
      ),
    );
  }

  void _showDeleteSnackbar(BuildContext context, TaskProvider provider) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Tarea eliminada'),

        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'Deshacer',

          onPressed: () => provider.undoDelete(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final provider = Provider.of<TaskProvider>(context);

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    // Determine the month to display
    final displayMonth = DateTime(now.year, now.month + _monthOffset, 1);
    final daysInMonth = DateUtils.getDaysInMonth(displayMonth.year, displayMonth.month);
    final firstDayOffset = displayMonth.weekday - 1; // 0 = Lunes, 6 = Domingo

    // Filter tasks for this month
    List<Task> monthTasks = [];
    for (var t in provider.tasks) {
      if (t.date.isEmpty || t.type == TaskType.recordatorio) continue;
      try {
        final d = DateTime.parse(t.date);
        if (d.year == displayMonth.year && d.month == displayMonth.month) {
          monthTasks.add(t);
        }
      } catch (_) {}
    }

    final dayNames = ['Lu', 'Ma', 'Mi', 'Ju', 'Vi', 'Sa', 'Do'];

    // Group tasks by exact date for the list below the calendar
    Map<String, List<Task>> groupedTasks = {};
    for (var t in monthTasks) {
      if (!groupedTasks.containsKey(t.date)) {
        groupedTasks[t.date] = [];
      }
      groupedTasks[t.date]!.add(t);
    }

    // Sort grouped keys
    final sortedKeys = groupedTasks.keys.toList()..sort();
    
    List<String> keysToDisplay = _selectedDateStr != null 
        ? (groupedTasks.containsKey(_selectedDateStr) ? [_selectedDateStr!] : [])
        : sortedKeys;

    return ListView(
      padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 100),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "${DateFormat('MMMM', 'es_ES').format(displayMonth).capitalize()} ${displayMonth.year}",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: colors.fg2),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
              decoration: BoxDecoration(
                color: colors.surfaceWarm,
                borderRadius: BorderRadius.circular(9999),
              ),
              child: Text(
                '${monthTasks.length} tareas',
                style: TextStyle(fontSize: 12, color: colors.muted, fontFamily: 'Geist Mono'),
              ),
            )
          ],
        ),
        const SizedBox(height: 16),
        // Navigation
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildNavButton(Icons.chevron_left, colors, () {
              setState(() => _monthOffset--);
            }),
            Text(
              "${DateFormat('MMMM', 'es_ES').format(displayMonth).capitalize()} ${displayMonth.year}",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: colors.fg),
            ),
            _buildNavButton(Icons.chevron_right, colors, () {
              setState(() => _monthOffset++);
            }),
          ],
        ),
        const SizedBox(height: 8),
        // Grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            childAspectRatio: 1.0,
            crossAxisSpacing: 2,
            mainAxisSpacing: 2,
          ),
          itemCount: 7 + firstDayOffset + daysInMonth,
          itemBuilder: (context, index) {
            if (index < 7) {
              return Center(
                child: Text(
                  dayNames[index],
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: colors.muted, fontFamily: 'Geist Mono'),
                ),
              );
            }
            final dayIndex = index - 7 - firstDayOffset;
            if (dayIndex < 0) {
              return Container(); // other month
            }

            final day = dayIndex + 1;
            final dateStr = "${displayMonth.year}-${displayMonth.month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}";
            
            final dt = groupedTasks[dateStr] ?? [];
            final isToday = dateStr == "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

            final isSelected = _selectedDateStr == dateStr;

            return GestureDetector(
              onTap: () {
                setState(() {
                  if (_selectedDateStr == dateStr) {
                    _selectedDateStr = null;
                  } else {
                    _selectedDateStr = dateStr;
                  }
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected ? colors.accent : (isToday ? colors.accent.withOpacity(0.2) : Colors.transparent),
                  borderRadius: BorderRadius.circular(10),
                ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                    Text(
                      day.toString(),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected || isToday ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected ? colors.accentOn : colors.fg2,
                      ),
                    ),
                  if (dt.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 2),
                      width: dt.length > 1 ? 12 : 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isSelected ? colors.accentOn : colors.accent,
                        borderRadius: BorderRadius.circular(dt.length > 1 ? 2 : 2), // small pill if multiple
                      ),
                    )
                ],
              ),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        if (keysToDisplay.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(color: colors.surfaceWarm, shape: BoxShape.circle),
                    child: Icon(Icons.calendar_month, size: 28, color: colors.accent),
                  ),
                  const SizedBox(height: 16),
                  Text(_selectedDateStr != null ? 'Sin tareas en este día' : 'Sin tareas este mes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: colors.fg2)),
                  const SizedBox(height: 4),
                  Text('Las tareas con fecha aparecerán aquí', style: TextStyle(fontSize: 13, color: colors.muted)),
                ],
              ),
            ),
          )
        else
          ...keysToDisplay.map((dk) {
            final date = DateTime.parse(dk);
            final dayTasks = groupedTasks[dk]!;
            final isToday = date == today;
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                    child: Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: isToday ? colors.accent : colors.border,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          DateFormat('EEEE, d MMMM', 'es_ES').format(date).capitalize(),
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: colors.fg2),
                        ),
                      ],
                    ),
                  ),
                  ...dayTasks.map((t) => TaskCard(
                    task: t,
                    onTap: () => _showDetailModal(context, t, provider),
                    onToggleDone: () => provider.toggleDone(t.id),
                    onDelete: () {
                      provider.deleteTask(t.id);
                      _showDeleteSnackbar(context, provider);
                    },
                    onPostpone: () => provider.postponeTask(t.id),
                  ))
                ],
              ),
            );
          }),
      ],
    );
  }

  Widget _buildNavButton(IconData icon, AppColors colors, VoidCallback onTap) {
    return Material(
      color: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(9999),
        side: BorderSide(color: colors.borderSoft),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(9999),
        child: Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          child: Icon(icon, size: 20, color: colors.fg2),
        ),
      ),
    );
  }
}
