import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../theme/app_theme.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onTap;
  final VoidCallback onToggleDone;
  final VoidCallback onDelete;
  final VoidCallback? onPostpone;

  const TaskCard({
    Key? key,
    required this.task,
    required this.onTap,
    required this.onToggleDone,
    required this.onDelete,
    this.onPostpone,
  }) : super(key: key);

  String _formatDate(String dateStr) {
    if (dateStr.isEmpty) return 'Sin fecha';
    try {
      final date = DateTime.parse(dateStr);
      final monthMap = {
        1: 'ene', 2: 'feb', 3: 'mar', 4: 'abr', 5: 'may', 6: 'jun',
        7: 'jul', 8: 'ago', 9: 'sep', 10: 'oct', 11: 'nov', 12: 'dic'
      };
      return '${date.day} ${monthMap[date.month]}';
    } catch (e) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    Color priorityColor;
    switch (task.priority) {
      case TaskPriority.alta:
        priorityColor = colors.danger;
        break;
      case TaskPriority.media:
        priorityColor = colors.warn;
        break;
      case TaskPriority.baja:
        priorityColor = colors.success;
        break;
    }

    final isCompleted = task.done;

    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: isCompleted
          ? _buildCardContent(priorityColor, colors, isCompleted)
          : Dismissible(
              key: Key('dismiss_${task.id}'),
              background: _buildSwipeBackground(colors.success, Icons.check, 'Completar', Alignment.centerLeft),
              secondaryBackground: _buildSwipeBackground(colors.warn, Icons.schedule, 'Posponer', Alignment.centerRight),
              confirmDismiss: (direction) async {
                if (direction == DismissDirection.startToEnd) {
                  onToggleDone();
                  return false;
                } else if (direction == DismissDirection.endToStart) {
                  if (onPostpone != null) onPostpone!();
                  return false;
                }
                return false;
              },
              child: _buildCardContent(priorityColor, colors, isCompleted),
            ),
    );
  }

  Widget _buildCardContent(Color priorityColor, AppColors colors, bool isCompleted) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Opacity(
          opacity: isCompleted ? 0.55 : 1.0,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isCompleted ? Colors.transparent : colors.borderSoft,
                  width: 1,
                ),
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Left Priority Border
                  Positioned(
                    left: -16,
                    top: -14,
                    bottom: -14,
                    child: Container(
                      width: 4,
                      decoration: BoxDecoration(
                        color: isCompleted ? Colors.transparent : priorityColor,
                      ),
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Checkbox
                      GestureDetector(
                        onTap: onToggleDone,
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          width: 22,
                          height: 22,
                          margin: const EdgeInsets.only(top: 2, right: 14),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isCompleted ? colors.accent : colors.border,
                              width: 2,
                            ),
                            color: isCompleted ? colors.accent : Colors.transparent,
                          ),
                          child: isCompleted
                              ? Icon(Icons.check, size: 16, color: colors.accentOn)
                              : null,
                        ),
                      ),
                      // Body
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              task.title,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: isCompleted ? colors.muted : colors.fg,
                                decoration: isCompleted ? TextDecoration.lineThrough : null,
                                height: 1.3,
                              ),
                            ),
                            if (task.desc.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                task.desc,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: colors.muted,
                                  height: 1.4,
                                ),
                              ),
                            ],
                            const SizedBox(height: 8),
                            // Meta Tags
                            Wrap(
                              spacing: 8,
                              runSpacing: 4,
                              children: [
                                _buildTag(
                                  icon: task.type == TaskType.reunion ? Icons.videocam : (task.date.isEmpty ? Icons.notifications : Icons.today),
                                  text: task.type == TaskType.reunion && task.time != null ? '${_formatDate(task.date)} ${task.time}' : _formatDate(task.date),
                                  color: colors.muted,
                                  bgColor: Colors.black.withOpacity(0.04),
                                ),
                                _buildTag(
                                  text: task.priority == TaskPriority.alta ? 'Alta' : task.priority == TaskPriority.media ? 'Media' : 'Baja',
                                  color: colors.muted,
                                  bgColor: Colors.black.withOpacity(0.04),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Delete button
                      IconButton(
                        onPressed: onDelete,
                        icon: const Icon(Icons.delete_outline),
                        color: colors.muted,
                        iconSize: 20,
                        constraints: const BoxConstraints(),
                        padding: const EdgeInsets.all(4),
                        splashRadius: 20,
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTag({IconData? icon, required String text, required Color color, required Color bgColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: color,
              fontFamily: 'Geist Mono', // Fallback handled by Flutter if not loaded properly, but let's assume it works or uses default mono
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwipeBackground(Color color, IconData icon, String text, Alignment alignment) {
    return Container(
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(height: 4),
          Text(text, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}