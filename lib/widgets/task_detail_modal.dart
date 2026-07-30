import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../theme/app_theme.dart';

class TaskDetailModal extends StatelessWidget {
  final Task task;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TaskDetailModal({
    Key? key,
    required this.task,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  String _formatDate(String dateStr) {
    if (dateStr.isEmpty) return 'Sin fecha';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('EEEE, d MMMM', 'es_ES').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  String _formatCategory(String dateStr) {
    if (dateStr.isEmpty) return 'Recordatorio';
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final diff = date.difference(today).inDays;
      if (diff <= 0) return 'Hoy';
      if (diff <= 6) return 'Esta semana';
      return 'Este mes';
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final createdDate = DateTime.fromMillisecondsSinceEpoch(task.createdAt);
    final createdFormatted = DateFormat('d MMM, HH:mm', 'es_ES').format(createdDate);

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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  task.title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: colors.fg,
                    height: 1.3,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Material(
                color: colors.surfaceWarm,
                shape: const CircleBorder(),
                child: IconButton(
                  icon: Icon(Icons.close, color: colors.fg2),
                  onPressed: () => Navigator.pop(context),
                  iconSize: 20,
                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                  padding: EdgeInsets.zero,
                  splashRadius: 18,
                ),
              )
            ],
          ),
          const SizedBox(height: 16),
          Text(
            task.desc.isEmpty ? 'Sin descripción' : task.desc,
            style: TextStyle(
              fontSize: 14,
              color: colors.fg2,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          _buildInfoRow(
            icon: task.done ? Icons.check_circle : Icons.radio_button_unchecked,
            text: task.done ? 'Completada' : 'Pendiente',
            colors: colors,
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            icon: Icons.flag,
            text: "Prioridad: ${task.priority == TaskPriority.alta ? 'Alta' : task.priority == TaskPriority.media ? 'Media' : 'Baja'}",
            colors: colors,
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            icon: task.date.isEmpty ? Icons.notifications : Icons.calendar_today,
            text: task.date.isEmpty ? 'Sin fecha — Recordatorio' : "${_formatDate(task.date)} — ${_formatCategory(task.date)}",
            colors: colors,
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            icon: Icons.schedule,
            text: "Creado $createdFormatted",
            colors: colors,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: TextButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    onEdit();
                  },
                  icon: Icon(Icons.edit, size: 18, color: colors.accentOn),
                  label: Text(
                    'Editar',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: colors.accentOn),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: colors.accent,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    onDelete();
                  },
                  icon: Icon(Icons.delete_outline, size: 18, color: colors.danger),
                  label: Text(
                    'Eliminar',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: colors.danger),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: colors.danger.withOpacity(0.1),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(color: colors.danger.withOpacity(0.2)),
                    ),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildInfoRow({required IconData icon, required String text, required AppColors colors}) {
    return Row(
      children: [
        Icon(icon, size: 18, color: colors.accent),
        const SizedBox(width: 10),
        Text(
          text,
          style: TextStyle(
            fontSize: 13,
            color: colors.muted,
          ),
        ),
      ],
    );
  }
}
