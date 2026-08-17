import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/task_detail_modal.dart';
import '../widgets/add_task_modal.dart';
import '../widgets/task_card.dart';

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

  void _duplicateTask(Task task, TaskProvider provider) {
    provider.addOrUpdateTask(
      title: task.title,
      desc: task.desc,
      date: task.date,
      priority: task.priority,
      type: task.type,
      time: task.time,
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
    final pending = provider.recordatoriosPendientes;
    final completed = rec.where((t) => t.done).toList();

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

    if (pending.isEmpty && completed.isNotEmpty) {
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
                child: Icon(Icons.check_circle, size: 28, color: colors.accent),
              ),
              const SizedBox(height: 16),
              Text('¡Todo listo!', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: colors.fg2)),
              const SizedBox(height: 4),
              Text(
                'No tienes recordatorios pendientes.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: colors.muted, height: 1.4),
              ),
              const SizedBox(height: 32),
              _buildSectionHeader('Completadas', completed.length, colors),
              ...completed.take(5).map((t) => _buildAlertCard(context, t, provider, colors)),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 100),
      children: [
        if (pending.isNotEmpty) ...[
          _buildSectionHeader('Recordatorios', pending.length, colors),
          ...pending.map((t) => _buildAlertCard(context, t, provider, colors)),
        ],
        if (completed.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildSectionHeader('Completadas', completed.length, colors),
          ...completed.map((t) => _buildAlertCard(context, t, provider, colors)),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(String title, int count, AppColors colors) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: colors.fg2)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
            decoration: BoxDecoration(
              color: colors.surfaceWarm,
              borderRadius: BorderRadius.circular(9999),
            ),
            child: Text(
              count.toString(),
              style: TextStyle(fontSize: 12, color: colors.muted, fontFamily: 'Geist Mono'),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildAlertCard(BuildContext context, Task t, TaskProvider provider, AppColors colors) {
    return TaskCard(
      task: t,
      onTap: () => _showDetailModal(context, t, provider),
      onToggleDone: () => provider.toggleDone(t.id),
      onDelete: () {
        provider.deleteTask(t.id);
        _showDeleteSnackbar(context, provider);
      },
      onEdit: () => _showEditModal(context, t, provider),
      onDuplicate: () => _duplicateTask(t, provider),
    );
  }
}
