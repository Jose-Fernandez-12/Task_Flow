import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/task_detail_modal.dart';
import '../widgets/add_task_modal.dart';

class AlertsView extends StatelessWidget {
  const AlertsView({Key? key}) : super(key: key);

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

  String _timeAgo(int ts) {
    final diff = DateTime.now().millisecondsSinceEpoch - ts;
    final min = (diff / 60000).floor();
    if (min < 1) return 'ahora';
    if (min < 60) return 'hace $min min';
    final hrs = (min / 60).floor();
    if (hrs < 24) return 'hace ${hrs}h';
    return 'hace ${(hrs / 24).floor()}d';
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final provider = Provider.of<TaskProvider>(context);
    final rec = provider.recordatorios;

    if (rec.isEmpty) {
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
                child: Icon(Icons.notifications_off, size: 28, color: colors.accent),
              ),
              const SizedBox(height: 16),
              Text('Sin recordatorios', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: colors.fg2)),
              const SizedBox(height: 4),
              Text(
                'Añade una tarea sin fecha para crear un recordatorio.',
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
              Text('Recordatorios', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: colors.fg2)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                decoration: BoxDecoration(
                  color: colors.surfaceWarm,
                  borderRadius: BorderRadius.circular(9999),
                ),
                child: Text(
                  '${rec.length}',
                  style: TextStyle(fontSize: 12, color: colors.muted, fontFamily: 'Geist Mono'),
                ),
              )
            ],
          ),
        ),
        ...rec.map((t) => Container(
          margin: const EdgeInsets.only(bottom: 8.0),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _showDetailModal(context, t, provider),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: colors.borderSoft),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      margin: const EdgeInsets.only(right: 14),
                      decoration: BoxDecoration(
                        color: colors.accent.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.notifications, size: 20, color: colors.accent),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t.title,
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: colors.fg, height: 1.3),
                          ),
                          if (t.desc.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              t.desc,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 13, color: colors.muted, height: 1.4),
                            ),
                          ],
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.04),
                                  borderRadius: BorderRadius.circular(9999),
                                ),
                                child: Text(
                                  'Creado ${_timeAgo(t.createdAt)}',
                                  style: TextStyle(fontSize: 11, color: colors.muted, fontFamily: 'Geist Mono'),
                                ),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () {
                                  provider.toggleDone(t.id);
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: t.done ? colors.accent.withOpacity(0.1) : colors.danger.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(9999),
                                    border: Border.all(color: t.done ? colors.accent.withOpacity(0.2) : colors.danger.withOpacity(0.2)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        t.done ? Icons.check_circle : Icons.radio_button_unchecked,
                                        size: 14,
                                        color: t.done ? colors.accent : colors.danger,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        t.done ? 'Completado' : 'Marcar hecho',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: t.done ? colors.accent : colors.danger,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        provider.deleteTask(t.id);
                        _showDeleteSnackbar(context, provider);
                      },
                      icon: const Icon(Icons.close),
                      color: colors.muted,
                      iconSize: 20,
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(4),
                      splashRadius: 20,
                    )
                  ],
                ),
              ),
            ),
          ),
        ))
      ],
    );
  }
}
