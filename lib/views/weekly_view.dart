import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/task_card.dart';
import '../widgets/task_detail_modal.dart';
import '../widgets/add_task_modal.dart';

class WeeklyView extends StatelessWidget {
  const WeeklyView({Key? key}) : super(key: key);

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
    // Find monday of current week
    final startOfWeek = today.subtract(Duration(days: today.weekday - 1));

    List<DateTime> weekDays = List.generate(7, (i) => startOfWeek.add(Duration(days: i)));

    // Group tasks by day
    Map<DateTime, List<Task>> groupedTasks = { for (var d in weekDays) d: [] };
    
    int totalWeekTasks = 0;

    for (var t in provider.tasks) {
      if (t.date.isEmpty || t.type == TaskType.recordatorio) continue;
      try {
        final d = DateTime.parse(t.date);
        final dateOnly = DateTime(d.year, d.month, d.day);
        if (groupedTasks.containsKey(dateOnly)) {
          groupedTasks[dateOnly]!.add(t);
          totalWeekTasks++;
        }
      } catch (_) {}
    }

    if (totalWeekTasks == 0) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: colors.surfaceWarm,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.calendar_view_week, size: 28, color: colors.accent),
              ),
              const SizedBox(height: 16),
              Text('Semana sin tareas', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: colors.fg2)),
              const SizedBox(height: 4),
              Text(
                'Añade tareas con fecha para verlas organizadas por día.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: colors.muted, height: 1.4),
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 100),
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Esta semana', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: colors.fg2)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                decoration: BoxDecoration(
                  color: colors.surfaceWarm,
                  borderRadius: BorderRadius.circular(9999),
                ),
                child: Text(
                  '$totalWeekTasks tareas',
                  style: TextStyle(fontSize: 12, color: colors.muted, fontFamily: 'Geist Mono'),
                ),
              )
            ],
          ),
        ),
        ...weekDays.map((day) {
          final isToday = day == today;
          final isPast = day.isBefore(today);
          final dayTasks = groupedTasks[day]!;
          
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
                          color: isToday ? colors.accent : (isPast ? colors.muted : colors.border),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        isToday ? 'Hoy' : DateFormat('EEEE', 'es_ES').format(day).capitalize(),
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: colors.fg2),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        DateFormat('d MMM', 'es_ES').format(day),
                        style: TextStyle(fontSize: 11, color: colors.muted, fontFamily: 'Geist Mono'),
                      ),
                    ],
                  ),
                ),
                if (dayTasks.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(left: 12, top: 4, bottom: 12),
                    child: Text('Sin tareas', style: TextStyle(fontSize: 13, color: colors.muted)),
                  )
                else
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
}

extension WeeklyViewStringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
