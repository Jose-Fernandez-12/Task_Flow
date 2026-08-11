import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Bottom sheet shown on long-press of a task card, with quick actions.
class TaskContextMenu extends StatelessWidget {
  final String taskTitle;
  final VoidCallback onEdit;
  final VoidCallback onDuplicate;
  final VoidCallback onMove;
  final VoidCallback onFocus;
  final VoidCallback onDelete;

  const TaskContextMenu({
    Key? key,
    required this.taskTitle,
    required this.onEdit,
    required this.onDuplicate,
    required this.onMove,
    required this.onFocus,
    required this.onDelete,
  }) : super(key: key);

  void _run(BuildContext context, VoidCallback action) {
    Navigator.pop(context);
    action();
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
        left: 12,
        right: 12,
        top: 12,
        bottom: 16 + MediaQuery.of(context).padding.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: colors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Text(
              taskTitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: colors.fg,
                height: 1.3,
              ),
            ),
          ),
          const SizedBox(height: 4),
          _buildTile(
            context,
            icon: Icons.edit_outlined,
            label: 'Editar',
            onTap: () => _run(context, onEdit),
            color: colors.accent,
          ),
          _buildTile(
            context,
            icon: Icons.copy_outlined,
            label: 'Duplicar',
            onTap: () => _run(context, onDuplicate),
            color: colors.fg2,
          ),
          _buildTile(
            context,
            icon: Icons.calendar_month_outlined,
            label: 'Mover a otro día',
            onTap: () => _run(context, onMove),
            color: colors.fg2,
          ),
          _buildTile(
            context,
            icon: Icons.timer_outlined,
            label: 'Foco Pomodoro',
            onTap: () => _run(context, onFocus),
            color: colors.fg2,
          ),
          Divider(height: 16, color: colors.borderSoft),
          _buildTile(
            context,
            icon: Icons.delete_outline,
            label: 'Eliminar',
            onTap: () => _run(context, onDelete),
            color: colors.danger,
          ),
        ],
      ),
    );
  }

  Widget _buildTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
  }) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              Icon(icon, size: 22, color: color),
              const SizedBox(width: 14),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: color == colors.danger ? color : colors.fg,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
