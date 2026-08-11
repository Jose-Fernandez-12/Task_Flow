import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/task_card.dart';
import '../widgets/task_detail_modal.dart';
import '../widgets/add_task_modal.dart';
import '../widgets/task_context_menu.dart';
import '../widgets/move_task_modal.dart';

class DailyView extends StatelessWidget {
  final void Function(String title)? onStartFocus;

  const DailyView({Key? key, this.onStartFocus}) : super(key: key);

  void _showDetailModal(BuildContext context, Task task, TaskProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => TaskDetailModal(
        task: task,
        onEdit: () {
          _showEditModal(context, task, provider);
        },
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
          onPressed: () {
            provider.undoDelete();
          },
        ),
      ),
    );
  }

  void _showContextMenu(BuildContext context, Task task, TaskProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => TaskContextMenu(
        taskTitle: task.title,
        onEdit: () {
          _showEditModal(context, task, provider);
        },
        onDuplicate: () {
          provider.duplicateTask(task.id);
        },
        onMove: () {
          _showMoveModal(context, task, provider);
        },
        onFocus: () {
          onStartFocus?.call(task.title);
        },
        onDelete: () {
          provider.deleteTask(task.id);
          _showDeleteSnackbar(context, provider);
        },
      ),
    );
  }

  void _showMoveModal(BuildContext context, Task task, TaskProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => MoveTaskModal(
        initialDate: task.date,
        onSelect: (date) {
          provider.moveTaskToDay(task.id, date);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final provider = Provider.of<TaskProvider>(context);

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    // Categorize
    List<Task> overdue = [];
    List<Task> pendingToday = [];
    List<Task> completed = [];

    for (var t in provider.tasks) {
      if (t.date.isEmpty) continue;
      try {
        final d = DateTime.parse(t.date);
        final dateOnly = DateTime(d.year, d.month, d.day);
        final diff = dateOnly.difference(today).inDays;
        
        if (t.done) {
          if (diff <= 0) completed.add(t);
        } else {
          if (diff < 0) overdue.add(t);
          else if (diff == 0) pendingToday.add(t);
        }
      } catch (_) {}
    }

    if (overdue.isEmpty && pendingToday.isEmpty) {
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
                'No tienes tareas pendientes para hoy. Pulsa + para añadir una.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: colors.muted, height: 1.4),
              ),
              if (completed.isNotEmpty) ...[
                const SizedBox(height: 32),
                _buildSectionHeader('Completadas', completed.length, colors),
                ...completed.take(5).map((t) => _buildCard(context, t, provider)),
              ]
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 100),
      children: [
        if (overdue.isNotEmpty) ...[
          _buildSectionHeader('Atrasadas', overdue.length, colors, titleColor: colors.danger),
          _buildReorderableSection(context, overdue, provider),
        ],
        if (pendingToday.isNotEmpty) ...[
          _buildSectionHeader('Pendientes hoy', pendingToday.length, colors),
          _buildReorderableSection(context, pendingToday, provider),
        ],
        if (completed.isNotEmpty) ...[
          _buildSectionHeader('Completadas', completed.length, colors),
          ...completed.take(5).map((t) => _buildCard(context, t, provider)),
        ],
      ],
    );
  }

  Widget _buildReorderableSection(
    BuildContext context,
    List<Task> tasks,
    TaskProvider provider,
  ) {
    return ReorderableListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      buildDefaultDragHandles: false,
      itemCount: tasks.length,
      onReorder: (oldIndex, newIndex) {
        if (newIndex > oldIndex) newIndex -= 1;
        final reordered = List<Task>.from(tasks);
        final moved = reordered.removeAt(oldIndex);
        reordered.insert(newIndex, moved);
        provider.reorderTasks(reordered);
      },
      itemBuilder: (context, index) {
        final task = tasks[index];
        return TaskCard(
          key: ValueKey('reorder_${task.id}'),
          task: task,
          onTap: () => _showDetailModal(context, task, provider),
          onLongPress: () => _showContextMenu(context, task, provider),
          onToggleDone: () => provider.toggleDone(task.id),
          onDelete: () {
            provider.deleteTask(task.id);
            _showDeleteSnackbar(context, provider);
          },
          onPostpone: () => provider.postponeTask(task.id),
          dragHandle: ReorderableDragStartListener(
            index: index,
            child: const Padding(
              padding: EdgeInsets.all(8),
              child: Icon(Icons.drag_indicator, size: 20),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title, int count, AppColors colors, {Color? titleColor}) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: titleColor ?? colors.fg2,
              letterSpacing: 0.1,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
            decoration: BoxDecoration(
              color: colors.surfaceWarm,
              borderRadius: BorderRadius.circular(9999),
            ),
            child: Text(
              count.toString(),
              style: TextStyle(
                fontSize: 12,
                color: colors.muted,
                fontFamily: 'Geist Mono',
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildCard(BuildContext context, Task task, TaskProvider provider) {
    return TaskCard(
      task: task,
      onTap: () => _showDetailModal(context, task, provider),
      onLongPress: () => _showContextMenu(context, task, provider),
      onToggleDone: () => provider.toggleDone(task.id),
      onDelete: () {
        provider.deleteTask(task.id);
        _showDeleteSnackbar(context, provider);
      },
      onPostpone: () => provider.postponeTask(task.id),
    );
  }
}
